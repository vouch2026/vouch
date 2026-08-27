import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../features/academic_structure/providers/academic_context_provider.dart';
import '../../features/academic_structure/providers/term_provider.dart';

class HistoricalArchiveBanner extends ConsumerWidget {
  const HistoricalArchiveBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReadOnly = ref.watch(isReadOnlyHistoricalTermProvider);
    final selectedTerm = ref.watch(selectedAcademicTermProvider);

    if (!isReadOnly || selectedTerm == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Soft Amber Background
        border: const Border(
          bottom: BorderSide(color: Color(0xFFFCD34D), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_clock_outlined,
            size: 20,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF92400E),
                ),
                children: [
                  const TextSpan(
                    text: 'Historical Archive Mode: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        'You are viewing records for ${selectedTerm.academicYear} (${selectedTerm.semester} Semester). Operational data is read-only — creation and editing are disabled.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              final activeTerm = ref.read(activeTermProvider).value;
              if (activeTerm != null) {
                ref.read(selectedAcademicTermProvider.notifier).setTerm(activeTerm);
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Switch to Current Active Term',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
