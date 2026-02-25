import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_bloc.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_event.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_state.dart';
import 'package:zybo_expense_tracker/features/transactions/widgets/transaction_card.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              " Transactions",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.05 * 24,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (state is TransactionLoaded) {
                    if (state.transactions.isEmpty) {
                      return Center(
                        child: Text(
                          "No transactions yet.",
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(
                        bottom: 80,
                      ), // Avoid overlap with fab/navbar
                      itemCount: state.transactions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = state.transactions[index];
                        return TransactionCard(
                          transaction: tx,
                          onDelete: () {
                            context.read<TransactionBloc>().add(
                              DeleteTransactionEvent(tx.id),
                            );
                          },
                        );
                      },
                    );
                  } else if (state is TransactionError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
