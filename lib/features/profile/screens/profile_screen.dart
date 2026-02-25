import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zybo_expense_tracker/features/profile/widgets/nickname_section.dart';
import 'package:zybo_expense_tracker/features/profile/widgets/alert_limit_section.dart';
import 'package:zybo_expense_tracker/features/profile/widgets/categories_section.dart';
import 'package:zybo_expense_tracker/features/profile/widgets/cloud_sync_section.dart';
import 'package:zybo_expense_tracker/features/profile/widgets/logout_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nickname = "User";
  double _currentLimit = 10000;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('user_nickname') ?? "User";
      _currentLimit = prefs.getDouble('alert_limit') ?? 10000;
    });
  }

  Future<void> _setLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final amountText = _amountController.text;
    final parsedAmount = double.tryParse(amountText);

    if (parsedAmount != null && parsedAmount > 0) {
      await prefs.setDouble('alert_limit', parsedAmount);

      if (!mounted) return;

      setState(() {
        _currentLimit = parsedAmount;
      });
      _amountController.clear();
      FocusScope.of(context).unfocus(); // Close keyboard
    }
  }

  Widget _pad(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 24.0,
          bottom: 100.0 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _pad(
              Text(
                "Profile & Settings",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, // Semi Bold
                  fontSize: 20,
                  height: 1.5,
                  letterSpacing: -0.05 * 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // NICKNAME SECTION
            _pad(NicknameSection(nickname: _nickname)),
            const SizedBox(height: 32),
            const Divider(color: Colors.white10, thickness: 3, height: 3),
            const SizedBox(height: 32),

            // ALERT LIMIT SECTION
            _pad(
              AlertLimitSection(
                amountController: _amountController,
                currentLimit: _currentLimit,
                onSetLimit: _setLimit,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white10, thickness: 3, height: 3),
            const SizedBox(height: 5),

            // CATEGORIES SECTION
            _pad(CategoriesSection(categoryController: _categoryController)),
            const SizedBox(height: 32),
            const Divider(color: Colors.white10, thickness: 3, height: 3),
            const SizedBox(height: 15),

            // CLOUD SYNC SECTION
            _pad(const CloudSyncSection()),
            const SizedBox(height: 24),

            // LOG OUT BUTTON
            _pad(
              LogoutButton(
                onTap: () {
                  // Handle logout
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
