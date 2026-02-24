import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle title = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    height: 36 / 24, // 1.5
    letterSpacing: -0.06 * 24, // -6%
    color: AppColors.textPrimary,
  );

  static TextStyle description = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400, // Regular
    height: 24 / 15, // 1.6
    letterSpacing: -0.04 * 15, // -4%
    color: AppColors.textSecondary,
  );

  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.0, // 100%
    letterSpacing: -0.03 * 16, // -3%
    color: AppColors.textPrimary,
  );
}
