import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nickname = "User";
  double _currentLimit = 10000;
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: 100.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
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
            const SizedBox(height: 32),

            // NICKNAME SECTION
            _buildSectionLabel("NICKNAME"),
            const SizedBox(height: 12),
            Container(
              width: 343,
              height: 64,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Slightly varied dark
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _nickname,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400, // Regular
                      fontSize: 14,
                      height: 1.5,
                      letterSpacing: -0.05 * 14,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black, // Black fill to highlight it
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        PhosphorIcons.pencilSimple(),
                        color: Colors.white,
                        size: 18, // Slightly bigger
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),

            // ALERT LIMIT SECTION
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 343),
              padding: const EdgeInsets.only(
                top: 20,
                right: 16,
                bottom: 20,
                left: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.1,
                  ), // 1px solid #FFFFFF1A
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("ALERT LIMIT (₹)"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF262626), // Text field bg
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              if (_amountController.text.isEmpty)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Amount ",
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        height: 1.0,
                                        letterSpacing: -0.03 * 18,
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "( ₹ )",
                                      style: TextStyle(
                                        fontFamily: 'Helvetica Neue',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        height: 1.0,
                                        letterSpacing: -0.05 * 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // gap: 10px from prompt
                      Container(
                        width: 54,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF312ECB), // background: #312ECB
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: _setLimit,
                            child: const Center(
                              child: Text(
                                "Set",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Current Limit: ₹${NumberFormat.decimalPattern().format(_currentLimit)}",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      letterSpacing: -0.03 * 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),

            // CATEGORIES SECTION
            _buildSectionLabel("CATEGORIES"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "New category Name",
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCategoryItem("Food"),
            _buildCategoryItem("Bills"),
            _buildCategoryItem("Transport"),
            _buildCategoryItem("Shopping", isLast: true),
            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),

            // CLOUD SYNC SECTION
            _buildSectionLabel("CLOUD SYNC"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF383874),
                    Color(0xFF2B2B5C),
                  ], // Deep purplish gradient
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sync To Cloud",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Sync and update data to the backend",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(PhosphorIcons.cloudArrowUp(), color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // LOG OUT BUTTON
            GestureDetector(
              onTap: () {
                // Handle logout
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Dark bg
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Log Out",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: const Color(0xFFFF4141), // Red color
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      PhosphorIcons.power(),
                      color: const Color(0xFFFF4141),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
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

  Widget _buildCategoryItem(String name, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3437).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFF3437).withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              PhosphorIcons.trash(),
              color: const Color(0xFFFF3437),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
