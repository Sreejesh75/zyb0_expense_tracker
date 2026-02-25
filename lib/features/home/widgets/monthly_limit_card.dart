import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MonthlyLimitCard extends StatelessWidget {
  final double currentAmount;
  final double limitAmount;
  final String title;

  const MonthlyLimitCard({
    super.key,
    required this.currentAmount,
    required this.limitAmount,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    double progress = limitAmount > 0 ? (currentAmount / limitAmount) : 0;
    bool isExceeded = currentAmount >= limitAmount;

    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0) progress = 0.0;

    int remainingPercent = isExceeded ? 0 : ((1.0 - progress) * 100).round();
    final formatter = NumberFormat("#,##0");
    final displayedCurrent = isExceeded ? limitAmount : currentAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, right: 16, bottom: 20, left: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Using grey800 from app_colors
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              letterSpacing: -0.05 * 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "₹${formatter.format(displayedCurrent)}",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.05 * 16,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "/ ₹${formatter.format(limitAmount)}",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: -0.05 * 14,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              if (isExceeded)
                Icon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: const Color(0xFF1DC533),
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isExceeded
                  ? const Color(0xFF900B0D)
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: isExceeded
                        ? const [Color(0xFFFF3437), Color(0xFF900B0D)]
                        : const [Color(0xFF1DC533), Color(0xFF0E5F19)],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isExceeded ? "Limit Exceeded" : "$remainingPercent% Remaining",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              letterSpacing: -0.05 * 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
