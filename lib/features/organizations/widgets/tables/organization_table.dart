import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/organization_model.dart';
import '../../providers/organization_provider.dart';

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
            return _buildDataTable(filteredOrgs);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildDataTable(List<OrganizationModel> orgs) {
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
              columns: const [
                DataColumn(label: Text('Organization')),
                DataColumn(label: Text('Adviser')),
                DataColumn(label: Text('Members')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: orgs.map((org) => DataRow(
                cells: [
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
                        child: org.logoUrl == null ? Text(org.code[0], style: const TextStyle(fontSize: 12)) : null,
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
                  )),
                  DataCell(Text(org.adviserName ?? 'Not Assigned', style: AppTextStyles.bodySmall)),
                  DataCell(Text('${org.memberCount}', style: AppTextStyles.bodySmall)),
                  DataCell(_StatusBadge(status: org.status)),
                  DataCell(PopupMenuButton(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit Organization')),
                      const PopupMenuItem(value: 'members', child: Text('Manage Members')),
                      const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
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
              backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
              child: org.logoUrl == null ? Text(org.code[0]) : null,
            ),
            title: Text(org.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('${org.memberCount} members'),
            trailing: _StatusBadge(status: org.status),
            onTap: () {},
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
