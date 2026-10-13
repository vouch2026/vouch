import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/term_provider.dart';
import '../models/academic_term_model.dart';

/// Compact AY|SEM selector pinned below the VouchEDU logo in the sidebar.
///
/// Reads [viewingTermProvider] (defaults to active term) and writes
/// [selectedTermIdProvider] + Hive persistence. When a past term is selected,
/// the card turns amber as a persistent "viewing history" cue; content pages
/// additionally enforce view-only mode via [isViewingPastProvider].
class SidebarTermSelector extends ConsumerWidget {
  const SidebarTermSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewingAsync = ref.watch(viewingTermProvider);
    final isPastAsync = ref.watch(isViewingPastProvider);

    final isPast = isPastAsync.valueOrNull ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openTermPicker(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isPast
                  ? AppColors.accent.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPast
                    ? AppColors.accent.withValues(alpha: 0.4)
                    : AppColors.primary.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isPast
                        ? AppColors.accent.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: isPast ? Colors.grey.shade800 : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: viewingAsync.when(
                    data: (term) {
                      if (term == null) {
                        return Text(
                          'No term',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'AY ${term.academicYear}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${term.semester} Sem',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _TermBadge(isPast: isPast, isActive: term.isActive),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => Text(
                      'Loading term…',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    error: (_, __) => Text(
                      'Term unavailable',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openTermPicker(BuildContext context, WidgetRef ref) async {
    // Gated list: students never see terms that ended before they registered.
    final terms = await ref.read(availableTermsProvider.future).catchError((_) => <AcademicTermModel>[]);
    final viewing = await ref.read(viewingTermProvider.future);
    if (!context.mounted) return;

    final selected = await showDialog<AcademicTermModel>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'School Year & Semester',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 360,
            child: terms.isEmpty
                ? const Text(
                    'No school years available. Terms that ended before you registered are hidden.')
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: terms.map((term) {
                        final isCurrent = viewing?.id == term.id;
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          selected: isCurrent,
                          selectedTileColor:
                              AppColors.primary.withValues(alpha: 0.08),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: term.isActive
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              term.isActive
                                  ? Icons.event_available_rounded
                                  : Icons.history_rounded,
                              size: 18,
                              color: term.isActive
                                  ? AppColors.primary
                                  : Colors.grey.shade700,
                            ),
                          ),
                          title: Text(
                            'AY ${term.academicYear} — ${term.semester}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: term.isActive
                              ? Text(
                                  'Active term',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : Text(
                                  'Past term — view only',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                          trailing: isCurrent
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => Navigator.pop(dialogContext, term),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    ref.read(selectedTermIdProvider.notifier).state = selected.id;
    await persistSelectedTerm(selected.id);

    if (context.mounted && !selected.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Viewing AY ${selected.academicYear} — ${selected.semester} (read-only)',
          ),
          backgroundColor: Colors.amber.shade800,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class _TermBadge extends StatelessWidget {
  final bool isPast;
  final bool isActive;

  const _TermBadge({required this.isPast, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final label = isPast ? 'PAST' : 'ACTIVE';
    final bg = isPast ? Colors.amber.shade700 : Colors.green.shade600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 9,
        ),
      ),
    );
  }
}
