import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routes/route_paths.dart';
import '../models/comselec_model.dart';
import '../providers/comselec_provider.dart';
import '../controllers/comselec_controller.dart';

class ComselecTable extends ConsumerStatefulWidget {
  const ComselecTable({super.key});

  @override
  ConsumerState<ComselecTable> createState() => _ComselecTableState();
}

class _ComselecTableState extends ConsumerState<ComselecTable> {
  String _searchQuery = '';
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final comselecsAsync = ref.watch(comselecsProvider);

    return comselecsAsync.when(
      data: (comselecs) {
        final filteredComselecs = comselecs.where((com) {
          final matchesSearch = com.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              com.code.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesStatus = _statusFilter == null || com.status == _statusFilter;
          return matchesSearch && matchesStatus;
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildMobileCards(filteredComselecs);
            }
            return _buildDataTable(filteredComselecs);
          },
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildDataTable(List<ComselecModel> comselecs) {
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
                DataColumn(label: Text('COMSELEC Branch')),
                DataColumn(label: Text('Campus')),
                DataColumn(label: Text('Voters')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: comselecs.map((com) => DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: com.logoUrl != null ? NetworkImage(com.logoUrl!) : null,
                          child: com.logoUrl == null 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/logos/vouch.webp',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Text(
                                    com.code[0], 
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
                            Text(com.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            Text(com.code, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      context.push(RoutePaths.comselecDashboard);
                    },
                  ),
                  DataCell(Text(com.campusName ?? 'Not Assigned', style: AppTextStyles.bodySmall)),
                  DataCell(Text('${com.memberCount}', style: AppTextStyles.bodySmall)),
                  DataCell(_StatusBadge(status: com.status)),
                  DataCell(PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    onSelected: (value) async {
                      if (value == 'view') {
                        context.push(RoutePaths.comselecDashboard);
                      } else if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete COMSELEC Branch'),
                            content: Text('Are you sure you want to delete ${com.name}? This action cannot be undone.'),
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
                          final success = await ref.read(comselecControllerProvider.notifier).deleteComselec(com.id);
                          
                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('COMSELEC branch deleted successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              final error = ref.read(comselecControllerProvider).error;
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
                      const PopupMenuItem(value: 'view', child: Text('Manage Elections')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit Settings')),
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

  Widget _buildMobileCards(List<ComselecModel> comselecs) {
    return Column(
      children: [
        _buildFilters(),
        const SizedBox(height: AppSpacing.md),
        ...comselecs.map((com) => Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: com.logoUrl != null ? NetworkImage(com.logoUrl!) : null,
              child: com.logoUrl == null 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logos/vouch.webp',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Text(com.code[0]),
                    ),
                  ) 
                : null,
            ),
            title: Text(com.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('${com.memberCount} voters'),
            trailing: _StatusBadge(status: com.status),
            onTap: () {
              context.push(RoutePaths.comselecDashboard);
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
              hintText: 'Search COMSELECs...',
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
          items: ['active', 'inactive'],
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
