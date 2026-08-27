import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../features/academic_structure/models/academic_term_model.dart';
import '../../features/academic_structure/providers/academic_context_provider.dart';

class AcademicContextSelector extends ConsumerWidget {
  final bool compact;

  const AcademicContextSelector({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTerm = ref.watch(selectedAcademicTermProvider);
    final eligibleTermsAsync = ref.watch(userEligibleTermsProvider);
    final isReadOnly = ref.watch(isReadOnlyHistoricalTermProvider);

    return eligibleTermsAsync.when(
      data: (terms) {
        if (terms.isEmpty) return const SizedBox.shrink();

        final currentSelected = selectedTerm ?? terms.firstWhere((t) => t.isActive, orElse: () => terms.first);

        return Container(
          decoration: BoxDecoration(
            color: isReadOnly ? AppColors.warning.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isReadOnly ? AppColors.warning.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: PopupMenuButton<AcademicTermModel>(
            tooltip: 'Select Academic Context (AY + Semester)',
            offset: const Offset(0, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            initialValue: currentSelected,
            onSelected: (term) {
              ref.read(selectedAcademicTermProvider.notifier).setTerm(term);
            },
            itemBuilder: (context) {
              return terms.map((term) {
                final isCurrentActive = term.isActive;
                final isSelected = term.id == currentSelected.id;

                return PopupMenuItem<AcademicTermModel>(
                  value: term,
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        size: 16,
                        color: isSelected ? AppColors.primary : AppColors.textGrey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${term.academicYear} — ${term.semester} Semester',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (isCurrentActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: compact ? 14 : 16,
                  color: isReadOnly ? AppColors.warning : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  compact
                      ? '${currentSelected.academicYear} (${currentSelected.semester})'
                      : 'AY: ${currentSelected.academicYear} | ${currentSelected.semester} Sem',
                  style: GoogleFonts.inter(
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: isReadOnly ? const Color(0xFFB45309) : AppColors.primaryDark,
                  ),
                ),
                if (isReadOnly) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Archive',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: isReadOnly ? const Color(0xFFB45309) : AppColors.primary,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
