import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/events/providers/event_provider.dart';
import '../../features/finance/providers/finance_provider.dart';

/// Mandatory vs voluntary badge for the CURRENT user.
///
/// Contract (matches activity cards + sanctions):
/// - parent not mandatory -> no badge (same as today).
/// - legacy (no rows in either target table) or user covered (listed or in
///   a targeted scope unit) -> amber MANDATORY.
/// - targeted parent where the user is NOT covered -> grey
///   "VOLUNTARY FOR YOU".
/// - loading/error -> MANDATORY (fail-closed: never tell an obligated
///   member they are free while resolving).
class ObligationBadge extends ConsumerWidget {
  final String parentId;
  final bool isMandatory;

  /// 'event' or 'fee'.
  final String kind;

  const ObligationBadge.event({
    super.key,
    required this.parentId,
    required this.isMandatory,
  }) : kind = 'event';

  const ObligationBadge.fee({
    super.key,
    required this.parentId,
    required this.isMandatory,
  }) : kind = 'fee';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isMandatory) return const SizedBox.shrink();

    final ruleAsync = kind == 'event'
        ? ref.watch(eventObligationProvider(parentId))
        : ref.watch(feeObligationProvider(parentId));
    final me = ref.watch(userProfileProvider).valueOrNull;

    final obligated = ruleAsync.maybeWhen(
      data: (rule) => rule.covers(
        userId: me?.id,
        campusId: me?.campusId,
        facultyId: me?.facultyId,
        programId: me?.programId,
        yearLevel: me?.yearLevel,
      ),
      orElse: () => true,
    );

    if (obligated) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'MANDATORY',
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade300),
      ),
      child: Text(
        'VOLUNTARY FOR YOU',
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.blueGrey.shade700,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
