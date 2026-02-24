import 'package:flutter/material.dart';
import 'dart:async';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';
import 'walkthrough_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to walkthrough after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'assets/images/logo_zybo.jpeg',
          width: 150, // Adjust size based on actual logo asset
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
