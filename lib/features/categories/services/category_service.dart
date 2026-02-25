import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:zybo_expense_tracker/core/constants/api_constants.dart';
import 'package:zybo_expense_tracker/features/auth/services/auth_service.dart';
import 'package:zybo_expense_tracker/features/categories/models/category_model.dart';

class CategoryService {
  final Dio _dio;
  final AuthService _authService;

  CategoryService(this._authService)
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.getCategories);
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (data['status'] == 'success') {
        final List<dynamic> jsonList = data['categories'] ?? [];
        return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<String>> syncCategories(List<CategoryModel> categories) async {
    if (categories.isEmpty) return [];

    List<String> syncedIds = [];
    for (var cat in categories) {
      try {
        final payload = cat.toApiJson();

        final response = await _dio.post(
          ApiConstants.addCategories,
          data: payload,
        );

        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        // Assuming either it indicates success or echoes back the ID
        if (data['status'] == 'success') {
          syncedIds.add(cat.id);
        } else if (data['synced_ids'] != null &&
            data['synced_ids'].contains(cat.id)) {
          syncedIds.add(cat.id);
        }
      } catch (e) {
        print('Error syncing category ${cat.id}: $e');
      }
    }
    return syncedIds;
  }

  Future<List<String>> deleteCategories(List<String> ids) async {
    if (ids.isEmpty) return [];

    List<String> deletedIds = [];
    for (String id in ids) {
      try {
        final response = await _dio.delete(
          ApiConstants.deleteCategories,
          data: {
            'ids': [id],
            'category_id': id,
          },
        );

        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        // Check both 'success' status or if the ID is just returned in a list
        if (data['status'] == 'success') {
          deletedIds.add(id);
        } else if (data['deleted_ids'] != null &&
            data['deleted_ids'].contains(id)) {
          deletedIds.add(id);
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          // If it's already 404 Not Found on the server, it is successfully deleted.
          deletedIds.add(id);
        } else {
          print(
            'Error deleting category $id: ${e.response?.statusCode} - ${e.response?.data}',
          );
        }
      } catch (e) {
        print('Error deleting category $id: $e');
      }
    }
    return deletedIds;
  }
}
