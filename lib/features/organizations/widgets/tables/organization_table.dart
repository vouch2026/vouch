import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routes/route_names.dart';
import '../../models/organization_model.dart';
import '../../providers/organization_provider.dart';
import '../../controllers/organization_controller.dart';
import '../../providers/workspace_provider.dart';
import '../../../../core/utils/role_mapper.dart';
import '../../../auth/providers/auth_provider.dart';

class OrganizationTable extends ConsumerStatefulWidget {
  const OrganizationTable({super.key});

  @override
  ConsumerState<OrganizationTable> createState() => _OrganizationTableState();
}

class _OrganizationTableState extends ConsumerState<OrganizationTable> {
  String _searchQuery = '';
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final organizationsAsync = ref.watch(organizationsProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';

    return organizationsAsync.when(
      data: (orgs) {
        final filteredOrgs = orgs.where((org) {
          final matchesSearch = org.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              org.code.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesStatus = _statusFilter == null || org.status == _statusFilter;
          return matchesSearch && matchesStatus;
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildMobileCards(filteredOrgs);
            }
            return _buildDataTable(filteredOrgs, isSuperAdmin);
          },
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildDataTable(List<OrganizationModel> orgs, bool isSuperAdmin) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        _buildFilters(),
        const SizedBox(height: AppSpacing.md),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
              columns: [
                const DataColumn(label: Text('Organization')),
                const DataColumn(label: Text('Adviser')),
                const DataColumn(label: Text('Members')),
                const DataColumn(label: Text('Status')),
                if (isSuperAdmin) const DataColumn(label: Text('Actions')),
              ],
              rows: orgs.map((org) => DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
                          child: org.logoUrl == null 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/logos/vouch.png',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Text(
                                    org.code[0], 
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ) 
                            : null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(org.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            Text(org.code, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      context.pushNamed(
                        RouteNames.organizationDetails,
                        pathParameters: {'id': org.id},
                      );
                    },
                  ),
                  DataCell(Text(org.adviserName ?? 'Not Assigned', style: AppTextStyles.bodySmall)),
                  DataCell(Text('${org.memberCount}', style: AppTextStyles.bodySmall)),
                  DataCell(_StatusBadge(status: org.status)),
                  if (isSuperAdmin)
                    DataCell(PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                      onSelected: (value) async {
                        if (value == 'view') {
                          context.pushNamed(
                            RouteNames.organizationDetails,
                            pathParameters: {'id': org.id},
                          );
                        } else if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Organization'),
                              content: Text('Are you sure you want to delete ${org.name}? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && mounted) {
                            // Show a loading snackbar or indicator if needed, 
                            // but the controller will set its state to loading.
                            final success = await ref.read(organizationControllerProvider.notifier).deleteOrganization(org.id);
                            
                            if (mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Organization deleted successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                final error = ref.read(organizationControllerProvider).error;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to delete: ${error?.toString() ?? 'Unknown error'}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'view', child: Text('View Details')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit Organization')),
                        const PopupMenuItem(value: 'members', child: Text('Manage Members')),
                        const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete', 
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    )),
                ],
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCards(List<OrganizationModel> orgs) {
    return Column(
      children: [
        _buildFilters(),
        const SizedBox(height: AppSpacing.md),
        ...orgs.map((org) => Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
              child: org.logoUrl == null 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logos/vouch.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Text(org.code[0]),
                    ),
                  ) 
                : null,
            ),
            title: Text(org.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('${org.memberCount} members'),
            trailing: _StatusBadge(status: org.status),
            onTap: () {
              context.pushNamed(
                RouteNames.organizationDetails,
                pathParameters: {'id': org.id},
              );
            },
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search organizations...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildFilterDropdown(
          hint: 'Status',
          value: _statusFilter,
          items: ['active', 'inactive', 'pending', 'suspended'],
          onChanged: (val) => setState(() => _statusFilter = val),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: AppTextStyles.bodySmall),
          items: [
            DropdownMenuItem(value: null, child: Text('All $hint')),
            ...items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase(), style: AppTextStyles.bodySmall))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.grey;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
