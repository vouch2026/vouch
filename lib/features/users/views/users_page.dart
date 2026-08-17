import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:excel/excel.dart' as excel_lib;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/utils/file_saver_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../providers/users_provider.dart';
import '../providers/user_stats_provider.dart';
import '../models/user_stats_model.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';
import '../../campuses/models/campus_model.dart';
import '../../faculties/models/faculty_model.dart';
import '../../programs/models/program_model.dart';
import '../widgets/modals/create_user_modal.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../routes/route_names.dart';
import '../../../core/config/supabase_config.dart';
import '../widgets/academic_hierarchy_filter.dart';
import '../../settings/providers/system_settings_provider.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExcelView = true;
  bool _isAcademicHierarchyView = false;
  String _selectedRole = 'All';
  String _selectedCampus = 'All';
  String _selectedFaculty = 'All';
  String _selectedProgram = 'All';
  String _selectedYearLevel = 'All';
  String _selectedStatus = 'All';
  Set<String> _selectedUserIds = {};
  bool _isSelectionMode = false;
  int _currentPage = 0;
  int _rowsPerPage = 10;
  String _prevRole = 'All';
  String _prevCampus = 'All';
  String _prevFaculty = 'All';
  String _prevProgram = 'All';
  String _prevYearLevel = 'All';
  String _prevStatus = 'All';

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

  String _initialsFromName(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Future<void> _downloadExcelReport(List<UserModel> users) async {
    try {
      final excel = excel_lib.Excel.createExcel();
      final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[defaultSheet];

      // Headers (Metadata)
      sheet.appendRow([
        excel_lib.TextCellValue('Report Type'),
        excel_lib.TextCellValue('User Directory Report'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Export Date'),
        excel_lib.TextCellValue(DateTime.now().toLocal().toString().substring(0, 19)),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Total Records'),
        excel_lib.TextCellValue('${users.length}'),
      ]);
      sheet.appendRow([]); // space row

      // Table Column Headers
      sheet.appendRow([
        excel_lib.TextCellValue('ID / Student Number'),
        excel_lib.TextCellValue('Full Name'),
        excel_lib.TextCellValue('Email'),
        excel_lib.TextCellValue('Role'),
        excel_lib.TextCellValue('Faculty'),
        excel_lib.TextCellValue('Program'),
        excel_lib.TextCellValue('Year Level'),
        excel_lib.TextCellValue('Status'),
      ]);

      // Data Rows
      for (final user in users) {
        sheet.appendRow([
          excel_lib.TextCellValue(user.schoolId),
          excel_lib.TextCellValue(user.fullName),
          excel_lib.TextCellValue(user.email),
          excel_lib.TextCellValue(user.roleDisplay),
          excel_lib.TextCellValue(user.facultyName ?? 'N/A'),
          excel_lib.TextCellValue(user.programName ?? 'N/A'),
          excel_lib.TextCellValue(user.yearLevelDisplay),
          excel_lib.TextCellValue(user.status.toUpperCase()),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception("Failed to encode excel");

      final String fileName = "Users_Directory_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      
      final isSuccess = await FileSaverUtil.saveFile(Uint8List.fromList(bytes), fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSuccess ? 'Users report downloaded successfully!' : 'Failed to download report.'),
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

  Widget _buildAnalyticsSection(UserStatsModel stats) {
    final total = stats.totalUsers;
    final studentsCount = stats.totalStudents;
    final personnelCount = stats.totalInstructors;
    final programHeadsCount = stats.programHeadsCount;
    final deansCount = stats.deansCount;
    
    final studentsPercent = total > 0 ? (studentsCount / total * 100).round() : 0;
    final personnelPercent = total > 0 ? (personnelCount / total * 100).round() : 0;
    final programHeadsPercent = total > 0 ? (programHeadsCount / total * 100).round() : 0;
    final deansPercent = total > 0 ? (deansCount / total * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          // KPI Cards
          LayoutBuilder(
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
                  title: 'Students',
                  value: '$studentsCount',
                  color: Colors.blue,
                  icon: LucideIcons.user,
                  isSelected: _selectedRole == 'student',
                  onTap: () => setState(() => _selectedRole = _selectedRole == 'student' ? 'All' : 'student'),
                ),
                _buildKpiCard(
                  title: 'Personnel',
                  value: '$personnelCount',
                  color: Colors.orange,
                  icon: LucideIcons.graduationCap,
                  isSelected: _selectedRole == 'personnel',
                  onTap: () => setState(() => _selectedRole = _selectedRole == 'personnel' ? 'All' : 'personnel'),
                ),
                _buildKpiCard(
                  title: 'Program Heads',
                  value: '$programHeadsCount',
                  color: Colors.teal,
                  icon: LucideIcons.userCheck,
                  isSelected: _selectedRole == 'program_head',
                  onTap: () => setState(() => _selectedRole = _selectedRole == 'program_head' ? 'All' : 'program_head'),
                ),
                _buildKpiCard(
                  title: 'Deans',
                  value: '$deansCount',
                  color: Colors.purple,
                  icon: LucideIcons.award,
                  isSelected: _selectedRole == 'dean',
                  onTap: () => setState(() => _selectedRole = _selectedRole == 'dean' ? 'All' : 'dean'),
                ),
              ]);
            },
          ),
          
          const SizedBox(height: 16),

          // Chart Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Pie Chart
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 32,
                          sections: [
                            PieChartSectionData(
                              value: studentsCount > 0 ? studentsCount.toDouble() : 0.001,
                              color: Colors.blue,
                              title: '',
                              radius: 18,
                            ),
                            PieChartSectionData(
                              value: personnelCount > 0 ? personnelCount.toDouble() : 0.001,
                              color: Colors.orange,
                              title: '',
                              radius: 18,
                            ),
                            PieChartSectionData(
                              value: programHeadsCount > 0 ? programHeadsCount.toDouble() : 0.001,
                              color: Colors.teal,
                              title: '',
                              radius: 18,
                            ),
                            PieChartSectionData(
                              value: deansCount > 0 ? deansCount.toDouble() : 0.001,
                              color: Colors.purple,
                              title: '',
                              radius: 18,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$total',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'User Roles Distribution',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem('Students', Colors.blue, studentsCount, studentsPercent),
                      const SizedBox(height: 6),
                      _buildLegendItem('Personnel', Colors.orange, personnelCount, personnelPercent),
                      const SizedBox(height: 6),
                      _buildLegendItem('Program Heads', Colors.teal, programHeadsCount, programHeadsPercent),
                      const SizedBox(height: 6),
                      _buildLegendItem('Deans', Colors.purple, deansCount, deansPercent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count, int percent) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          '$count ($percent%)',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
    bool isOutline = false,
    IconData? trailingIcon,
  }) {
    final chipContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary 
            : (isOutline ? Colors.transparent : AppColors.primary.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? AppColors.primary 
              : (isOutline ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent),
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
              color: isSelected ? Colors.white : (isOutline ? AppColors.primary.withValues(alpha: 0.7) : AppColors.primary),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            Icon(
              trailingIcon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.primary.withValues(alpha: 0.7),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chipContent,
      );
    }
    
    return chipContent;
  }

  List<String> _getAvailableYearLevels(List<UserModel> users) {
    final years = users
        .map((u) => u.yearLevel)
        .where((y) => y != null && y != 0)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...years.map((y) => y.toString())];
  }

  String _getRoleFilterLabel(String roleValue) {
    if (roleValue == 'All') return 'Role';
    if (roleValue == 'program_head') return 'Program Head';
    if (roleValue == 'super_admin') return 'Super Admin';
    return roleValue[0].toUpperCase() + roleValue.substring(1).toLowerCase();
  }

  String _getYearLevelFilterLabel(String yearValue) {
    if (yearValue == 'All') return 'Year Level';
    if (yearValue == '1') return '1st Year';
    if (yearValue == '2') return '2nd Year';
    if (yearValue == '3') return '3rd Year';
    if (yearValue == '4') return '4th Year';
    return '$yearValue Year';
  }

  String _getCampusFilterLabel(String campusId, List<CampusModel> campuses) {
    if (campusId == 'All') return 'Campus';
    try {
      final campus = campuses.firstWhere((c) => c.id == campusId);
      return campus.name;
    } catch (_) {
      return 'Campus';
    }
  }

  String _getFacultyFilterLabel(String facultyId, List<FacultyModel> faculties) {
    if (facultyId == 'All') return 'Faculty';
    try {
      final faculty = faculties.firstWhere((f) => f.id == facultyId);
      return faculty.code;
    } catch (_) {
      return 'Faculty';
    }
  }

  String _getProgramFilterLabel(String programId, List<ProgramModel> programs) {
    if (programId == 'All') return 'Program';
    try {
      final program = programs.firstWhere((p) => p.id == programId);
      return program.code;
    } catch (_) {
      return 'Program';
    }
  }

  Widget _buildFilterSection({
    required List<UserModel> allUsers,
    required List<CampusModel> campuses,
    required List<FacultyModel> faculties,
    required List<ProgramModel> programs,
    required bool isSuperAdmin,
    required UserModel? userProfile,
  }) {
    final yearLevels = _getAvailableYearLevels(allUsers);

    // Apply role-based restrictions to faculties and programs lists
    List<FacultyModel> restrictedFaculties = faculties;
    List<ProgramModel> restrictedPrograms = programs;

    if (userProfile?.role == 'dean') {
      final facultyId = userProfile?.facultyId;
      restrictedFaculties = faculties.where((f) => f.id == facultyId).toList();
      restrictedPrograms = programs.where((p) => p.facultyId == facultyId).toList();
    } else if (userProfile?.role == 'program_head') {
      final programId = userProfile?.programId;
      ProgramModel? program;
      try {
        program = programs.firstWhere((p) => p.id == programId);
      } catch (_) {
        program = null;
      }
      if (program != null) {
        restrictedFaculties = faculties.where((f) => f.id == program!.facultyId).toList();
        restrictedPrograms = programs.where((p) => p.id == programId).toList();
      } else {
        restrictedFaculties = [];
        restrictedPrograms = [];
      }
    }

    // Filter faculties list based on selected campus
    final filteredFaculties = _selectedCampus == 'All'
        ? restrictedFaculties
        : restrictedFaculties.where((f) => f.campusId == _selectedCampus).toList();

    // Filter programs list based on selected faculty (or campus)
    final filteredPrograms = _selectedFaculty != 'All'
        ? restrictedPrograms.where((p) => p.facultyId == _selectedFaculty).toList()
        : (_selectedCampus != 'All'
            ? (() {
                final campusFacultyIds = restrictedFaculties
                    .where((f) => f.campusId == _selectedCampus)
                    .map((f) => f.id)
                    .toSet();
                return restrictedPrograms.where((p) => campusFacultyIds.contains(p.facultyId)).toList();
              })()
            : restrictedPrograms);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          // 1. Roles Dropdown Filter
          if (isSuperAdmin) ...[
            PopupMenuButton<String>(
              onSelected: (String role) {
                setState(() {
                  _selectedRole = role;
                });
              },
              offset: const Offset(0, 45),
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.05)),
              ),
              itemBuilder: (BuildContext context) {
                final roles = [
                  {'label': 'All Roles', 'value': 'All'},
                  {'label': 'Student', 'value': 'student'},
                  {'label': 'Personnel', 'value': 'personnel'},
                  {'label': 'Program Head', 'value': 'program_head'},
                  {'label': 'Dean', 'value': 'dean'},
                ];
                return roles.map((roleOpt) {
                  final isItemSelected = _selectedRole == roleOpt['value'];
                  return PopupMenuItem<String>(
                    value: roleOpt['value'],
                    height: 42,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            roleOpt['label']!,
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
                label: _getRoleFilterLabel(_selectedRole),
                isSelected: _selectedRole != 'All',
                trailingIcon: LucideIcons.chevronDown,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 2. Campus Dropdown Filter
          if (isSuperAdmin) ...[
            PopupMenuButton<String>(
              onSelected: (String campusId) {
                setState(() {
                  _selectedCampus = campusId;
                  // Connected reset: Reset dependent filters when campus changes
                  _selectedFaculty = 'All';
                  _selectedProgram = 'All';
                });
              },
              offset: const Offset(0, 45),
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.05)),
              ),
              itemBuilder: (BuildContext context) {
                final items = [
                  {'label': 'All Campuses', 'value': 'All'},
                  ...campuses.map((c) => {'label': c.name, 'value': c.id}),
                ];
                return items.map((camp) {
                  final isItemSelected = _selectedCampus == camp['value'];
                  return PopupMenuItem<String>(
                    value: camp['value']!,
                    height: 42,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            camp['label']!,
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
                label: _getCampusFilterLabel(_selectedCampus, campuses),
                isSelected: _selectedCampus != 'All',
                trailingIcon: LucideIcons.chevronDown,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 3. Faculty Dropdown Filter
          if (isSuperAdmin || userProfile?.role == 'dean') ...[
            PopupMenuButton<String>(
              onSelected: (String facultyId) {
                setState(() {
                  _selectedFaculty = facultyId;
                  // Connected reset: Reset dependent program filter when faculty changes
                  _selectedProgram = 'All';
                });
              },
              offset: const Offset(0, 45),
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.05)),
              ),
              itemBuilder: (BuildContext context) {
                final items = [
                  {'label': 'All Faculties', 'value': 'All'},
                  ...filteredFaculties.map((f) => {'label': f.code, 'value': f.id}),
                ];
                return items.map((fac) {
                  final isItemSelected = _selectedFaculty == fac['value'];
                  return PopupMenuItem<String>(
                    value: fac['value']!,
                    height: 42,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            fac['label']!,
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
                label: _getFacultyFilterLabel(_selectedFaculty, faculties),
                isSelected: _selectedFaculty != 'All',
                trailingIcon: LucideIcons.chevronDown,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 4. Program Dropdown Filter
          PopupMenuButton<String>(
            onSelected: (String programId) {
              setState(() {
                _selectedProgram = programId;
              });
            },
            offset: const Offset(0, 45),
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.05)),
            ),
            itemBuilder: (BuildContext context) {
              final items = userProfile?.role == 'program_head'
                  ? filteredPrograms.map((p) => {'label': p.code, 'value': p.id}).toList()
                  : [
                      {'label': 'All Programs', 'value': 'All'},
                      ...filteredPrograms.map((p) => {'label': p.code, 'value': p.id}),
                    ];
              return items.map((prog) {
                final isItemSelected = _selectedProgram == prog['value'];
                return PopupMenuItem<String>(
                  value: prog['value']!,
                  height: 42,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          prog['label']!,
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
              label: _getProgramFilterLabel(_selectedProgram, programs),
              isSelected: _selectedProgram != 'All',
              trailingIcon: LucideIcons.chevronDown,
            ),
          ),
          const SizedBox(width: 8),

          // 5. Year Level Dropdown Filter
          PopupMenuButton<String>(
            onSelected: (String year) {
              setState(() {
                _selectedYearLevel = year;
              });
            },
            offset: const Offset(0, 45),
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.05)),
            ),
            itemBuilder: (BuildContext context) {
              return yearLevels.map((y) {
                final isItemSelected = _selectedYearLevel == y;
                return PopupMenuItem<String>(
                  value: y,
                  height: 42,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          y == 'All' ? 'All Year Levels' : _getYearLevelFilterLabel(y),
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
              label: _getYearLevelFilterLabel(_selectedYearLevel),
              isSelected: _selectedYearLevel != 'All',
              trailingIcon: LucideIcons.chevronDown,
            ),
          ),
          const SizedBox(width: 8),

          // 6. Status Dropdown Filter
          PopupMenuButton<String>(
            onSelected: (String status) {
              setState(() {
                _selectedStatus = status;
              });
            },
            offset: const Offset(0, 45),
            elevation: 6,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.05)),
            ),
            itemBuilder: (BuildContext context) {
              final statuses = [
                {'label': 'All Statuses', 'value': 'All'},
                {'label': 'Active', 'value': 'Active'},
                {'label': 'Pending', 'value': 'Pending'},
                {'label': 'Suspended', 'value': 'Suspended'},
              ];
              return statuses.map((stat) {
                final isItemSelected = _selectedStatus == stat['value'];
                return PopupMenuItem<String>(
                  value: stat['value'],
                  height: 42,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          stat['label']!,
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
              label: _selectedStatus == 'All' ? 'Status' : _selectedStatus,
              isSelected: _selectedStatus != 'All',
              trailingIcon: LucideIcons.chevronDown,
            ),
          ),
          if (_selectedRole != 'All' ||
              _selectedCampus != 'All' ||
              _selectedFaculty != 'All' ||
              _selectedProgram != 'All' ||
              _selectedYearLevel != 'All' ||
              _selectedStatus != 'All') ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedRole = 'All';
                  _selectedCampus = 'All';
                  _selectedFaculty = 'All';
                  _selectedProgram = 'All';
                  _selectedYearLevel = 'All';
                  _selectedStatus = 'All';
                });
              },
              icon: const Icon(LucideIcons.x, size: 14, color: Colors.red),
              label: Text(
                'Clear Filters',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                ),
                backgroundColor: Colors.red.withValues(alpha: 0.05),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            icon: LucideIcons.list,
            label: 'Card List',
            isSelected: !_isExcelView,
            onTap: () => setState(() => _isExcelView = false),
          ),
          const SizedBox(width: 4),
          _buildToggleOption(
            icon: LucideIcons.sheet,
            label: 'Excel Preview',
            isSelected: _isExcelView,
            onTap: () => setState(() => _isExcelView = true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActionsMenu(List<UserModel> filteredUsers) {
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
      onSelected: (action) => _handleBulkAction(action, filteredUsers),
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
          value: 'select_students',
          child: Row(
            children: [
              const Icon(LucideIcons.userCheck, size: 16, color: Colors.blue),
              const SizedBox(width: 10),
              Text(
                'Select Students',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'select_faculty',
          child: Row(
            children: [
              const Icon(LucideIcons.users, size: 16, color: Colors.indigo),
              const SizedBox(width: 10),
              Text(
                'Select Faculty',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
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
                  'Activate Selected${_selectedUserIds.isNotEmpty ? " (${_selectedUserIds.length})" : ""}',
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
            value: 'suspend',
            child: Row(
              children: [
                const Icon(
                  LucideIcons.alertCircle,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                Text(
                  'Suspend Selected${_selectedUserIds.isNotEmpty ? " (${_selectedUserIds.length})" : ""}',
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
                  'Delete Selected${_selectedUserIds.isNotEmpty ? " (${_selectedUserIds.length})" : ""}',
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

  Future<void> _handleBulkAction(String action, List<UserModel> filteredUsers) async {
    if (action == 'enable_selection') {
      setState(() {
        _isSelectionMode = true;
      });
      return;
    }
    if (action == 'disable_selection') {
      setState(() {
        _isSelectionMode = false;
        _selectedUserIds.clear();
      });
      return;
    }
    if (action == 'select_students') {
      setState(() {
        _isSelectionMode = true;
        _selectedUserIds = filteredUsers
            .where((u) => u.role == 'student' && u.id != null)
            .map((u) => u.id!)
            .toSet();
      });
      return;
    }
    if (action == 'select_faculty') {
      setState(() {
        _isSelectionMode = true;
        _selectedUserIds = filteredUsers
            .where((u) => (u.role == 'personnel' || u.role == 'program_head' || u.role == 'dean') && u.id != null)
            .map((u) => u.id!)
            .toSet();
      });
      return;
    }
    if (action == 'select_all') {
      setState(() {
        _isSelectionMode = true;
        _selectedUserIds = filteredUsers
            .where((u) => u.id != null)
            .map((u) => u.id!)
            .toSet();
      });
      return;
    }

    if (action == 'activate' || action == 'suspend' || action == 'delete') {
      if (_selectedUserIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select at least one user first.',
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
              ? 'Delete Users'
              : action == 'activate'
                  ? 'Activate Users'
                  : 'Suspend Users',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          action == 'delete'
              ? 'Are you sure you want to delete ${_selectedUserIds.length} selected user(s)? This action is permanent and will delete the user(s) from both the database and authentication.'
              : 'Are you sure you want to change the status of ${_selectedUserIds.length} selected user(s)?',
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
      final ids = _selectedUserIds.toList();

      if (action == 'delete') {
        for (final id in ids) {
          await client.rpc(
            'delete_user_entirely',
            params: {'p_user_id': id},
          );
        }
      } else if (action == 'activate') {
        await client.from('users').update({'account_status': 'active'}).inFilter('id', ids);
      } else if (action == 'suspend') {
        await client.from('users').update({'account_status': 'suspended'}).inFilter('id', ids);
      }

      // Show success toast
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'delete'
                  ? 'Successfully deleted users'
                  : 'Successfully updated user statuses',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Clear selections and refresh
      setState(() {
        _selectedUserIds.clear();
        _isSelectionMode = false;
      });
      ref.invalidate(allUsersProvider);
      ref.invalidate(userStatsProvider);
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

  Future<void> _handleSingleUserAction(String action, UserModel user) async {
    if (user.id == null) return;

    if (action == 'view') {
      context.pushNamed(
        RouteNames.userDetails,
        pathParameters: {'id': user.id!},
      );
      return;
    }

    final client = SupabaseConfig.client;

    if (action == 'suspend') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Suspend User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to suspend ${user.fullName}?', style: GoogleFonts.poppins(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('Confirm', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      try {
        await client.from('users').update({'account_status': 'suspended'}).eq('id', user.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully suspended ${user.fullName}', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        }
        ref.invalidate(allUsersProvider);
        ref.invalidate(userStatsProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to suspend user: $e', style: GoogleFonts.poppins()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    if (action == 'activate') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Activate User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to activate ${user.fullName}?', style: GoogleFonts.poppins(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('Confirm', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      try {
        await client.from('users').update({'account_status': 'active'}).eq('id', user.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully activated ${user.fullName}', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        }
        ref.invalidate(allUsersProvider);
        ref.invalidate(userStatsProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to activate user: $e', style: GoogleFonts.poppins()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete ${user.fullName}? This action is permanent and will delete the user from both the database and authentication.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Confirm', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      try {
        await client.rpc(
          'delete_user_entirely',
          params: {'p_user_id': user.id!},
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully deleted ${user.fullName}', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        }
        ref.invalidate(allUsersProvider);
        ref.invalidate(userStatsProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete user: $e', style: GoogleFonts.poppins()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }
  }

  Widget _buildEmptyState() {
    final hasNoFilters = _searchController.text.isEmpty &&
        _selectedRole == 'All' &&
        _selectedCampus == 'All' &&
        _selectedFaculty == 'All' &&
        _selectedProgram == 'All' &&
        _selectedYearLevel == 'All' &&
        _selectedStatus == 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasNoFilters ? LucideIcons.clipboard : LucideIcons.search,
                size: 60,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasNoFilters ? 'No users registered yet' : 'No matching users found',
              style: GoogleFonts.poppins(
                color: Colors.black.withValues(alpha: 0.5),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.poppins(
                color: Colors.black.withValues(alpha: 0.35),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!hasNoFilters)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedRole = 'All';
                      _selectedCampus = 'All';
                      _selectedFaculty = 'All';
                      _selectedProgram = 'All';
                      _selectedYearLevel = 'All';
                      _selectedStatus = 'All';
                    });
                  },
                  child: const Text(
                    'Clear all filters',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExcelPreviewTable(List<UserModel> users, bool isSuperAdmin) {
    if (users.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  showCheckboxColumn: isSuperAdmin && _isSelectionMode,
                  onSelectAll: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedUserIds.addAll(users.where((u) => u.id != null).map((u) => u.id!));
                      } else {
                        for (final u in users) {
                          _selectedUserIds.remove(u.id);
                        }
                      }
                    });
                  },
                  headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.04)),
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return AppColors.primary.withValues(alpha: 0.02);
                    }
                    return null;
                  }),
                  columnSpacing: 24,
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
                        'ID / Number',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Full Name',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Role',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Campus',
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
                        'Year Level',
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
                  rows: users.map((user) {
                    final statusColor = user.status.toLowerCase() == 'active'
                        ? Colors.green
                        : user.status.toLowerCase() == 'pending'
                            ? Colors.orange
                            : Colors.red;

                    Color roleColor;
                    if (user.role == 'student') {
                      roleColor = Colors.blue;
                    } else if (user.role == 'super_admin') {
                      roleColor = Colors.red;
                    } else {
                      roleColor = Colors.indigo;
                    }

                    return DataRow(
                      selected: _selectedUserIds.contains(user.id),
                      onSelectChanged: (selected) {
                        if (isSuperAdmin && _isSelectionMode) {
                          setState(() {
                            if (selected == true) {
                              if (user.id != null) _selectedUserIds.add(user.id!);
                            } else {
                              _selectedUserIds.remove(user.id);
                            }
                          });
                        } else {
                          if (user.id != null) {
                            context.pushNamed(
                              RouteNames.userDetails,
                              pathParameters: {'id': user.id!},
                            );
                          }
                        }
                      },
                      cells: [
                        DataCell(
                          InkWell(
                            onTap: _isSelectionMode
                                ? null
                                : () {
                                    context.pushNamed(
                                      RouteNames.userDetails,
                                      pathParameters: {'id': user.id!},
                                    );
                                  },
                            child: Text(
                              user.schoolId,
                              style: GoogleFonts.poppins(
                                fontSize: 12, 
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: _isSelectionMode
                                ? null
                                : () {
                                    context.pushNamed(
                                      RouteNames.userDetails,
                                      pathParameters: {'id': user.id!},
                                    );
                                  },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.fullName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.roleDisplay,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: roleColor,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            user.campusName ?? 'N/A',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                        DataCell(
                          Text(
                            user.facultyCode ?? 'N/A',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                        DataCell(
                          Text(
                            user.programCode ?? 'N/A',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                        DataCell(
                          Text(
                            user.yearLevel == null || user.yearLevel == 0
                                ? 'N/A'
                                : user.yearLevelDisplay,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.status.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
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
                              onSelected: (value) => _handleSingleUserAction(value, user),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Text('View Profile', style: TextStyle(fontSize: 13)),
                                ),
                                if (user.status.toLowerCase() == 'active')
                                  const PopupMenuItem(
                                    value: 'suspend',
                                    child: Text('Suspend', style: TextStyle(fontSize: 13)),
                                  )
                                else
                                  const PopupMenuItem(
                                    value: 'activate',
                                    child: Text('Activate', style: TextStyle(fontSize: 13)),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardList(List<UserModel> users, bool isSuperAdmin) {
    if (users.isEmpty) {
      return _buildEmptyState();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: users.map((user) => _buildUserCard(user, isSuperAdmin)).toList(),
      ),
    );
  }

  Widget _buildUserCard(UserModel user, bool isSuperAdmin) {
    final statusColor = user.status.toLowerCase() == 'active'
        ? Colors.green
        : user.status.toLowerCase() == 'pending'
            ? Colors.orange
            : Colors.red;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isSuperAdmin && _isSelectionMode) {
          setState(() {
            if (_selectedUserIds.contains(user.id)) {
              _selectedUserIds.remove(user.id);
            } else {
              if (user.id != null) _selectedUserIds.add(user.id!);
            }
          });
        } else {
          if (user.id != null) {
            context.pushNamed(
              RouteNames.userDetails,
              pathParameters: {'id': user.id!},
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
        children: [
          if (isSuperAdmin && _isSelectionMode) ...[
            Checkbox(
              value: _selectedUserIds.contains(user.id),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    if (user.id != null) _selectedUserIds.add(user.id!);
                  } else {
                    _selectedUserIds.remove(user.id);
                  }
                });
              },
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 4),
          ],
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            child: Text(
              _initialsFromName(user.fullName),
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.schoolId} • ${user.roleDisplay}',
                  style: GoogleFonts.poppins(
                    color: Colors.black54, 
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.programName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      user.programName!,
                      style: GoogleFonts.poppins(
                        color: Colors.black45,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  user.status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isSuperAdmin) ...[
                const SizedBox(height: 6),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded, size: 18, color: Colors.grey),
                  offset: const Offset(0, 30),
                  elevation: 6,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) => _handleSingleUserAction(value, user),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Profile', style: TextStyle(fontSize: 13)),
                    ),
                    if (user.status.toLowerCase() == 'active')
                      const PopupMenuItem(
                        value: 'suspend',
                        child: Text('Suspend', style: TextStyle(fontSize: 13)),
                      )
                    else
                      const PopupMenuItem(
                        value: 'activate',
                        child: Text('Activate', style: TextStyle(fontSize: 13)),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (_prevRole != _selectedRole ||
        _prevCampus != _selectedCampus ||
        _prevFaculty != _selectedFaculty ||
        _prevProgram != _selectedProgram ||
        _prevYearLevel != _selectedYearLevel ||
        _prevStatus != _selectedStatus) {
      _prevRole = _selectedRole;
      _prevCampus = _selectedCampus;
      _prevFaculty = _selectedFaculty;
      _prevProgram = _selectedProgram;
      _prevYearLevel = _selectedYearLevel;
      _prevStatus = _selectedStatus;
      _currentPage = 0;
    }

    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';

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


    final usersAsync = ref.watch(allUsersProvider);
    final allUsers = usersAsync.value ?? <UserModel>[];
    final statsAsync = ref.watch(userStatsProvider);
    final campusesAsync = ref.watch(campusesProvider);
    final facultiesAsync = ref.watch(facultiesProvider);
    final programsAsync = ref.watch(programsProvider);

    final campuses = campusesAsync.valueOrNull ?? const <CampusModel>[];
    final faculties = facultiesAsync.valueOrNull ?? const <FacultyModel>[];
    final programs = programsAsync.valueOrNull ?? const <ProgramModel>[];

    final isMobile = MediaQuery.of(context).size.width < 768;

    final filteredUsers = allUsers.where((user) {
      final query = _searchController.text.toLowerCase();
      final matchesQuery = user.fullName.toLowerCase().contains(query) ||
          user.schoolId.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.programName ?? '').toLowerCase().contains(query) ||
          (user.facultyName ?? '').toLowerCase().contains(query);

      final matchesRole = _selectedRole == 'All' || 
          user.role == _selectedRole;

      final matchesCampus = _selectedCampus == 'All' || user.campusId == _selectedCampus;

      final matchesFaculty = _selectedFaculty == 'All' || user.facultyId == _selectedFaculty;

      final matchesProgram = _selectedProgram == 'All' || user.programId == _selectedProgram;

      final matchesYear = _selectedYearLevel == 'All' || user.yearLevel?.toString() == _selectedYearLevel;

      final matchesStatus = _selectedStatus == 'All' || user.status.toLowerCase() == _selectedStatus.toLowerCase();

      return matchesQuery && matchesRole && matchesCampus && matchesFaculty && matchesProgram && matchesYear && matchesStatus;
    }).toList();

    final totalItems = filteredUsers.length;
    final maxPages = (totalItems / _rowsPerPage).ceil();
    final safePage = _currentPage >= maxPages ? (maxPages > 0 ? maxPages - 1 : 0) : _currentPage;
    final startIndex = safePage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > totalItems ? totalItems : (startIndex + _rowsPerPage);
    final paginatedUsers = totalItems == 0 ? <UserModel>[] : filteredUsers.sublist(startIndex, endIndex);

    return DashboardLayout(
      title: 'User Management',
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs / Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.people_outline_rounded, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text(
                    'Users',
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
                          'User Management',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage all university accounts, including students, faculty, and advisers',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Row of header actions
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      if (isSuperAdmin)
                        FilledButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const CreateUserModal(),
                            );
                          },
                          icon: const Icon(LucideIcons.userPlus, size: 16),
                          label: Text(
                            'Add User',
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
                      
                      // Working Excel export button
                      if (allUsers.isNotEmpty)
                        FilledButton.icon(
                          onPressed: () => _downloadExcelReport(allUsers),
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
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Analytics KPI and Chart Card (Only visible to Super Admin)
            if (isSuperAdmin) ...[
              statsAsync.when(
                data: (stats) => _buildAnalyticsSection(stats),
                loading: () => const Center(child: FlickrLoader()),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text('Failed to load user analytics: $err'),
                ),
              ),
              const SizedBox(height: 24),
              ref.watch(systemSettingsProvider).when(
                data: (autoActivateEnabled) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: autoActivateEnabled
                        ? AppColors.success.withValues(alpha: 0.08)
                        : AppColors.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: autoActivateEnabled
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        autoActivateEnabled ? LucideIcons.shieldAlert : LucideIcons.shieldCheck,
                        color: autoActivateEnabled ? AppColors.success : AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              autoActivateEnabled ? 'Auto-Activation Mode: ON' : 'Manual Approval Mode: ON',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: autoActivateEnabled ? AppColors.success : AppColors.textDark,
                              ),
                            ),
                            Text(
                              autoActivateEnabled
                                  ? 'New user registrations are automatically activated instantly. Ideal for Deployment Day.'
                                  : 'Newly registered users require manual activation/approval from administrators.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: autoActivateEnabled,
                        activeColor: AppColors.success,
                        onChanged: (val) async {
                          await ref.read(systemSettingsProvider.notifier).toggleAutoActivation(val);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(val 
                                  ? 'Auto-activation enabled. New users will be active immediately!'
                                  : 'Manual approval enabled. New users must be vetted.'
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                loading: () => Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (e, _) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.shieldAlert, color: AppColors.error),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Configuration Error',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                                Text(
                                  'Please run the SQL migration script to create the `system_settings` table on Supabase.',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.invalidate(systemSettingsProvider);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                      if (e.toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Details: $e',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth >= 1024;
                
                // Helper to build the right-side/standard content (Search bar, Filters, and Table/Card list)
                Widget buildMainContentList() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search and Filter Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'User Accounts',
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
                                    _buildViewToggle(),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Search bar
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
                                  hintText: 'Search by user name, ID, email or program...',
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

                      // Filter chips and dropdowns with pinned bulk actions menu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildFilterSection(
                                allUsers: allUsers,
                                campuses: campuses,
                                faculties: faculties,
                                programs: programs,
                                isSuperAdmin: isSuperAdmin,
                                userProfile: userProfile,
                              ),
                            ),
                            if (isSuperAdmin) ...[
                              const SizedBox(width: 8),
                              _buildBulkActionsMenu(filteredUsers),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // User List or Excel Preview Table
                      usersAsync.when(
                        data: (usersList) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _isExcelView
                                  ? _buildExcelPreviewTable(paginatedUsers, isSuperAdmin)
                                  : _buildCardList(paginatedUsers, isSuperAdmin),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: _buildPaginationFooter(totalItems, safePage, _rowsPerPage),
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(child: FlickrLoader()),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Center(child: Text('Error loading users: $err')),
                        ),
                      ),
                    ],
                  );
                }

                // If academic directory mode is active
                if (_isAcademicHierarchyView) {
                  final hierarchyWidget = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: AcademicHierarchyFilter(
                      campuses: campuses,
                      faculties: faculties,
                      programs: programs,
                      allUsers: allUsers,
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
                        // Left column: Academic structure tree view
                        SizedBox(
                          width: 320,
                          child: hierarchyWidget,
                        ),
                        // Right column: Standard user table & filters
                        Expanded(
                          child: buildMainContentList(),
                        ),
                      ],
                    );
                  } else {
                    // Mobile stacked layout
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Collapsible directory filter at the top on mobile
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

                // Default standard full-width layout
                return buildMainContentList();
              },
            ),
          ],
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

