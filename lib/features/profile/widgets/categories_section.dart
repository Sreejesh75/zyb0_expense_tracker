import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zybo_expense_tracker/features/categories/bloc/category_bloc.dart';
import 'package:zybo_expense_tracker/features/categories/bloc/category_event.dart';
import 'package:zybo_expense_tracker/features/categories/bloc/category_state.dart';

class CategoriesSection extends StatelessWidget {
  final TextEditingController categoryController;

  const CategoriesSection({super.key, required this.categoryController});

  Widget _buildCategoryItem(
    BuildContext context,
    String id,
    String name, {
    bool isLast = false,
  }) {
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
          GestureDetector(
            onTap: () {
              context.read<CategoryBloc>().add(DeleteCategoryEvent(id));
            },
            child: Container(
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CATEGORIES",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            letterSpacing: -0.05 * 14,
            height: 1.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: categoryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "New category Name",
                          hintStyle: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.03 * 15,
                            height: 1.0,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
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
                        onTap: () {
                          final text = categoryController.text.trim();
                          if (text.isNotEmpty) {
                            context.read<CategoryBloc>().add(
                              AddCategoryEvent(text),
                            );
                            categoryController.clear();
                            FocusScope.of(context).unfocus();
                          }
                        },
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white10),
              const SizedBox(height: 20),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF312ECB),
                      ),
                    );
                  } else if (state is CategoryLoaded ||
                      state is CategorySyncing) {
                    final categories = state is CategoryLoaded
                        ? state.categories
                        : (state as CategorySyncing).categories;

                    if (categories.isEmpty) {
                      return const Text(
                        "No categories yet.",
                        style: TextStyle(color: Colors.white54),
                      );
                    }

                    return Column(
                      children: categories.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final cat = entry.value;
                        return _buildCategoryItem(
                          context,
                          cat.id,
                          cat.name,
                          isLast: idx == categories.length - 1,
                        );
                      }).toList(),
                    );
                  } else if (state is CategoryError) {
                    return const Text(
                      "Failed to load categories",
                      style: TextStyle(color: Colors.redAccent),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
