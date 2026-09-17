import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/academic_term_model.dart';
import '../providers/term_provider.dart';

class AcademicTermSelector extends ConsumerWidget {
  const AcademicTermSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider).value;
    final activeTerm = ref.watch(activeTermProvider).value;
    final selectedTerm = ref.watch(selectedTermProvider);

    if (user == null) return const SizedBox.shrink();

    // Check if user is admin/governance role
    final isAdmin = user.organizationIds.isNotEmpty || user.yearLevel == null;


    final termsAsync = ref.watch(
      accessibleTermsProvider((userId: user.id ?? '', isAdmin: isAdmin)),
    );

    return termsAsync.when(
      data: (terms) {
        if (terms.isEmpty) return const SizedBox.shrink();

        final currentSelection = selectedTerm ?? activeTerm ?? terms.first;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: selectedTerm?.id != activeTerm?.id 
                ? Colors.amber.shade50 
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selectedTerm?.id != activeTerm?.id 
                  ? Colors.amber.shade400 
                  : AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AcademicTermModel>(
              value: terms.any((t) => t.id == currentSelection.id) 
                  ? terms.firstWhere((t) => t.id == currentSelection.id)
                  : terms.first,
              icon: Icon(
                Icons.arrow_drop_down_rounded, 
                color: selectedTerm?.id != activeTerm?.id ? Colors.amber.shade900 : AppColors.primary,
              ),
              isDense: true,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selectedTerm?.id != activeTerm?.id ? Colors.amber.shade900 : AppColors.primary,
              ),
              items: terms.map((term) {
                final isActive = term.id == activeTerm?.id;
                return DropdownMenuItem<AcademicTermModel>(
                  value: term,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? Icons.stars_rounded : Icons.history_rounded,
                        size: 14,
                        color: isActive ? Colors.amber.shade700 : Colors.grey[600],
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'AY ${term.academicYear} | ${term.semester} Sem${isActive ? ' (Active)' : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newTerm) {
                if (newTerm != null) {
                  ref.read(selectedTermOverrideProvider.notifier).state = newTerm;
                }
              },
            ),
          ),
        );
      },
      loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
