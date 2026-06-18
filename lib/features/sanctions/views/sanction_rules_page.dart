import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import 'package:vouch_v2/shared/widgets/loading_overlay.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../core/permissions/app_permissions.dart';
import '../providers/sanction_provider.dart';

class SanctionRulesPage extends ConsumerStatefulWidget {
  const SanctionRulesPage({super.key});

  @override
  ConsumerState<SanctionRulesPage> createState() => _SanctionRulesPageState();
}

class _SanctionRulesPageState extends ConsumerState<SanctionRulesPage> {
  final _client = SupabaseConfig.client;
  bool _isSyncing = false;

  Future<List<Map<String, dynamic>>> _fetchRules() async {
    final workspace = ref.read(workspaceProvider);
    final org = workspace.selectedOrganization;
    final term = ref.read(activeTermProvider).value;

    if (org == null || term == null) return [];

    String? scopeId = org.campusId;
    if (org.type == 'faculty-based') {
      scopeId = org.facultyId;
    } else if (org.type == 'program-based') {
      scopeId = org.programId;
    }

    if (scopeId == null) return [];

    final response = await _client
        .from('sanction_rules')
        .select()
        .eq('scope_id', scopeId)
        .eq('academic_term_id', term.id)
        .order('min_absence', ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
  }

  String _formatScoreRange(dynamic min, dynamic max) {
    final double minVal = (min as num?)?.toDouble() ?? 0.0;
    final String minStr = minVal % 1 == 0 ? minVal.toInt().toString() : minVal.toString();

    if (max == null) {
      return '$minStr+ Sanction Score';
    }

    final double maxVal = (max as num).toDouble();
    if (minVal == maxVal) {
      return '$minStr Sanction Score';
    }

    final String maxStr = maxVal % 1 == 0 ? maxVal.toInt().toString() : maxVal.toString();
    return '$minStr - $maxStr Sanction Score';
  }

  void _showAddRuleDialog() {
    final minScoreController = TextEditingController();
    final maxScoreController = TextEditingController();
    final worthController = TextEditingController();
    final itemController = TextEditingController();
    String ruleType = 'single'; // 'single', 'range', 'above'

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Sanction Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rule Application Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textGrey)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: ruleType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'single', child: Text('Single Score (e.g. exactly 1)')),
                    DropdownMenuItem(value: 'range', child: Text('Score Range (e.g. 1 - 2)')),
                    DropdownMenuItem(value: 'above', child: Text('Score and Above (e.g. 3+)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        ruleType = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                if (ruleType == 'single') ...[
                  TextField(
                    controller: minScoreController,
                    decoration: const InputDecoration(
                      labelText: 'Sanction Score',
                      hintText: 'e.g. 1 or 1.5',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ] else if (ruleType == 'range') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minScoreController,
                          decoration: const InputDecoration(
                            labelText: 'Min Score',
                            hintText: 'e.g. 1',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextField(
                          controller: maxScoreController,
                          decoration: const InputDecoration(
                            labelText: 'Max Score',
                            hintText: 'e.g. 2',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                ] else if (ruleType == 'above') ...[
                  TextField(
                    controller: minScoreController,
                    decoration: const InputDecoration(
                      labelText: 'Threshold Score (And Above)',
                      hintText: 'e.g. 3',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: worthController,
                  decoration: const InputDecoration(
                    labelText: 'Monetary Worth (PHP) - Optional',
                    hintText: 'e.g. 100.00',
                    border: OutlineInputBorder(),
                    prefixText: '₱ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: itemController,
                  decoration: const InputDecoration(
                    labelText: 'Item/Donation Description',
                    hintText: 'e.g. Donate supplies / pay dues',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final workspace = ref.read(workspaceProvider);
                final org = workspace.selectedOrganization;
                final term = ref.read(activeTermProvider).value;
                final user = ref.read(userProfileProvider).value;

                if (org == null || term == null || user == null) return;
                if (minScoreController.text.isEmpty) return;
                if (ruleType == 'range' && maxScoreController.text.isEmpty) return;
                if (itemController.text.isEmpty) return;

                String? scopeId = org.campusId;
                String scopeType = 'Institutional';
                if (org.type == 'faculty-based') {
                  scopeId = org.facultyId;
                  scopeType = 'Faculty';
                } else if (org.type == 'program-based') {
                  scopeId = org.programId;
                  scopeType = 'Program';
                }

                final double? minVal = double.tryParse(minScoreController.text);
                if (minVal == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid sanction score')));
                  return;
                }

                double? maxVal;
                if (ruleType == 'single') {
                  maxVal = minVal;
                } else if (ruleType == 'range') {
                  maxVal = double.tryParse(maxScoreController.text);
                  if (maxVal == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid max score')));
                    return;
                  }
                  if (maxVal < minVal) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Max score cannot be less than min score')));
                    return;
                  }
                }

                double? worthVal;
                if (worthController.text.isNotEmpty) {
                  worthVal = double.tryParse(worthController.text);
                  if (worthVal == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid numeric worth value')));
                    return;
                  }
                }

                try {
                  await _client.from('sanction_rules').insert({
                    'scope_id': scopeId,
                    'scope_type': scopeType,
                    'academic_term_id': term.id,
                    'min_absence': minVal,
                    'max_absence': maxVal,
                    'required_value': worthVal,
                    'item_description': itemController.text,
                    'sanction_type': 'Donation',
                    'created_by_user_id': user.id,
                  });
                  if (mounted) {
                    setState(() {});
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Add Rule'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeRole = ref.watch(workspaceProvider).activeRole;
    final canManageRules = activeRole?.hasPermission(AppPermissions.createSanctionRules) ?? false;
    final canSync = activeRole?.hasPermission(AppPermissions.receiveSanctionItems) ?? false;

    return LoadingOverlay(
      isLoading: _isSyncing,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sanction Rules', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Define items students must donate based on their sanction score ranges.', style: TextStyle(color: AppColors.textGrey)),
                  ],
                ),
                Row(
                  children: [
                    if (canSync)
                      OutlinedButton.icon(
                        onPressed: () async {
                          final workspace = ref.read(workspaceProvider);
                          final org = workspace.selectedOrganization;
                          final term = ref.read(activeTermProvider).value;
                          if (org == null || term == null) return;

                          setState(() => _isSyncing = true);
                          try {
                            String? scopeId = org.campusId;
                            String scopeType = 'Institutional';
                            if (org.type == 'faculty-based') {
                              scopeId = org.facultyId;
                              scopeType = 'Faculty';
                            } else if (org.type == 'program-based') {
                              scopeId = org.programId;
                              scopeType = 'Program';
                            }
                            
                            await ref.read(sanctionRepositoryProvider).generateSanctionsForTerm(term.id, scopeId!, scopeType);
                            ref.invalidate(workspaceSanctionsProvider);
                            ref.invalidate(mySanctionsProvider);
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sanction records synchronized successfully.')));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error syncing: $e')));
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isSyncing = false);
                            }
                          }
                        },
                        icon: const Icon(Icons.sync_rounded),
                        label: const Text('Sync Sanctions'),
                      ),
                    if (canManageRules) ...[
                      const SizedBox(width: AppSpacing.md),
                      FilledButton.icon(
                        onPressed: _showAddRuleDialog,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Rule'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchRules(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: FlickrLoader());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final rules = snapshot.data ?? [];
                  if (rules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rule_folder_rounded, size: 64, color: AppColors.textGrey.withOpacity(0.2)),
                          const SizedBox(height: AppSpacing.md),
                          const Text('No sanction rules defined yet.', style: TextStyle(color: AppColors.textGrey)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: rules.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.rule_rounded, color: AppColors.primary),
                          ),
                          title: Text(_formatScoreRange(rule['min_absence'], rule['max_absence']), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rule['item_description'], style: AppTextStyles.bodyMedium),
                                if (rule['required_value'] != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Worth: ₱${(rule['required_value'] as num).toStringAsFixed(2)}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing: canManageRules ? IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                            onPressed: () async {
                              await _client.from('sanction_rules').delete().eq('id', rule['id']);
                              setState(() {});
                            },
                          ) : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
