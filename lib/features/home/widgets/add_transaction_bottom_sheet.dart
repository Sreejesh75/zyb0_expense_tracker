import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_bloc.dart';
import 'package:zybo_expense_tracker/features/transactions/bloc/transaction_event.dart';
import 'package:zybo_expense_tracker/features/transactions/models/transaction_model.dart';
import 'package:zybo_expense_tracker/features/categories/bloc/category_bloc.dart';
import 'package:zybo_expense_tracker/features/categories/bloc/category_state.dart';

class AddTransactionBottomSheet extends StatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  State<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet> {
  bool isExpense = true;
  String? selectedCategoryId;
  String? selectedCategoryName;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      note: title,
      amount: amount,
      type: isExpense
          ? 'debit'
          : 'credit', // Usually expense=debit, income=credit
      category_id: selectedCategoryId!,
      categoryName: selectedCategoryName,
      timestamp: DateTime.now(),
    );

    context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375,
      height: 578,
      padding: const EdgeInsets.only(top: 32, right: 16, left: 16, bottom: 20),
      // ... all UI elements ... same as before
      decoration: const BoxDecoration(
        color: Color(0xFF1F1F1F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Transaction",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  letterSpacing: -0.05 * 24,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  "Close",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: -0.03 * 14,
                    height: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expense / Income Toggle
          Container(
            height: 56,
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(
                0xFF121212,
              ), // Darker background for toggle tab
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isExpense = true),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isExpense
                            ? const Color(0xFF1DC533)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Expense",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: isExpense ? Colors.white : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isExpense = false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: !isExpense
                            ? const Color(0xFF1DC533)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Income",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: !isExpense ? Colors.white : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Title Input Container
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF262626), // Text field bg
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Title",
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Amount Input Container
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF262626), 
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
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  onChanged: (_) => setState(
                    () {},
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category Label
          Text(
            "CATEGORY",
            style: TextStyle(
              fontFamily: 'Helvetica Neue',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              letterSpacing: -0.03 * 13,
              height: 1.0,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),

          // Categories Options
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              List<dynamic> displayCategories = [];
              if (state is CategoryLoaded) {
                displayCategories = state.categories;
              } else if (state is CategorySyncing) {
                displayCategories = state.categories;
              }

              if (displayCategories.isEmpty && state is CategoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (displayCategories.isEmpty) {
                return const Text(
                  "No categories available",
                  style: TextStyle(color: Colors.white54),
                );
              }

           
              if (selectedCategoryId == null && displayCategories.isNotEmpty) {
                selectedCategoryId = displayCategories.first.id;
                selectedCategoryName = displayCategories.first.name;
              } else if (selectedCategoryId != null &&
                  !displayCategories.any((c) => c.id == selectedCategoryId)) {
                selectedCategoryId = displayCategories.isNotEmpty
                    ? displayCategories.first.id
                    : null;
                selectedCategoryName = displayCategories.isNotEmpty
                    ? displayCategories.first.name
                    : null;
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: displayCategories.map((cat) {
                    bool isSelected = selectedCategoryId == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryId = cat.id;
                            selectedCategoryName = cat.name;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            cat.name,
                            style: TextStyle(
                              fontFamily: 'Helvetica Neue',
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              letterSpacing: -0.03 * 15,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 22),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF18281A), 
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Everything you add here is saved only on your device.",
                    style: TextStyle(
                      fontFamily: 'Helvetica Neue',
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
