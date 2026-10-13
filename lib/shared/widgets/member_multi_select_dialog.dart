import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/schools/providers/school_scope_provider.dart';

/// Multi-select member picker: search + select-all-in-scope + checkboxes.
///
/// Pattern follows AssignOfficerDialog (search TextField + ListView rows with
/// CircleAvatar + name + schoolId•email + check indicator), extended to
/// multi-select. Returns the confirmed set of user ids, or null on cancel.
///
/// Visibility vs obligation contract: everyone in [scopeType]/[scopeId] can
/// SEE the event/fee; only the returned ids are OBLIGATED (must attend/pay,
/// counts toward clearance).
class MemberMultiSelectDialog extends ConsumerStatefulWidget {
  final String scopeType;
  final String scopeId;
  final Set<String> initiallySelected;
  final String title;
  final String obligationLabel;

  const MemberMultiSelectDialog({
    super.key,
    required this.scopeType,
    required this.scopeId,
    this.initiallySelected = const {},
    this.title = 'Select Members',
    this.obligationLabel = 'obligated',
  });

  @override
  ConsumerState<MemberMultiSelectDialog> createState() =>
      _MemberMultiSelectDialogState();
}

class _MemberMultiSelectDialogState
    extends ConsumerState<MemberMultiSelectDialog> {
  late Set<String> _selected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initiallySelected);
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersInScopeProvider(
        (scopeType: widget.scopeType, scopeId: widget.scopeId)));

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Container(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration:
            const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            const Icon(Icons.group_add_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    'Only selected members are ${widget.obligationLabel}. Everyone in scope can still view it.',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search name, ID, or email',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
            ),
            const SizedBox(height: AppSpacing.sm),
            usersAsync.when(
              data: (users) {
                final filtered = users.where((u) {
                  if (_searchQuery.isEmpty) return true;
                  return u.fullName.toLowerCase().contains(_searchQuery) ||
                      u.schoolId.toLowerCase().contains(_searchQuery) ||
                      u.email.toLowerCase().contains(_searchQuery);
                }).toList();
                final allFilteredSelected = filtered.isNotEmpty &&
                    filtered.every((u) => _selected.contains(u.id));

                return Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                        value: allFilteredSelected,
                        tristate: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        title: Text(
                          _selected.isEmpty
                              ? 'Select all in scope (${filtered.length})'
                              : '${_selected.length} selected',
                          style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        onChanged: (_) {
                          setState(() {
                            if (allFilteredSelected) {
                              for (final u in filtered) {
                                _selected.remove(u.id);
                              }
                            } else {
                              for (final u in filtered) {
                                if (u.id != null) _selected.add(u.id!);
                              }
                            }
                          });
                        },
                      ),
                      const Divider(height: 1),
                      Flexible(
                        child: filtered.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Text(
                                  users.isEmpty
                                      ? 'No members found in this scope.'
                                      : 'No members match "$_searchQuery".',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textGrey),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: filtered.length,
                                itemBuilder: (context, i) {
                                  final u = filtered[i];
                                  final isSelected =
                                      _selected.contains(u.id);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    dense: true,
                                    secondary: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      child: Text(
                                        u.fullName.isNotEmpty
                                            ? u.fullName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary),
                                      ),
                                    ),
                                    title: Text(u.fullName,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                                fontWeight: FontWeight.w600)),
                                    subtitle: Text(
                                      '${u.schoolId} • ${u.email}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.textGrey),
                                    ),
                                    onChanged: (_) {
                                      setState(() {
                                        if (u.id == null) return;
                                        if (isSelected) {
                                          _selected.remove(u.id);
                                        } else {
                                          _selected.add(u.id!);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Text('Could not load members: $e'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selected.isEmpty
              ? null
              : () {
                  setState(_selected.clear);
                },
          child: const Text('Clear'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text('Confirm (${_selected.length})'),
        ),
      ],
    );
  }
}
