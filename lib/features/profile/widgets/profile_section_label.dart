import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSectionLabel extends StatelessWidget {
  final String text;

  const ProfileSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 12, // Usually slightly smaller for section headers
        letterSpacing: -0.05 * 12,
        color: Colors.white.withValues(alpha: 0.5),
        height: 1.5,
      ),
    );
  }
}
