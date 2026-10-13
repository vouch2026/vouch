import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/academic_structure/providers/term_provider.dart';

/// Global read-only banner shown on every [DashboardLayout] page while the
/// user views a past AY|SEM term. Tapping "Back to active" clears the
/// selection (follows the active term again).
class PastTermBanner extends ConsumerWidget {
  const PastTermBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPastAsync = ref.watch(isViewingPastProvider);
    final viewingAsync = ref.watch(viewingTermProvider);

    final isPast = isPastAsync.valueOrNull ?? false;
    if (!isPast) return const SizedBox.shrink();

    final viewing = viewingAsync.valueOrNull;
    final label = viewing == null
        ? 'Viewing past term — read-only'
        : 'Viewing AY ${viewing.academicYear} — ${viewing.semester} (read-only)';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              ref.read(selectedTermIdProvider.notifier).state = null;
              await persistSelectedTerm(null);
              ref.invalidate(viewingTermProvider);
              ref.invalidate(isViewingPastProvider);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            child: const Text('Back to active',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
