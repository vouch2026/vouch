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
import '../repositories/sanction_repository.dart';
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
        .order('absence_count', ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
  }

  void _showAddRuleDialog() {
    final absenceController = TextEditingController();
    final itemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sanction Rule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: absenceController,
              decoration: const InputDecoration(labelText: 'Absence Count'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: 'Item/Donation Description',
                hintText: 'e.g. Donate 50 PHP worth of supplies',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final workspace = ref.read(workspaceProvider);
              final org = workspace.selectedOrganization;
              final term = ref.read(activeTermProvider).value;
              final user = ref.read(userProfileProvider).value;

              if (org == null || term == null || user == null) return;

              String? scopeId = org.campusId;
              String scopeType = 'Institutional';
              if (org.type == 'faculty-based') {
                scopeId = org.facultyId;
                scopeType = 'Faculty';
              } else if (org.type == 'program-based') {
                scopeId = org.programId;
                scopeType = 'Program';
              }

              try {
                await _client.from('sanction_rules').insert({
                  'scope_id': scopeId,
                  'scope_type': scopeType,
                  'academic_term_id': term.id,
                  'absence_count': int.parse(absenceController.text),
                  'item_description': itemController.text,
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
                    Text('Absence Sanctions', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Define items students must donate based on their number of absences.', style: TextStyle(color: AppColors.textGrey)),
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
                            child: Text(rule['absence_count'].toString(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                          title: Text('${rule['absence_count']} Absences', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(rule['item_description']),
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
