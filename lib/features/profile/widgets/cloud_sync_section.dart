import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:zybo_expense_tracker/features/profile/widgets/sync_cloud_dialog.dart';

class CloudSyncSection extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const CloudSyncSection({
    super.key,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CLOUD SYNC",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            letterSpacing: -0.05 * 14,
            height: 1.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => SyncCloudDialog(
                initialEnabled: isEnabled,
                onToggle: onToggle,
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: 104,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFF312ECB).withValues(alpha: 0.5)
                    : const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sync To Cloud",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: -0.05 * 18,
                            height: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEnabled
                              ? "✔ Connected & Syncing"
                              : "Sync and update data to the backend",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            letterSpacing: -0.03 * 14,
                            height: 1.2,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    isEnabled
                        ? PhosphorIcons.cloudCheck(PhosphorIconsStyle.fill)
                        : PhosphorIcons.cloudArrowUp(PhosphorIconsStyle.fill),
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
