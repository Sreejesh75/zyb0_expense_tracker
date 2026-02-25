import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';
import 'package:zybo_expense_tracker/core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zybo_expense_tracker/features/auth/bloc/auth_bloc.dart';
import 'package:zybo_expense_tracker/features/auth/bloc/auth_event.dart';
import 'package:zybo_expense_tracker/features/auth/bloc/auth_state.dart';
import 'package:zybo_expense_tracker/features/auth/screens/name_entry_screen.dart';
import 'package:zybo_expense_tracker/features/home/screens/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _start = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _start = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next input
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        // Last node, dismiss keyboard
        _focusNodes[index].unfocus();
      }
    } else {
      // Move to previous input on delete
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Masking the phone number except last two digits, assuming arbitrary format
    // Real masking depends on exact digits, but visual shows 8606****23
    final maskedPhone = widget.phoneNumber.length > 6
        ? '${widget.phoneNumber.substring(0, 4)}****${widget.phoneNumber.substring(widget.phoneNumber.length - 2)}'
        : widget.phoneNumber;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          // Returning user: API returned token, proceed to Home
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        } else if (state is OtpVerifiedNeedsAccount) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          // New user: Needs nickname
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => NameEntryScreen(phone: widget.phoneNumber),
                ),
              )
              .then((_) {
                // Restart timer if user comes back
                _startTimer();
              });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is OtpSentState) {
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'OTP sent successfully: ${state.expectedOtp}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 30),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Title
                  Text('Verify OTP', style: AppTextStyles.loginTitle),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Enter the 6-Digit code sent to $maskedPhone',
                    style: AppTextStyles.description,
                  ),
                  const SizedBox(height: 4),

                  // Change Number Link
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Go back to login screen
                    },
                    child: Text('Change Number', style: AppTextStyles.linkText),
                  ),
                  const SizedBox(height: 40),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index == 5 ? 0 : 8),
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.grey800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: AppTextStyles
                                  .title, // Standardizing to large text size
                              decoration: InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                hintText: '-',
                                hintStyle: AppTextStyles.title.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              onChanged: (val) => _onOtpChanged(val, index),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final otp = _controllers.map((c) => c.text).join();
                        if (otp.length == 6) {
                          context.read<AuthBloc>().add(
                            ValidateOtpEvent(widget.phoneNumber, otp),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter 6 digits'),
                            ),
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
                      child: Text('Verify', style: AppTextStyles.buttonText),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Resend OTP text
                  Row(
                    children: [
                      Text(
                        _start > 0
                            ? 'Resend OTP in '
                            : 'Didn\'t receive code? ',
                        style: AppTextStyles.description,
                      ),
                      if (_start > 0)
                        Text(
                          '${_start}s',
                          style: AppTextStyles.description.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            context.read<AuthBloc>().add(
                              SendOtpEvent(widget.phoneNumber),
                            );
                          },
                          child: Text(
                            'Resend OTP',
                            style: AppTextStyles.linkText,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
