import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final url = 'https://appskilltest.zybotech.in/categories/add/';

  // Try 1: As per docs
  try {
    print('--- Test 1: {"categories": [{"id": "...", "name": "Food"}]} ---');
    final response = await dio.post(
      url,
      data: {
        "categories": [
          {"id": "test-id-1", "name": "Food"},
        ],
      },
    );
    print('Test 1 Success: ${response.data}');
  } on DioException catch (e) {
    print('Test 1 Error: ${e.response?.statusCode} - ${e.response?.data}');
  }

  // Try 2: Array only
  try {
    print('\n--- Test 2: [{"id": "...", "name": "Food"}] ---');
    final response = await dio.post(
      url,
      data: [
        {"id": "test-id-2", "name": "Food"},
      ],
    );
    print('Test 2 Success: ${response.data}');
  } on DioException catch (e) {
    print('Test 2 Error: ${e.response?.statusCode} - ${e.response?.data}');
  }

  // Try 3: Single object directly
  try {
    print('\n--- Test 3: {"id": "...", "name": "Food"} ---');
    final response = await dio.post(
      url,
      data: {"id": "test-id-3", "name": "Food"},
    );
    print('Test 3 Success: ${response.data}');
  } on DioException catch (e) {
    print('Test 3 Error: ${e.response?.statusCode} - ${e.response?.data}');
  }
}
