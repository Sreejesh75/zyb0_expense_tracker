import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zybo_expense_tracker/core/constants/api_constants.dart';
import 'package:zybo_expense_tracker/core/database/database_helper.dart';

class AuthService {
  final Dio _dio;

  AuthService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  /// Send OTP to the given phone number
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendOtp,
        data: {'phone': phone},
      );

      if (response.data is String) {
        return jsonDecode(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  /// Create a new account with the given nickname
  Future<Map<String, dynamic>> createAccount(
    String phone,
    String nickname,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.createAccount,
        data: {'phone': phone, 'nickname': nickname},
      );

      if (response.data is String) {
        return jsonDecode(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  /// Get local user profile
  Future<Map<String, dynamic>?> getLocalUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final nickname = prefs.getString('user_nickname');

    if (token != null && nickname != null && token.isNotEmpty) {
      return {'nickname': nickname, 'token': token};
    }

    // Fallback to SQLite
    final dbProfile = await DatabaseHelper.instance.getUserProfile();
    return dbProfile;
  }

  /// Save Token and Nickname locally
  Future<void> saveAuthData(String token, String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_nickname', nickname);

    // Save to SQLite as requested
    await DatabaseHelper.instance.saveUserProfile(nickname, token);
  }

  /// Read Token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    // Deliberately keep 'user_nickname' and 'DatabaseHelper' profile data
    // so the user's modifications survive across logins.
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      if (e.response?.data is Map) {
        return e.response?.data['message'] ?? 'Server error occurred';
      }
      return e.response?.statusMessage ?? 'Server error occurred';
    } else {
      return 'Network error or timeout. Check internet connection.';
    }
  }
}
