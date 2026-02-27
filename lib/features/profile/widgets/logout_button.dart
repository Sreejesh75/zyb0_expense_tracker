import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zybo_expense_tracker/features/profile/widgets/logout_confirm_dialog.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => LogoutConfirmDialog(onConfirm: onTap),
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(
            0xFF1E1E1E,
          ), // Dark bg, this matches Figma mock visual look
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.1,
            ), // Matched border with Cloud Sync section
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Log Out",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: -0.05 * 15,
                height: 1.5,
                color: const Color(0xFFFF2929),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              PhosphorIcons.power(),
              color: const Color(0xFFFF2929),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
