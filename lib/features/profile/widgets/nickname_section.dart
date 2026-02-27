import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zybo_expense_tracker/features/profile/widgets/profile_section_label.dart';
import 'package:zybo_expense_tracker/features/profile/widgets/edit_nickname_dialog.dart';

class NicknameSection extends StatelessWidget {
  final String nickname;
  final ValueChanged<String> onNicknameChanged;

  const NicknameSection({
    super.key,
    required this.nickname,
    required this.onNicknameChanged,
  });

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditNicknameDialog(
        currentNickname: nickname,
        onSave: onNicknameChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionLabel(text: "NICKNAME"),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 64,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
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
                nickname,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  height: 1.5,
                  letterSpacing: -0.05 * 14,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditDialog(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      PhosphorIcons.pencilSimple(),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
