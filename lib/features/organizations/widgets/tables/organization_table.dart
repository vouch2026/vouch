import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routes/route_names.dart';
import '../../models/organization_model.dart';
import '../../controllers/organization_controller.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../faculties/models/faculty_model.dart';
import '../../../programs/models/program_model.dart';

class OrganizationTable extends ConsumerWidget {
  final List<OrganizationModel> organizations;
  final List<FacultyModel> faculties;
  final List<ProgramModel> programs;
  final bool isSelectionMode;
  final Set<String> selectedOrgIds;
  final Function(String orgId, bool? selected)? onSelectChanged;
  final Function(bool? selected)? onSelectAll;

  const OrganizationTable({
    super.key,
    required this.organizations,
    required this.faculties,
    required this.programs,
    this.isSelectionMode = false,
    required this.selectedOrgIds,
    this.onSelectChanged,
    this.onSelectAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileCards(context, organizations);
        }
        return _buildDataTable(context, ref, organizations, isSuperAdmin);
      },
    );
  }

  Widget _buildDataTable(BuildContext context, WidgetRef ref, List<OrganizationModel> orgs, bool isSuperAdmin) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        showCheckboxColumn: isSuperAdmin && isSelectionMode,
        onSelectAll: (selected) {
          onSelectAll?.call(selected);
        },
        headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.04)),
        dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return AppColors.primary.withValues(alpha: 0.02);
          }
          return null;
        }),
        columnSpacing: 20,
        horizontalMargin: 16,
        headingRowHeight: 48,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 48,
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
          verticalInside: BorderSide(color: Colors.grey.shade100, width: 0.5),
        ),
        columns: [
          DataColumn(
            label: Text(
              'Organization',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Organization Type',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Faculty',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Program',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Adviser',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Members',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
          if (isSuperAdmin)
            DataColumn(
              label: Text(
                'Actions',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
        rows: orgs.map((org) {
          Color typeColor;
          String typeText;
          switch (org.type) {
            case 'campus-based':
              typeColor = Colors.blue;
              typeText = 'Institutional';
              break;
            case 'faculty-based':
              typeColor = Colors.orange;
              typeText = 'Faculty-Based';
              break;
            case 'program-based':
              typeColor = Colors.purple;
              typeText = 'Program-Based';
              break;
            default:
              typeColor = Colors.grey;
              typeText = org.type;
          }

          FacultyModel? matchedFaculty;
          try {
            matchedFaculty = faculties.firstWhere((f) => f.id == org.facultyId);
          } catch (_) {
            matchedFaculty = null;
          }
          final facultyDisplay = matchedFaculty != null ? matchedFaculty.code : 'N/A';

          ProgramModel? matchedProgram;
          try {
            matchedProgram = programs.firstWhere((p) => p.id == org.programId);
          } catch (_) {
            matchedProgram = null;
          }
          final programDisplay = matchedProgram != null ? matchedProgram.code : 'N/A';

          return DataRow(
            selected: isSuperAdmin && isSelectionMode && selectedOrgIds.contains(org.id),
            onSelectChanged: isSuperAdmin && isSelectionMode
                ? (selected) => onSelectChanged?.call(org.id, selected)
                : null,
            cells: [
              DataCell(
                InkWell(
                  onTap: isSelectionMode
                      ? null
                      : () {
                          context.pushNamed(
                            RouteNames.organizationDetails,
                            pathParameters: {'id': org.id},
                          );
                        },
                  child: Row(
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
                                  org.code.isNotEmpty ? org.code[0] : 'O', 
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
                          Text(
                            org.name, 
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            org.code, 
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    typeText,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  facultyDisplay,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                ),
              ),
              DataCell(
                Text(
                  programDisplay,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                ),
              ),
              DataCell(
                Text(
                  org.adviserName ?? 'Not Assigned', 
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                ),
              ),
              DataCell(
                Text(
                  '${org.memberCount}', 
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                ),
              ),
              DataCell(
                _StatusBadge(status: org.status),
              ),
              if (isSuperAdmin)
                DataCell(
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    offset: const Offset(0, 45),
                    elevation: 6,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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

                        if (confirmed == true) {
                          final success = await ref.read(organizationControllerProvider.notifier).deleteOrganization(org.id);
                          
                          if (context.mounted) {
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
                      const PopupMenuItem(value: 'view', child: Text('View Details', style: TextStyle(fontSize: 13))),
                      const PopupMenuItem(value: 'edit', child: Text('Edit Organization', style: TextStyle(fontSize: 13))),
                      const PopupMenuItem(value: 'members', child: Text('Manage Members', style: TextStyle(fontSize: 13))),
                      const PopupMenuItem(value: 'deactivate', child: Text('Deactivate', style: TextStyle(fontSize: 13))),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete', 
                        child: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileCards(BuildContext context, List<OrganizationModel> orgs) {
    return Column(
      children: orgs.map((org) => Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: isSelectionMode
              ? Checkbox(
                  value: selectedOrgIds.contains(org.id),
                  onChanged: (val) => onSelectChanged?.call(org.id, val),
                )
              : CircleAvatar(
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
                          errorBuilder: (context, error, stackTrace) => Text(org.code.isNotEmpty ? org.code[0] : 'O'),
                        ),
                      ) 
                    : null,
                ),
          title: Text(org.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
          subtitle: Text('${org.memberCount} members', style: GoogleFonts.poppins(fontSize: 11)),
          trailing: _StatusBadge(status: org.status),
          onTap: () {
            if (isSelectionMode) {
              onSelectChanged?.call(org.id, !selectedOrgIds.contains(org.id));
            } else {
              context.pushNamed(
                RouteNames.organizationDetails,
                pathParameters: {'id': org.id},
              );
            }
          },
        ),
      )).toList(),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
