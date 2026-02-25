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
            fontSize: 14,
            letterSpacing: -0.05 * 14,
            height: 1.5,
            color: Colors.white,
      ),
    );
  }
}
