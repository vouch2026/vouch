import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../campuses/models/campus_model.dart';
import '../../faculties/models/faculty_model.dart';
import '../../programs/models/program_model.dart';
import '../../auth/models/user_model.dart';

class AcademicHierarchyFilter extends StatefulWidget {
  final List<CampusModel> campuses;
  final List<FacultyModel> faculties;
  final List<ProgramModel> programs;
  final List<UserModel> allUsers;
  final String selectedCampusId;
  final String selectedFacultyId;
  final String selectedProgramId;
  final Function(String) onCampusSelected;
  final Function(String) onFacultySelected;
  final Function(String) onProgramSelected;
  final VoidCallback onClearFilters;
  final String userRole;
  final String? userFacultyId;
  final String? userProgramId;

  const AcademicHierarchyFilter({
    super.key,
    required this.campuses,
    required this.faculties,
    required this.programs,
    required this.allUsers,
    required this.selectedCampusId,
    required this.selectedFacultyId,
    required this.selectedProgramId,
    required this.onCampusSelected,
    required this.onFacultySelected,
    required this.onProgramSelected,
    required this.onClearFilters,
    required this.userRole,
    this.userFacultyId,
    this.userProgramId,
  });

  @override
  State<AcademicHierarchyFilter> createState() => _AcademicHierarchyFilterState();
}

class _AcademicHierarchyFilterState extends State<AcademicHierarchyFilter> {
  final Set<String> _expandedCampuses = {};
  final Set<String> _expandedFaculties = {};
  bool _hasToggledDeanFacultyInitially = false;

  void _toggleCampus(String id) {
    setState(() {
      if (_expandedCampuses.contains(id)) {
        _expandedCampuses.remove(id);
      } else {
        _expandedCampuses.add(id);
      }
    });
  }

  void _toggleFaculty(String id) {
    setState(() {
      if (_expandedFaculties.contains(id)) {
        _expandedFaculties.remove(id);
      } else {
        _expandedFaculties.add(id);
      }
    });
  }

  int _getCampusUserCount(String campusId) {
    return widget.allUsers.where((u) => u.campusId == campusId).length;
  }

  int _getFacultyUserCount(String facultyId) {
    return widget.allUsers.where((u) => u.facultyId == facultyId).length;
  }

