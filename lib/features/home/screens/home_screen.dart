import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';
import 'package:zybo_expense_tracker/features/home/widgets/balance_card.dart';
import 'package:zybo_expense_tracker/features/home/widgets/custom_nav_bar.dart';
import 'package:zybo_expense_tracker/features/home/widgets/monthly_limit_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zybo_expense_tracker/features/profile/screens/profile_screen.dart';
import 'package:zybo_expense_tracker/features/home/widgets/add_transaction_bottom_sheet.dart';
import 'package:zybo_expense_tracker/features/transactions/screens/transactions_screen.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_bloc.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_event.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_state.dart';
import 'package:zybo_expense_tracker/features/transactions/widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nickname = "User";
  int _selectedIndex = 0;
  double _alertLimit = 10000;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('user_nickname') ?? "User";
      _alertLimit = prefs.getDouble('alert_limit') ?? 10000;
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _loadUserProfile(); // Refresh data like limits when coming back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeContent(),
                const TransactionsScreen(),
                const ProfileScreen(),
              ],
            ),

            // Add Transaction Button
            Positioned(
              right: 24,
              bottom: 112,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: const AddTransactionBottomSheet(),
                    ),
                  );
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF20DE39), Color(0xFF147721)],
                    ),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),

            // Custom Floating Bottom Navigation Bar
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: CustomNavBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onNavTapped,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("👋 ", style: TextStyle(fontSize: 24)),
                Text(
                  "Welcome, $_nickname!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                double totalIncome = 0;
                double totalExpense = 0;

                if (state is TransactionLoaded) {
                  for (var tx in state.transactions) {
                    if (tx.type == 'credit') {
                      totalIncome += tx.amount;
                    } else if (tx.type == 'debit') {
                      totalExpense += tx.amount;
                    }
                  }

                  // Calculate net balance for the "Total Income" card as requested
                  totalIncome = totalIncome - totalExpense;
                }

                final formatter = NumberFormat("#,##0");
                final formattedIncome = "₹${formatter.format(totalIncome)}";
                final formattedExpense = "₹${formatter.format(totalExpense)}";

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: BalanceCard(
                            title:
                                "Total Balance", // Updated title to better reflect its meaning
                            amount: formattedIncome,
                            isIncome: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BalanceCard(
                            title: "Total Expense",
                            amount: formattedExpense,
                            isIncome: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    MonthlyLimitCard(
                      title: "Monthly Limit",
                      currentAmount: totalExpense,
                      limitAmount: _alertLimit,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            // Recent Transactions List with dynamic header
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
                      return const Center(
                        child: Text(
                          "No recent transactions",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recent Transactions",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.05 * 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 80),
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
                          ),
                        ),
                      ],
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
