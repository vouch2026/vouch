import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:excel/excel.dart' as excel_lib;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/utils/file_saver_helper.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../providers/workspace_provider.dart';
import '../../../core/utils/role_mapper.dart';
import '../providers/organization_provider.dart';
import '../models/organization_model.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';
import '../../campuses/models/campus_model.dart';
import '../../faculties/models/faculty_model.dart';
import '../../programs/models/program_model.dart';
import '../widgets/tables/organization_table.dart';
import '../widgets/modals/organization_creation_modal.dart';
import '../widgets/details/assign_adviser_dialog.dart';
import '../widgets/academic_hierarchy_org_filter.dart';

class OrganizationsPage extends ConsumerStatefulWidget {
  const OrganizationsPage({super.key});

  @override
  ConsumerState<OrganizationsPage> createState() => _OrganizationsPageState();
}

class _OrganizationsPageState extends ConsumerState<OrganizationsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedType = 'All';
  
  String _selectedCampus = 'All';
  String _selectedFaculty = 'All';
  String _selectedProgram = 'All';
  
  bool _isAcademicHierarchyView = false;
  Set<String> _selectedOrgIds = {};
  bool _isSelectionMode = false;
  int _currentPage = 0;
  int _rowsPerPage = 10;
  String _prevStatus = 'All';
  String _prevType = 'All';
  String _prevCampus = 'All';
  String _prevFaculty = 'All';
  String _prevProgram = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 0;
    });
  }

  Future<void> _downloadExcelReport(List<OrganizationModel> orgs) async {
    try {
      final excel = excel_lib.Excel.createExcel();
      final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[defaultSheet];

      // Headers (Metadata)
      sheet.appendRow([
        excel_lib.TextCellValue('Report Type'),
        excel_lib.TextCellValue('Organizations Directory Report'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Export Date'),
        excel_lib.TextCellValue(DateTime.now().toLocal().toString().substring(0, 19)),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Total Records'),
        excel_lib.TextCellValue('${orgs.length}'),
      ]);
      sheet.appendRow([]); // space row

      // Table Column Headers
      sheet.appendRow([
        excel_lib.TextCellValue('Organization Name'),
        excel_lib.TextCellValue('Code'),
        excel_lib.TextCellValue('Type'),
        excel_lib.TextCellValue('Adviser'),
        excel_lib.TextCellValue('Members Count'),
        excel_lib.TextCellValue('Status'),
      ]);

      // Data Rows
      for (final org in orgs) {
        sheet.appendRow([
          excel_lib.TextCellValue(org.name),
          excel_lib.TextCellValue(org.code),
          excel_lib.TextCellValue(org.type.toUpperCase()),
          excel_lib.TextCellValue(org.adviserName ?? 'Not Assigned'),
          excel_lib.TextCellValue('${org.memberCount}'),
          excel_lib.TextCellValue(org.status.toUpperCase()),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception("Failed to encode excel");

      final String fileName = "Organizations_Directory_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      
      final isSuccess = await FileSaverUtil.saveFile(Uint8List.fromList(bytes), fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSuccess ? 'Organizations report downloaded successfully!' : 'Failed to download report.'),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAnalyticsSection(List<OrganizationModel> orgs) {
    final total = orgs.length;
    final campusCount = orgs.where((o) => o.type == 'campus-based').length;
    final facultyCount = orgs.where((o) => o.type == 'faculty-based').length;
    final programCount = orgs.where((o) => o.type == 'program-based').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;
          final double cardSpacing = 12.0;
          final itemWidth = isSmall 
              ? (constraints.maxWidth - cardSpacing) / 2 
              : (constraints.maxWidth - (cardSpacing * 3)) / 4;
          
          Widget buildGridRow(List<Widget> children) {
            return Wrap(
              spacing: cardSpacing,
              runSpacing: cardSpacing,
              children: children.map((c) => SizedBox(width: itemWidth, child: c)).toList(),
            );
          }

          return buildGridRow([
            _buildKpiCard(
              title: 'Organizations',
              value: '$total',
              color: Colors.blue,
              icon: LucideIcons.building,
              isSelected: _selectedType == 'All',
              onTap: () => setState(() => _selectedType = 'All'),
            ),
            _buildKpiCard(
              title: 'Institutional',
              value: '$campusCount',
              color: Colors.green,
              icon: LucideIcons.building2,
              isSelected: _selectedType == 'campus-based',
              onTap: () => setState(() => _selectedType = _selectedType == 'campus-based' ? 'All' : 'campus-based'),
            ),
            _buildKpiCard(
              title: 'Faculty-Based',
              value: '$facultyCount',
              color: Colors.orange,
              icon: LucideIcons.landmark,
              isSelected: _selectedType == 'faculty-based',
              onTap: () => setState(() => _selectedType = _selectedType == 'faculty-based' ? 'All' : 'faculty-based'),
            ),
            _buildKpiCard(
              title: 'Program-Based',
              value: '$programCount',
              color: Colors.purple,
              icon: LucideIcons.graduationCap,
              isSelected: _selectedType == 'program-based',
              onTap: () => setState(() => _selectedType = _selectedType == 'program-based' ? 'All' : 'program-based'),
            ),
          ]);
        },
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.06 : 0.02),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    IconData? trailingIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary 
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            Icon(
              trailingIcon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 1. Type Dropdown Filter
          PopupMenuButton<String>(
            onSelected: (String type) {
              setState(() {
                _selectedType = type;
              });
            },
            offset: const Offset(0, 45),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (BuildContext context) {
              final types = [
                {'label': 'All Types', 'value': 'All'},
                {'label': 'Institutional', 'value': 'campus-based'},
                {'label': 'Faculty-Based', 'value': 'faculty-based'},
                {'label': 'Program-Based', 'value': 'program-based'},
              ];
              return types.map((typeOpt) {
                final isItemSelected = _selectedType == typeOpt['value'];
                return PopupMenuItem<String>(
                  value: typeOpt['value'],
                  height: 42,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          typeOpt['label']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isItemSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isItemSelected ? AppColors.primary : Colors.black87,
                          ),
                        ),
                      ),
                      if (isItemSelected)
                        const Icon(LucideIcons.checkCircle, size: 16, color: AppColors.primary),
                    ],
                  ),
                );
              }).toList();
            },
            child: _buildFilterChip(
              label: _getTypeFilterLabel(_selectedType),
              isSelected: _selectedType != 'All',
              trailingIcon: LucideIcons.chevronDown,
            ),
          ),
          const SizedBox(width: 8),

          // 2. Status Dropdown Filter
          PopupMenuButton<String>(
            onSelected: (String status) {
              setState(() {
                _selectedStatus = status;
              });
            },
            offset: const Offset(0, 45),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (BuildContext context) {
              final statuses = [
                {'label': 'All Statuses', 'value': 'All'},
                {'label': 'Active', 'value': 'active'},
                {'label': 'Inactive', 'value': 'inactive'},
                {'label': 'Pending', 'value': 'pending'},
                {'label': 'Suspended', 'value': 'suspended'},
              ];
              return statuses.map((statusOpt) {
                final isItemSelected = _selectedStatus == statusOpt['value'];
                return PopupMenuItem<String>(
                  value: statusOpt['value'],
                  height: 42,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          statusOpt['label']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isItemSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isItemSelected ? AppColors.primary : Colors.black87,
                          ),
                        ),
                      ),
                      if (isItemSelected)
                        const Icon(LucideIcons.checkCircle, size: 16, color: AppColors.primary),
                    ],
                  ),
                );
              }).toList();
            },
            child: _buildFilterChip(
              label: _getStatusFilterLabel(_selectedStatus),
              isSelected: _selectedStatus != 'All',
              trailingIcon: LucideIcons.chevronDown,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeFilterLabel(String type) {
    if (type == 'All') return 'Type: All';
    if (type == 'campus-based') return 'Institutional';
    if (type == 'faculty-based') return 'Faculty-Based';
    if (type == 'program-based') return 'Program-Based';
    return type;
  }

  String _getStatusFilterLabel(String status) {
    if (status == 'All') return 'Status: All';
    return 'Status: ${status.toUpperCase()}';
  }

  Widget _buildBulkActionsMenu(List<OrganizationModel> filteredOrgs) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(Icons.more_vert_rounded, color: AppColors.primary, size: 20),
      ),
      tooltip: 'Bulk Actions',
      onSelected: (action) => _handleBulkAction(action, filteredOrgs),
      offset: const Offset(0, 45),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      itemBuilder: (context) => [
        if (!_isSelectionMode)
          PopupMenuItem(
            value: 'enable_selection',
            child: Row(
              children: [
                const Icon(LucideIcons.checkSquare, size: 16, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'Enable Selection',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        else
          PopupMenuItem(
            value: 'disable_selection',
            child: Row(
              children: [
                const Icon(LucideIcons.xSquare, size: 16, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  'Cancel Selection',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'select_all',
          child: Row(
            children: [
              const Icon(LucideIcons.checkSquare, size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'Select All',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        if (_isSelectionMode) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'activate',
            child: Row(
              children: [
                const Icon(
                  LucideIcons.playCircle,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                Text(
                  'Activate Selected${_selectedOrgIds.isNotEmpty ? " (${_selectedOrgIds.length})" : ""}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'deactivate',
            child: Row(
              children: [
                const Icon(
                  LucideIcons.stopCircle,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                Text(
                  'Deactivate Selected${_selectedOrgIds.isNotEmpty ? " (${_selectedOrgIds.length})" : ""}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: Colors.red,
                ),
                const SizedBox(width: 10),
                Text(
                  'Delete Selected${_selectedOrgIds.isNotEmpty ? " (${_selectedOrgIds.length})" : ""}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleBulkAction(String action, List<OrganizationModel> filteredOrgs) async {
    if (action == 'enable_selection') {
      setState(() {
        _isSelectionMode = true;
      });
      return;
    }
    if (action == 'disable_selection') {
      setState(() {
        _isSelectionMode = false;
        _selectedOrgIds.clear();
      });
      return;
    }
    if (action == 'select_all') {
      setState(() {
        _isSelectionMode = true;
        _selectedOrgIds = filteredOrgs
            .map((o) => o.id)
            .toSet();
      });
      return;
    }

    if (action == 'activate' || action == 'deactivate' || action == 'delete') {
      if (_selectedOrgIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select at least one organization first.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          action == 'delete'
              ? 'Delete Organizations'
              : action == 'activate'
                  ? 'Activate Organizations'
                  : 'Deactivate Organizations',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          action == 'delete'
              ? 'Are you sure you want to delete ${_selectedOrgIds.length} selected organization(s)? This action is permanent and cannot be undone.'
              : 'Are you sure you want to change the status of ${_selectedOrgIds.length} selected organization(s)?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: action == 'delete' ? Colors.red : AppColors.primary,
            ),
            child: Text('Confirm', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final client = SupabaseConfig.client;
      final ids = _selectedOrgIds.toList();

      if (action == 'delete') {
        await client.from('organizations').delete().inFilter('id', ids);
      } else if (action == 'activate') {
        await client.from('organizations').update({'status': 'active'}).inFilter('id', ids);
      } else if (action == 'deactivate') {
        await client.from('organizations').update({'status': 'inactive'}).inFilter('id', ids);
      }

      // Show success toast
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'delete'
                  ? 'Successfully deleted organizations'
                  : 'Successfully updated organization statuses',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Clear selections and refresh
      setState(() {
        _selectedOrgIds.clear();
        _isSelectionMode = false;
      });
      ref.invalidate(organizationsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bulk action failed: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prevStatus != _selectedStatus ||
        _prevType != _selectedType ||
        _prevCampus != _selectedCampus ||
        _prevFaculty != _selectedFaculty ||
        _prevProgram != _selectedProgram) {
      _prevStatus = _selectedStatus;
      _prevType = _selectedType;
      _prevCampus = _selectedCampus;
      _prevFaculty = _selectedFaculty;
      _prevProgram = _selectedProgram;
      _currentPage = 0;
    }

    final userProfile = ref.watch(userProfileProvider).value;
    final activeRole = ref.watch(workspaceProvider).activeRole;
    final isSuperAdmin = userProfile?.role == 'super_admin';

    bool isAuthorized = isSuperAdmin;
    if (!isAuthorized && activeRole != null) {
      final roleKey = RoleMapper.mapDbRoleToAppFormat(activeRole.roleName);
      if (roleKey == 'dean' || roleKey == 'program_head') {
        isAuthorized = true;
      }
    }

    if (!isAuthorized) {
      return const DashboardLayout(
        title: 'Organizations',
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 48, color: AppColors.error),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Access Denied',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'You do not have permission to view the organizations list.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    ref.listen<AsyncValue<UserModel?>>(userProfileProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        if (user.role == 'dean' && _selectedFaculty == 'All') {
          setState(() {
            _selectedFaculty = user.facultyId ?? 'All';
          });
        } else if (user.role == 'program_head' && _selectedProgram == 'All') {
          setState(() {
            _selectedProgram = user.programId ?? 'All';
          });
        }
      }
    });

    final organizationsAsync = ref.watch(organizationsProvider);
    final allOrgs = organizationsAsync.value ?? <OrganizationModel>[];

    final filteredOrgs = allOrgs.where((org) {
      final query = _searchController.text.toLowerCase();
      final matchesSearch = org.name.toLowerCase().contains(query) ||
          org.code.toLowerCase().contains(query);
      
      final matchesType = _selectedType == 'All' || org.type == _selectedType;
      final matchesStatus = _selectedStatus == 'All' || org.status.toLowerCase() == _selectedStatus.toLowerCase();

      final matchesCampus = _selectedCampus == 'All' || org.campusId == _selectedCampus;
      final matchesFaculty = _selectedFaculty == 'All' || org.facultyId == _selectedFaculty;
      final matchesProgram = _selectedProgram == 'All' || org.programId == _selectedProgram;

      return matchesSearch && matchesType && matchesStatus && matchesCampus && matchesFaculty && matchesProgram;
    }).toList();

    final totalItems = filteredOrgs.length;
    final maxPages = (totalItems / _rowsPerPage).ceil();
    final safePage = _currentPage >= maxPages ? (maxPages > 0 ? maxPages - 1 : 0) : _currentPage;
    final startIndex = safePage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > totalItems ? totalItems : (startIndex + _rowsPerPage);
    final paginatedOrgs = totalItems == 0 ? <OrganizationModel>[] : filteredOrgs.sublist(startIndex, endIndex);

    final campusesAsync = ref.watch(campusesProvider);
    final facultiesAsync = ref.watch(facultiesProvider);
    final programsAsync = ref.watch(programsProvider);

    final campuses = campusesAsync.valueOrNull ?? const <CampusModel>[];
    final faculties = facultiesAsync.valueOrNull ?? const <FacultyModel>[];
    final programs = programsAsync.valueOrNull ?? const <ProgramModel>[];

    final isMobile = MediaQuery.of(context).size.width < 768;

    return DashboardLayout(
      title: 'Organizations',
      child: RefreshIndicator(
        onRefresh: () async {
          try {
            await ref.refresh(organizationsProvider.future);
            await ref.refresh(campusesProvider.future);
            await ref.refresh(facultiesProvider.future);
            await ref.refresh(programsProvider.future);
          } catch (_) {}
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs / Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.business_center_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text(
                    'Organizations',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title Section with Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organization Management',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage all institutional, faculty, and program-based student organizations',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  if (isSuperAdmin) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const OrganizationCreationModal(),
                            );
                          },
                          icon: const Icon(Icons.add_business_rounded, size: 16),
                          label: Text(
                            'Create Org',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const AssignAdviserDialog(),
                            );
                          },
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                          label: Text(
                            'Assign Adviser',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Interactive KPI Cards Section
            organizationsAsync.when(
              data: (orgs) => _buildAnalyticsSection(orgs),
              loading: () => const Center(child: FlickrLoader()),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text('Failed to load organization statistics: $err'),
              ),
            ),
            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth >= 1024;

                Widget buildMainContentList() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Registered Organizations',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Academic Directory',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _isAcademicHierarchyView ? AppColors.primary : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Switch(
                                      value: _isAcademicHierarchyView,
                                      onChanged: (val) {
                                        setState(() {
                                          _isAcademicHierarchyView = val;
                                        });
                                      },
                                      activeThumbColor: AppColors.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    if (filteredOrgs.isNotEmpty) ...[
                                      FilledButton.icon(
                                        onPressed: () => _downloadExcelReport(filteredOrgs),
                                        icon: const Icon(LucideIcons.download, size: 16),
                                        label: Text(
                                          isMobile ? 'Export' : 'Download Excel',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.accent,
                                          foregroundColor: AppColors.primary,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
                                          ),
                                        ),
                                      ),
                                      if (isSuperAdmin) ...[
                                        const SizedBox(width: 8),
                                        _buildBulkActionsMenu(filteredOrgs),
                                      ],
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Unified Search bar
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search by organization name or code...',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                  prefixIcon: const Icon(LucideIcons.search, size: 20, color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: _buildFilterSection(),
                      ),
                      const SizedBox(height: 16),

                      // Main Organization Table
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: organizationsAsync.when(
                          data: (orgsList) {
                            if (filteredOrgs.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'No Organizations Found',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Try refining your search query or filter settings.',
                                      style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                OrganizationTable(
                                  organizations: paginatedOrgs,
                                  faculties: faculties,
                                  programs: programs,
                                  isSelectionMode: _isSelectionMode,
                                  selectedOrgIds: _selectedOrgIds,
                                  onSelectAll: (selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedOrgIds.addAll(paginatedOrgs.map((o) => o.id));
                                      } else {
                                        for (final org in paginatedOrgs) {
                                          _selectedOrgIds.remove(org.id);
                                        }
                                      }
                                    });
                                  },
                                  onSelectChanged: (orgId, selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedOrgIds.add(orgId);
                                      } else {
                                        _selectedOrgIds.remove(orgId);
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildPaginationFooter(totalItems, safePage, _rowsPerPage),
                              ],
                            );
                          },
                          loading: () => const Center(child: FlickrLoader()),
                          error: (error, stack) => Center(child: Text('Error: $error')),
                        ),
                      ),
                    ],
                  );
                }

                if (_isAcademicHierarchyView) {
                  final hierarchyWidget = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: AcademicHierarchyOrgFilter(
                      campuses: campuses,
                      faculties: faculties,
                      programs: programs,
                      organizations: allOrgs,
                      selectedCampusId: _selectedCampus,
                      selectedFacultyId: _selectedFaculty,
                      selectedProgramId: _selectedProgram,
                      userRole: userProfile?.role ?? 'student',
                      userFacultyId: userProfile?.facultyId,
                      userProgramId: userProfile?.programId,
                      onCampusSelected: (campusId) {
                        setState(() {
                          _selectedCampus = campusId;
                          _selectedFaculty = 'All';
                          _selectedProgram = 'All';
                        });
                      },
                      onFacultySelected: (facultyId) {
                        final faculty = faculties.firstWhere((f) => f.id == facultyId);
                        setState(() {
                          _selectedCampus = faculty.campusId;
                          _selectedFaculty = facultyId;
                          _selectedProgram = 'All';
                        });
                      },
                      onProgramSelected: (programId) {
                        final program = programs.firstWhere((p) => p.id == programId);
                        final faculty = faculties.firstWhere((f) => f.id == program.facultyId);
                        setState(() {
                          _selectedCampus = faculty.campusId;
                          _selectedFaculty = program.facultyId;
                          _selectedProgram = programId;
                        });
                      },
                      onClearFilters: () {
                        setState(() {
                          _selectedCampus = 'All';
                          _selectedFaculty = 'All';
                          _selectedProgram = 'All';
                        });
                      },
                    ),
                  );

                  if (isWideScreen) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 320,
                          child: hierarchyWidget,
                        ),
                        Expanded(
                          child: buildMainContentList(),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(
                                'Filter by Academic Directory',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              leading: const Icon(LucideIcons.gitMerge, color: AppColors.primary, size: 18),
                              backgroundColor: Colors.transparent,
                              collapsedBackgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              children: [
                                hierarchyWidget,
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildMainContentList(),
                      ],
                    );
                  }
                }

                return buildMainContentList();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildPaginationFooter(int totalItems, int currentPage, int rowsPerPage) {
    final totalPages = (totalItems / rowsPerPage).ceil();
    final startItem = totalItems == 0 ? 0 : (currentPage * rowsPerPage) + 1;
    final endItem = (currentPage * rowsPerPage) + rowsPerPage > totalItems
        ? totalItems
        : (currentPage * rowsPerPage) + rowsPerPage;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        final dropdownWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isNarrow ? 'Rows:' : 'Rows per page:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: rowsPerPage,
                  icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54),
                  elevation: 4,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  items: [5, 10, 20, 50].map((val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text(
                        '$val',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _rowsPerPage = val;
                        _currentPage = 0;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        );

        final infoTextWidget = Text(
          'Showing $startItem-$endItem of $totalItems',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        );

        final navigationWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page_rounded, size: 18),
              onPressed: currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage = 0;
                      });
                    }
                  : null,
              tooltip: 'First Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 18),
              onPressed: currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage = currentPage - 1;
                      });
                    }
                  : null,
              tooltip: 'Previous Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${currentPage + 1} / ${totalPages > 0 ? totalPages : 1}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 18),
              onPressed: currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage = currentPage + 1;
                      });
                    }
                  : null,
              tooltip: 'Next Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.last_page_rounded, size: 18),
              onPressed: currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage = totalPages - 1;
                      });
                    }
                  : null,
              tooltip: 'Last Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    dropdownWidget,
                    infoTextWidget,
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                navigationWidget,
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              dropdownWidget,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  infoTextWidget,
                  const SizedBox(width: 24),
                  navigationWidget,
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
