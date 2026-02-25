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

  // Batch sync up to the server
  Future<List<String>> syncTransactions(
    List<TransactionModel> transactions,
  ) async {
    if (transactions.isEmpty) return [];

    try {
      final requestData = {
        'transactions': transactions.map((t) => t.toApiJson()).toList(),
      };

      final response = await _dio.post(
        ApiConstants.addTransactions,
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
      throw Exception('Failed to sync transactions: $e');
    }
  }

  // Batch delete on the server
  Future<List<String>> deleteTransactions(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final response = await _dio.delete(
        ApiConstants.deleteTransactions,
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
      throw Exception('Failed to delete transactions: $e');
    }
  }
}
