import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_bloc.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_event.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_state.dart';
import 'package:zybo_expense_tracker/features/transactions/widgets/transaction_card.dart';
import 'package:zybo_expense_tracker/core/widgets/shimmer_loading.dart';

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
                    return ListView.builder(
                      itemCount: 8,
                      itemBuilder: (context, index) =>
                          const TransactionCardShimmer(),
                    );
                  } else if (state is TransactionLoaded ||
                      state is TransactionSyncing) {
                    final txs = state is TransactionLoaded
                        ? state.transactions
                        : (state as TransactionSyncing).transactions;
                    if (txs.isEmpty) {
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
                      itemCount: txs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = txs[index];
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
