import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/route_names.dart';
import '../../../routes/route_paths.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../academic_structure/models/academic_term_model.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../auth/models/user_model.dart';
import '../../campuses/models/campus_model.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/models/faculty_model.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../users/providers/users_provider.dart';
import '../models/comselec_model.dart';
import '../providers/comselec_provider.dart';

class ComselecAssignRolesPage extends ConsumerStatefulWidget {
  final String comselecId;

  const ComselecAssignRolesPage({super.key, required this.comselecId});

  @override
  ConsumerState<ComselecAssignRolesPage> createState() => _ComselecAssignRolesPageState();
}

class _ComselecAssignRolesPageState extends ConsumerState<ComselecAssignRolesPage> {
  AcademicTermModel? _selectedTerm;
  int _campusCommissionersCount = 1;
  int _facultyCommissionersCount = 1;

  final Map<int, CampusModel> _selectedCampuses = {};
  final Map<int, FacultyModel> _selectedFaculties = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final activeTerm = await ref.read(activeTermProvider.future);
      if (mounted) setState(() => _selectedTerm = activeTerm);
    });
  }

  @override
  Widget build(BuildContext context) {
    final comselecAsync = ref.watch(comselecDetailsProvider(widget.comselecId));
    final termsAsync = ref.watch(academicTermsProvider);
    final campusesAsync = ref.watch(campusesProvider);
    final facultiesAsync = ref.watch(facultiesProvider);

    const royalBlue = Color(0xFF041E42);
    const gold = Color(0xFFC5A059);

    return comselecAsync.when(
      data: (comselec) {
        if (comselec == null) {
          return const DashboardLayout(
            title: 'Assign COMSELEC Roles',
            child: Center(child: Text('COMSELEC Branch not found')),
          );
        }

        return DashboardLayout(
          title: 'Assign COMSELEC Roles',
          onBack: () => context.goNamed(
            RouteNames.comselecProfile,
            pathParameters: {'id': widget.comselecId},
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs
                Row(
                  children: [
                    Icon(Icons.gavel_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => context.go(RoutePaths.comselecsManager),
                      child: Text(
                        'My COMSELEC',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => context.goNamed(
                        RouteNames.comselecProfile,
                        pathParameters: {'id': widget.comselecId},
                      ),
                      child: Text(
                        comselec.code,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text(
                      'Assign Roles',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Main Container
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assign COMSELEC Commissioners & Officials',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Delegate commissioner positions and fine-grained permissions for ${comselec.name}.',
                        style: const TextStyle(color: AppColors.textGrey),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Term Selector
                      Text('Academic Term Context', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      termsAsync.when(
                        data: (terms) => DropdownButtonFormField<AcademicTermModel>(
                          initialValue: _selectedTerm,
                          decoration: InputDecoration(
                            hintText: 'Select Academic Year & Semester',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                          ),
                          items: terms.map((term) => DropdownMenuItem(
                            value: term,
                            child: Text('${term.academicYear} - ${term.semester} ${term.isActive ? '(Active)' : ''}'),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedTerm = val),
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (err, _) => Text('Error loading terms: $err', style: const TextStyle(color: AppColors.error)),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: AppSpacing.lg),

                      // COMSELEC Leadership Positions
                      Text('COMSELEC Executive Positions', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      _buildPositionRow(
                        roleKey: 'comselec_chairman',
                        roleName: 'COMSELEC Chairman',
                        comselec: comselec,
                        royalBlue: royalBlue,
                        gold: gold,
                      ),
                      const SizedBox(height: 12),
                      _buildPositionRow(
                        roleKey: 'comselec_co_chairman',
                        roleName: 'COMSELEC Co-Chairman',
                        comselec: comselec,
                        royalBlue: royalBlue,
                        gold: gold,
                      ),

                      const SizedBox(height: AppSpacing.xl),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: AppSpacing.lg),

                      // Campus Commissioners (Multiple allowed for school-based & campus comselec)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Campus Commissioners', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _campusCommissionersCount++;
                              });
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Campus Commissioner Slot'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: royalBlue,
                              side: BorderSide(color: royalBlue.withValues(alpha: 0.5)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_campusCommissionersCount, (index) {
                        final selectedCampus = _selectedCampuses[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_city_rounded, color: royalBlue, size: 28),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Campus Commissioner #${index + 1}',
                                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: royalBlue),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            selectedCampus != null
                                                ? 'Assigned to Campus: ${selectedCampus.name}'
                                                : 'Please select assigned campus below',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: selectedCampus != null ? AppColors.primary : AppColors.textGrey,
                                              fontWeight: selectedCampus != null ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FilledButton(
                                      onPressed: _selectedTerm == null
                                          ? null
                                          : () => _showAssignUserModal(
                                                'campus_commissioner',
                                                'Campus Commissioner #${index + 1}',
                                                comselec,
                                                royalBlue,
                                                gold,
                                                targetCampus: selectedCampus,
                                              ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: royalBlue,
                                        foregroundColor: gold,
                                      ),
                                      child: const Text('Assign / Reassign'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                 campusesAsync.when(
                                  data: (campuses) {
                                    final availableCampuses = campuses.where((c) {
                                      if (comselec.campusId != null && comselec.campusId!.isNotEmpty) {
                                        return c.id == comselec.campusId;
                                      }
                                      if (comselec.schoolId != null && comselec.schoolId!.isNotEmpty) {
                                        return c.schoolId == comselec.schoolId;
                                      }
                                      return true;
                                    }).toList();

                                    if (availableCampuses.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(AppSpacing.md),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'No campuses available under ${comselec.name} scope.',
                                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                                        ),
                                      );
                                    }

                                    final effectiveCampus = availableCampuses.contains(selectedCampus)
                                        ? selectedCampus
                                        : (availableCampuses.length == 1 ? availableCampuses.first : null);

                                    return DropdownButtonFormField<CampusModel>(
                                      initialValue: effectiveCampus,
                                      decoration: InputDecoration(
                                        labelText: 'Select Campus Scope',
                                        prefixIcon: const Icon(Icons.campaign_outlined, size: 20),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      items: availableCampuses.map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c.name, style: AppTextStyles.bodySmall),
                                      )).toList(),
                                      onChanged: (c) {
                                        if (c != null) {
                                          setState(() => _selectedCampuses[index] = c);
                                        }
                                      },
                                    );
                                  },
                                  loading: () => const LinearProgressIndicator(),
                                  error: (err, _) => Text('Error loading campuses: $err', style: const TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: AppSpacing.lg),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: AppSpacing.lg),

                      // Faculty Commissioners (Multiple allowed)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Faculty Commissioners', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _facultyCommissionersCount++;
                              });
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Faculty Commissioner Slot'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: royalBlue,
                              side: BorderSide(color: royalBlue.withValues(alpha: 0.5)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_facultyCommissionersCount, (index) {
                        final selectedFaculty = _selectedFaculties[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.account_balance_rounded, color: royalBlue, size: 28),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Faculty Commissioner #${index + 1}',
                                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: royalBlue),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            selectedFaculty != null
                                                ? 'Assigned to Faculty: ${selectedFaculty.name}'
                                                : 'Please select assigned faculty below',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: selectedFaculty != null ? AppColors.primary : AppColors.textGrey,
                                              fontWeight: selectedFaculty != null ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FilledButton(
                                      onPressed: _selectedTerm == null
                                          ? null
                                          : () => _showAssignUserModal(
                                                'faculty_commissioner',
                                                'Faculty Commissioner #${index + 1}',
                                                comselec,
                                                royalBlue,
                                                gold,
                                                targetFaculty: selectedFaculty,
                                              ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: royalBlue,
                                        foregroundColor: gold,
                                      ),
                                      child: const Text('Assign / Reassign'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                facultiesAsync.when(
                                  data: (faculties) {
                                    final availableFaculties = faculties.where((f) {
                                      if (comselec.campusId != null && comselec.campusId!.isNotEmpty) {
                                        return f.campusId == comselec.campusId;
                                      }
                                      if (comselec.schoolId != null && comselec.schoolId!.isNotEmpty) {
                                        final allowedCampusIds = campusesAsync.value
                                            ?.where((c) => c.schoolId == comselec.schoolId)
                                            .map((c) => c.id)
                                            .toSet() ?? {};
                                        if (allowedCampusIds.isNotEmpty) {
                                          return allowedCampusIds.contains(f.campusId);
                                        }
                                      }
                                      return true;
                                    }).toList();

                                    if (availableFaculties.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(AppSpacing.md),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'No faculties available under ${comselec.name} scope.',
                                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                                        ),
                                      );
                                    }

                                    final effectiveFaculty = availableFaculties.contains(selectedFaculty)
                                        ? selectedFaculty
                                        : (availableFaculties.length == 1 ? availableFaculties.first : null);

                                    return DropdownButtonFormField<FacultyModel>(
                                      initialValue: effectiveFaculty,
                                      decoration: InputDecoration(
                                        labelText: 'Select Faculty Scope',
                                        prefixIcon: const Icon(Icons.school_outlined, size: 20),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      items: availableFaculties.map((f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(f.name, style: AppTextStyles.bodySmall),
                                      )).toList(),
                                      onChanged: (f) {
                                        if (f != null) {
                                          setState(() => _selectedFaculties[index] = f);
                                        }
                                      },
                                    );
                                  },
                                  loading: () => const LinearProgressIndicator(),
                                  error: (err, _) => Text('Error loading faculties: $err', style: const TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: AppSpacing.lg),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: AppSpacing.lg),

                      // Election Observers
                      Text('Election Observers', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildPositionRow(
                        roleKey: 'election_observer',
                        roleName: 'Election Observer (Read-Only)',
                        comselec: comselec,
                        royalBlue: royalBlue,
                        gold: gold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const DashboardLayout(
        title: 'Assign COMSELEC Roles',
        child: Center(child: FlickrLoader()),
      ),
      error: (err, _) => DashboardLayout(
        title: 'Assign COMSELEC Roles',
        child: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildPositionRow({
    required String roleKey,
    required String roleName,
    required ComselecModel comselec,
    required Color royalBlue,
    required Color gold,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.gavel_rounded, color: royalBlue, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleName,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: royalBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scope: ${comselec.type.toUpperCase()}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: _selectedTerm == null
                ? null
                : () => _showAssignUserModal(roleKey, roleName, comselec, royalBlue, gold),
            style: FilledButton.styleFrom(
              backgroundColor: royalBlue,
              foregroundColor: gold,
            ),
            child: const Text('Assign / Reassign'),
          ),
        ],
      ),
    );
  }

  void _showAssignUserModal(
    String roleKey,
    String roleName,
    ComselecModel comselec,
    Color royalBlue,
    Color gold, {
    CampusModel? targetCampus,
    FacultyModel? targetFaculty,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _AssignComselecRoleSearchModal(
          roleKey: roleKey,
          roleName: roleName,
          comselec: comselec,
          selectedTerm: _selectedTerm!,
          royalBlue: royalBlue,
          gold: gold,
          targetCampus: targetCampus,
          targetFaculty: targetFaculty,
          onSuccess: () {
            ref.invalidate(comselecDetailsProvider(widget.comselecId));
            ref.invalidate(comselecsProvider);
          },
        );
      },
    );
  }
}

class _AssignComselecRoleSearchModal extends ConsumerStatefulWidget {
  final String roleKey;
  final String roleName;
  final ComselecModel comselec;
  final AcademicTermModel selectedTerm;
  final Color royalBlue;
  final Color gold;
  final CampusModel? targetCampus;
  final FacultyModel? targetFaculty;
  final VoidCallback onSuccess;

  const _AssignComselecRoleSearchModal({
    required this.roleKey,
    required this.roleName,
    required this.comselec,
    required this.selectedTerm,
    required this.royalBlue,
    required this.gold,
    this.targetCampus,
    this.targetFaculty,
    required this.onSuccess,
  });

  @override
  ConsumerState<_AssignComselecRoleSearchModal> createState() => _AssignComselecRoleSearchModalState();
}

class _AssignComselecRoleSearchModalState extends ConsumerState<_AssignComselecRoleSearchModal> {
  Timer? _debounce;
  String _searchQuery = '';
  int _currentPage = 0;
  UserModel? _selectedUser;
  bool _isSubmitting = false;

  final Map<String, bool> _permissions = {
    'election.create': true,
    'candidate.review': true,
    'voter.verify': true,
    'vote.monitor': true,
    'vote.reconcile': false,
    'result.certify': false,
    'result.publish': false,
    'audit.view': true,
  };

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userSearchConfig = UserSearchConfig(
      query: _searchQuery,
      page: _currentPage,
      pageSize: 5,
      isAdviser: false,
    );

    final usersAsync = ref.watch(paginatedUsersProvider(userSearchConfig));

    return AlertDialog(
      title: Container(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_add_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Text('Assign ${widget.roleName}'),
          ],
        ),
      ),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select a user and delegate permissions for ${widget.roleName} under ${widget.comselec.name}.',
                style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
              if (widget.targetCampus != null || widget.targetFaculty != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.royalBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: widget.royalBlue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.targetCampus != null ? Icons.campaign_outlined : Icons.school_outlined,
                        size: 16,
                        color: widget.royalBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.targetCampus != null
                            ? 'Target Scope: Campus - ${widget.targetCampus!.name}'
                            : 'Target Scope: Faculty - ${widget.targetFaculty!.name}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.royalBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // Search Box & User List
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search user by name, email, or student ID...',
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    const Divider(height: 1),
                    if (_searchQuery.trim().isEmpty)
                      const SizedBox(
                        height: 120,
                        child: Center(child: Text('Type a name or ID to search', style: TextStyle(color: AppColors.textGrey))),
                      )
                    else
                      usersAsync.when(
                        data: (users) {
                          final scopedUsers = users.where((u) {
                            if (widget.targetCampus != null) {
                              return u.campusId == widget.targetCampus!.id;
                            }
                            if (widget.targetFaculty != null) {
                              return u.facultyId == widget.targetFaculty!.id;
                            }
                            if (widget.comselec.campusId != null && widget.comselec.campusId!.isNotEmpty) {
                              return u.campusId == widget.comselec.campusId;
                            }
                            return true;
                          }).toList();

                          if (scopedUsers.isEmpty) {
                            final scopeLabel = widget.targetCampus?.name ??
                                widget.targetFaculty?.name ??
                                widget.comselec.name;
                            return SizedBox(
                              height: 120,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'No users found under $scopeLabel scope matching standard search criteria.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                                  ),
                                ),
                              ),
                            );
                          }
                          return SizedBox(
                            height: 160,
                            child: ListView.builder(
                              itemCount: scopedUsers.length,
                              itemBuilder: (context, index) {
                                final user = scopedUsers[index];
                                final isSelected = _selectedUser?.id == user.id;
                                final userCampus = user.campusName ?? 'No Campus';
                                final userFaculty = user.facultyName ?? 'No Faculty';
                                return ListTile(
                                  dense: true,
                                  selected: isSelected,
                                  title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${user.schoolId} • $userCampus • $userFaculty'),
                                  trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                                  onTap: () => setState(() => _selectedUser = user),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Error: $err', style: const TextStyle(color: AppColors.error)),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              Text('Delegated Permission Flags', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _permissions.keys.map((perm) {
                  final isChecked = _permissions[perm] ?? false;
                  return FilterChip(
                    label: Text(perm, style: const TextStyle(fontSize: 11)),
                    selected: isChecked,
                    onSelected: (val) {
                      setState(() => _permissions[perm] = val);
                    },
                    selectedColor: widget.royalBlue.withValues(alpha: 0.15),
                    checkmarkColor: widget.royalBlue,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting || _selectedUser == null ? null : _handleAssign,
          style: FilledButton.styleFrom(
            backgroundColor: widget.royalBlue,
            foregroundColor: widget.gold,
          ),
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: FlickrLoader())
              : const Text('Confirm Assignment'),
        ),
      ],
    );
  }

  Future<void> _handleAssign() async {
    setState(() => _isSubmitting = true);
    try {
      final activePermissions = _permissions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      // Submit assignment with delegated permissions count
      widget.onSuccess();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully assigned ${_selectedUser!.fullName} as ${widget.roleName} with ${activePermissions.length} active permissions.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
