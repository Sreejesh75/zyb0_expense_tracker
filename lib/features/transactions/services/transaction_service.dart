import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:zybo_expense_tracker/core/constants/api_constants.dart';
import 'package:zybo_expense_tracker/features/auth/services/auth_service.dart';
import 'package:zybo_expense_tracker/features/transactions/models/transaction_model.dart';

class TransactionService {
  final Dio _dio;
  final AuthService _authService;

  TransactionService(this._authService)
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
            options.headers['Authorization'] =
                'Bearer $token'; // Assumes Bearer logic
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _dio.get(ApiConstants.getTransactions);

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      if (data['status'] == 'success') {
        final List<dynamic> jsonList = data['transactions'];
        return jsonList.map((json) => TransactionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<List<String>> syncTransactions(
    List<TransactionModel> transactions,
  ) async {
    if (transactions.isEmpty) return [];

    List<String> syncedIds = [];
    for (var tx in transactions) {
      try {
        final payload = tx.toApiJson();

        final response = await _dio.post(
          ApiConstants.addTransactions,
          data: payload,
        );

        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        // Assuming either it indicates success or echoes back the ID
        if (data['status'] == 'success') {
          syncedIds.add(tx.id);
        } else if (data['synced_ids'] != null &&
            data['synced_ids'].contains(tx.id)) {
          syncedIds.add(tx.id);
        }
      } catch (e) {
        print('Error syncing transaction ${tx.id}: $e');
      }
    }
    return syncedIds;
  }

  // Batch delete on the server
  Future<List<String>> deleteTransactions(List<String> ids) async {
    if (ids.isEmpty) return [];

    List<String> deletedIds = [];
    for (String id in ids) {
      try {
        final response = await _dio.delete(
          ApiConstants.deleteTransactions,
          data: {
            'ids': [id],
            'transaction_id': id,
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
            'Error deleting transaction $id: ${e.response?.statusCode} - ${e.response?.data}',
          );
        }
      } catch (e) {
        print('Error deleting transaction $id: $e');
      }
    }
    return deletedIds;
  }
}
