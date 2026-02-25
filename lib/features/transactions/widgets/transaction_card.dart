import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zybo_expense_tracker/features/transactions/models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCredit = transaction.type == 'credit';
    final formatter = NumberFormat("#,##0");
    final formattedAmount = "₹${formatter.format(transaction.amount)}";
    final amountText = isCredit ? "+$formattedAmount" : "-$formattedAmount";
    final amountColor = isCredit
        ? const Color(0xFF34FF4F)
        : const Color(0xFFFF3437);

    // Custom date logic based on requested UI (12th Dec 2026)
    // Note: 'do' isn't fully supported consistently in all locales for intl,
    // a safer fallback is 'd MMM yyyy' but let's implement the suffix manually for perfection:
    final day = transaction.timestamp.day;
    final suffix = (day >= 11 && day <= 13)
        ? 'th'
        : {1: 'st', 2: 'nd', 3: 'rd'}[day % 10] ?? 'th';
    final formattedDate =
        "${day}$suffix ${DateFormat("MMM yyyy").format(transaction.timestamp)}";

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 343),
      // Removed fixed height to prevent overflow
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Match dark background pattern
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(transaction.category),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  transaction.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, // Semi Bold
                    fontSize: 16,
                    height: 1.5,
                    letterSpacing: -0.05 * 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  transaction.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400, // Regular
                    fontSize: 14,
                    height: 1.5,
                    letterSpacing: -0.05 * 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Metrics & Delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    formattedDate,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400, // Regular
                      fontSize: 13,
                      height: 1.5,
                      letterSpacing: -0.05 * 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete, // Basic material or Phosphor
                      color: Color(0xFFFF3437),
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                amountText,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500, // Medium
                  fontSize: 22, // Set to 22 per specs
                  height: 1.5,
                  letterSpacing: -0.05 * 22,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return PhosphorIcons.hamburger();
      case 'bills':
        return PhosphorIcons.receipt();
      case 'transport':
        return PhosphorIcons.bus();
      case 'shopping':
        return PhosphorIcons.shoppingCart();
      default:
        return PhosphorIcons.list();
    }
  }
}
