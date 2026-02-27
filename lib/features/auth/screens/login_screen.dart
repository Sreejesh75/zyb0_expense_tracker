import 'package:flutter/material.dart';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';
import 'package:zybo_expense_tracker/core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zybo_expense_tracker/features/auth/bloc/auth_bloc.dart';
import 'package:zybo_expense_tracker/features/auth/bloc/auth_event.dart';
import 'package:zybo_expense_tracker/features/auth/bloc/auth_state.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'OTP sent successfully: ${state.expectedOtp}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtpScreen(phoneNumber: _phoneController.text),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 64), // Spacing from top
                  // Title
                  Text('Get Started', style: AppTextStyles.loginTitle),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Log In Using Phone & OTP',
                    style: AppTextStyles.description,
                  ),
                  const SizedBox(height: 48),

                  // Phone Number Input Container
                  Container(
                    width: double.infinity,
                    height: 56,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Country Code
                        Text(
                          '+91',
                          style: AppTextStyles.description.copyWith(
                            color: AppColors
                                .textPrimary, // Explicit white color as per design
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Separator
                        Container(
                          width: 1,
                          height: 24,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.5,
                          ), // Muted divider
                        ),
                        const SizedBox(width: 10),

                        // Phone Input Field
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: AppTextStyles.description.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Phone',
                              hintStyle: AppTextStyles.description.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final phone = _phoneController.text.trim();
                              if (phone.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please enter your phone number",
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              } else if (phone.length < 10) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Phone number must be at least 10 digits",
                                    ),
                                    backgroundColor: Colors.orangeAccent,
                                  ),
                                );
                              } else if (phone.length > 10) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Phone number cannot exceed 10 digits",
                                    ),
                                    backgroundColor: Colors.orangeAccent,
                                  ),
                                );
                              } else {
                                context.read<AuthBloc>().add(
                                  SendOtpEvent(phone),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Continue', style: AppTextStyles.buttonText),
                    ),
                  ),

                  // The numeric keyboard will pop up from the bottom natively natively on tap
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