  int _getProgramUserCount(String programId) {
    return widget.allUsers.where((u) => u.programId == programId).length;
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = widget.selectedCampusId != 'All' ||
        widget.selectedFacultyId != 'All' ||
        widget.selectedProgramId != 'All';

    // Conditionally determine top-level content based on userRole
    Widget treeContent;

    if (widget.userRole == 'dean') {
      FacultyModel? deanFaculty;
      try {
        deanFaculty = widget.faculties.firstWhere((f) => f.id == widget.userFacultyId);
      } catch (_) {
        deanFaculty = null;
      }

      if (deanFaculty == null) {
        treeContent = Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No faculty assigned',
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ),
        );
      } else {
        final facultyPrograms = widget.programs
            .where((p) => p.facultyId == deanFaculty!.id)
            .toList();
        final isFacultySelected = widget.selectedFacultyId == deanFaculty.id &&
            widget.selectedProgramId == 'All';
        final isExpanded = _expandedFaculties.contains(deanFaculty.id) ||
            !_hasToggledDeanFacultyInitially;
        final userCount = _getFacultyUserCount(deanFaculty.id);

        treeContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFacultyRow(
              faculty: deanFaculty,
              userCount: userCount,
              isSelected: isFacultySelected,
              isExpanded: isExpanded,
              onTap: () {
                widget.onFacultySelected(deanFaculty!.id);
              },
              onToggleExpand: () {
                setState(() {
                  _hasToggledDeanFacultyInitially = true;
                });
                _toggleFaculty(deanFaculty!.id);
              },
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: facultyPrograms.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'No programs found',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Column(
                        children: facultyPrograms.map((program) {
                          final isProgramSelected = widget.selectedProgramId == program.id;
                          final programCount = _getProgramUserCount(program.id);

                          return _buildProgramRow(
                            program: program,
                            userCount: programCount,
                            isSelected: isProgramSelected,
                            onTap: () {
                              widget.onProgramSelected(program.id);
                            },
                          );
                        }).toList(),
                      ),
              ),
          ],
        );
      }
    } else if (widget.userRole == 'program_head') {
      ProgramModel? headProgram;
      try {
        headProgram = widget.programs.firstWhere((p) => p.id == widget.userProgramId);
      } catch (_) {
        headProgram = null;
      }

      if (headProgram == null) {
        treeContent = Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No program assigned',
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ),
        );
      } else {
        final isProgramSelected = widget.selectedProgramId == headProgram.id;
        final programCount = _getProgramUserCount(headProgram.id);

        treeContent = _buildProgramRow(
          program: headProgram,
          userCount: programCount,
          isSelected: isProgramSelected,
          onTap: () {
            widget.onProgramSelected(headProgram!.id);
          },
        );
      }
    } else {
      // Default: Super Admin and other roles
      if (widget.campuses.isEmpty) {
        treeContent = Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No campus data available',
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 13,
              ),
            ),
          ),
        );
      } else {
        treeContent = ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.campuses.length,
          itemBuilder: (context, index) {
            final campus = widget.campuses[index];
            final isSelected = widget.selectedCampusId == campus.id &&
                widget.selectedFacultyId == 'All' &&
                widget.selectedProgramId == 'All';
            final isExpanded = _expandedCampuses.contains(campus.id);
            final userCount = _getCampusUserCount(campus.id);

            final campusFaculties = widget.faculties
                .where((f) => f.campusId == campus.id)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCampusRow(
                  campus: campus,
                  userCount: userCount,
                  isSelected: isSelected,
                  isExpanded: isExpanded,
                  onTap: () {
                    widget.onCampusSelected(campus.id);
                  },
                  onToggleExpand: () => _toggleCampus(campus.id),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: campusFaculties.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'No faculties found',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[400],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : Column(
                            children: campusFaculties.map((faculty) {
                              final isFacultySelected = widget.selectedFacultyId == faculty.id &&
                                  widget.selectedProgramId == 'All';
                              final isFacultyExpanded = _expandedFaculties.contains(faculty.id);
                              final facultyCount = _getFacultyUserCount(faculty.id);
                              final facultyPrograms = widget.programs
                                  .where((p) => p.facultyId == faculty.id)
                                  .toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFacultyRow(
                                    faculty: faculty,
                                    userCount: facultyCount,
                                    isSelected: isFacultySelected,
                                    isExpanded: isFacultyExpanded,
                                    onTap: () {
                                      widget.onFacultySelected(faculty.id);
                                    },
                                    onToggleExpand: () => _toggleFaculty(faculty.id),
                                  ),
                                  if (isFacultyExpanded)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: facultyPrograms.isEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              child: Text(
                                                'No programs found',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: Colors.grey[400],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            )
                                          : Column(
                                              children: facultyPrograms.map((program) {
                                                final isProgramSelected = widget.selectedProgramId == program.id;
                                                final programCount = _getProgramUserCount(program.id);

                                                return _buildProgramRow(
                                                  program: program,
                                                  userCount: programCount,
                                                  isSelected: isProgramSelected,
                                                  onTap: () {
                                                    widget.onProgramSelected(program.id);
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                  ),
              ],
            );
          },
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academic Directory',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select a node to filter list',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasActiveFilter)
                  TextButton.icon(
                    onPressed: widget.onClearFilters,
                    icon: const Icon(LucideIcons.x, size: 14),
                    label: Text(
                      'Clear',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          treeContent,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCampusRow({
    required CampusModel campus,
    required int userCount,
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onTap,
    required VoidCallback onToggleExpand,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 8, right: 12),
        leading: GestureDetector(
          onTap: onToggleExpand,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
              size: 18,
              color: Colors.grey[700],
            ),
          ),
        ),
        title: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  campus.name,
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                    color: isSelected ? AppColors.primary : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildCountBadge(userCount, isSelected, AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyRow({
    required FacultyModel faculty,
    required int userCount,
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onTap,
    required VoidCallback onToggleExpand,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 8, right: 12),
        leading: GestureDetector(
          onTap: onToggleExpand,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
              size: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        title: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  faculty.name,
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                    color: isSelected ? AppColors.primary : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildCountBadge(userCount, isSelected, AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramRow({
    required ProgramModel program,
    required int userCount,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.teal.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 32, right: 12),
        title: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  program.name,
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                    fontSize: 11,
                    color: isSelected ? Colors.teal[800] : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildCountBadge(userCount, isSelected, Colors.teal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountBadge(int count, bool isSelected, Color baseColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? baseColor.withValues(alpha: 0.2)
            : baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isSelected ? baseColor : Colors.black54,
        ),
      ),
    );
  }
}
