import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<ValidateOtpEvent>(_onValidateOtp);
    on<CreateAccountEvent>(_onCreateAccount);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authService.sendOtp(event.phone);

      if (response['status'] == 'success') {
        final String receivedOtp = response['otp'].toString();
        debugPrint('--- OTP RECEIVED FROM API: $receivedOtp ---');

        emit(
          OtpSentState(
            phone: event.phone,
            expectedOtp: receivedOtp, // API returns OTP for testing
            userExists: response['user_exists'] ?? false,
            token: response['token'],
            nickname: response['nickname'],
          ),
        );
      } else {
        emit(AuthError(response['message'] ?? 'Failed to send OTP'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onValidateOtp(
    ValidateOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is OtpSentState) {
      if (currentState.expectedOtp == event.otpToVerify) {
        // OTP matches
        if (currentState.userExists && currentState.token != null) {
          // Returning user: Save info locally and succeed
          await authService.saveAuthData(
            currentState.token!,
            currentState.nickname ?? 'User',
          );
          emit(AuthSuccess(currentState.token!));
        } else {
          // New user: Requires nickname and create account
          emit(OtpVerifiedNeedsAccount(event.phone));
        }
      } else {
        emit(const AuthError("Invalid OTP entered"));
        // Need to revert to OtpSentState so the user can try again
        emit(currentState);
      }
    } else {
      emit(const AuthError("Invalid state for OTP validation"));
    }
  }

  Future<void> _onCreateAccount(
    CreateAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authService.createAccount(
        event.phone,
        event.nickname,
      );

      if (response['status'] == 'success' && response['token'] != null) {
        final String token = response['token'];
        await authService.saveAuthData(token, event.nickname);
        emit(AuthSuccess(token));
      } else {
        emit(AuthError(response['message'] ?? 'Failed to create account'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
