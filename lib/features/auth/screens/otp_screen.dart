import 'package:flutter/material.dart';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';
import 'package:zybo_expense_tracker/core/theme/app_text_styles.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next input
      if (index < 3) {
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Title
              Text('Verify OTP', style: AppTextStyles.loginTitle),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Enter the 4-Digit code sent to $maskedPhone',
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
                children: List.generate(4, (index) {
                  return Container(
                    width: 79.75,
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
                    // TODO: Execute verification
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
                  Text('Resend OTP in ', style: AppTextStyles.description),
                  Text(
                    '32s',
                    style: AppTextStyles.description.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
