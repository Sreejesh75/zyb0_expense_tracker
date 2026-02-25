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

    try {
      final requestData = {
        'categories': categories.map((c) => c.toApiJson()).toList(),
      };

      final response = await _dio.post(
        ApiConstants.addCategories,
        data: requestData,
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      if (data['status'] == 'success') {
        final List<dynamic> rawIds = data['synced_ids'] ?? [];
        return rawIds.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to sync categories: $e');
    }
  }

  Future<List<String>> deleteCategories(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final response = await _dio.delete(
        ApiConstants.deleteCategories,
        data: {'ids': ids},
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      if (data['status'] == 'success') {
        final List<dynamic> rawIds = data['deleted_ids'] ?? [];
        return rawIds.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to delete categories: $e');
    }
  }
}
