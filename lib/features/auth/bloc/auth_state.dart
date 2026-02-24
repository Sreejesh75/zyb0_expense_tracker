import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {
  final String phone;
  final String expectedOtp;
  final bool userExists;
  // Included token & nickname if user exists during the OTP send
  final String? token;
  final String? nickname;

  const OtpSentState({
    required this.phone,
    required this.expectedOtp,
    required this.userExists,
    this.token,
    this.nickname,
  });

  @override
  List<Object?> get props => [phone, expectedOtp, userExists, token, nickname];
}

// Emitted when OTP is valid, but user doesn't exist yet -> show name prompt
class OtpVerifiedNeedsAccount extends AuthState {
  final String phone;
  const OtpVerifiedNeedsAccount(this.phone);

  @override
  List<Object?> get props => [phone];
}

class AuthSuccess extends AuthState {
  final String token;
  const AuthSuccess(this.token);

  @override
  List<Object?> get props => [token];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
