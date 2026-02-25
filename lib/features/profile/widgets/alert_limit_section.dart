import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zybo_expense_tracker/features/profile/widgets/profile_section_label.dart';

class AlertLimitSection extends StatefulWidget {
  final TextEditingController amountController;
  final VoidCallback onSetLimit;
  final double currentLimit;

  const AlertLimitSection({
    super.key,
    required this.amountController,
    required this.onSetLimit,
    required this.currentLimit,
  });

  @override
  State<AlertLimitSection> createState() => _AlertLimitSectionState();
}

class _AlertLimitSectionState extends State<AlertLimitSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, right: 16, bottom: 20, left: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionLabel(text: "ALERT LIMIT (₹)"),
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
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      if (widget.amountController.text.isEmpty)
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
                                color: Colors.white.withValues(alpha: 0.5),
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
                        controller: widget.amountController,
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
              const SizedBox(width: 10),
              Container(
                width: 54,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF312ECB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: widget.onSetLimit,
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
            "Current Limit: ₹${NumberFormat.decimalPattern().format(widget.currentLimit)}",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: -0.03 * 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
