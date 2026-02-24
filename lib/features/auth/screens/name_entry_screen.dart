import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';
import 'package:zybo_expense_tracker/core/theme/app_text_styles.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class NameEntryScreen extends StatefulWidget {
  final String phone;

  const NameEntryScreen({super.key, required this.phone});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isValid = false;

  void _validateName(String value) {
    setState(() {
      _isValid = value.trim().length >= 3;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate to Home
            print("To Home!");
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 64),

                  // Title
                  Text(
                    '👋 What should we call you?',
                    style: AppTextStyles.loginTitle,
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'This name stays only on your device.',
                    style: AppTextStyles.description,
                  ),
                  const SizedBox(height: 48),

                  // Name Input Container
                  Container(
                    width: double.infinity,
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: AppColors.grey800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: AppTextStyles.description.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            onChanged: _validateName,
                            decoration: InputDecoration(
                              hintText: 'Eg: Johnnnie',
                              hintStyle: AppTextStyles.description.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_isValid)
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors
                                .green, // Visual indicator shown in screenshots
                            size: 20,
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
                      onPressed: (_isValid && !isLoading)
                          ? () {
                              context.read<AuthBloc>().add(
                                CreateAccountEvent(
                                  widget.phone,
                                  _nameController.text.trim(),
                                ),
                              );
                            }
                          : null, // disables button natively
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValid
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.3),
                        foregroundColor: AppColors.textPrimary,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.2,
                        ),
                        disabledForegroundColor: AppColors.textSecondary,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
