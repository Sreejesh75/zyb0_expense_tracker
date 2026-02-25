import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';
import 'package:zybo_expense_tracker/features/auth/bloc/auth_bloc.dart';
import 'package:zybo_expense_tracker/features/home/screens/home_screen.dart';
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
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final isLoggedIn = await context.read<AuthBloc>().authService.isLoggedIn();

    if (!mounted) return;

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WalkthroughScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'assets/images/logo_zybo.png',
          width: 150, // Adjust size based on actual logo asset
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
