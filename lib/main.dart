import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zybo_expense_tracker/core/theme/app_theme.dart';
import 'package:zybo_expense_tracker/features/auth/services/auth_service.dart';
import 'package:zybo_expense_tracker/features/auth/bloc/auth_bloc.dart';
import 'package:zybo_expense_tracker/features/onboarding/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc(authService)),
      ],
      child: MaterialApp(
        title: 'Zybo Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
