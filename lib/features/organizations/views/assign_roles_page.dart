import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/route_names.dart';
import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../models/organization_model.dart';
import '../models/organization_membership_model.dart';
import '../providers/organization_provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../academic_structure/models/academic_term_model.dart';
import '../../users/providers/users_provider.dart';

class AssignRolesPage extends ConsumerStatefulWidget {
  final String orgId;
  const AssignRolesPage({super.key, required this.orgId});

  @override
  ConsumerState<AssignRolesPage> createState() => _AssignRolesPageState();
}

class _AssignRolesPageState extends ConsumerState<AssignRolesPage> {
  AcademicTermModel? _selectedTerm;

  @override
  void initState() {
    super.initState();
    // Pre-select active term if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final activeTerm = await ref.read(activeTermProvider.future);
      if (mounted) setState(() => _selectedTerm = activeTerm);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orgAsync = ref.watch(organizationProvider(widget.orgId));
    final termsAsync = ref.watch(academicTermsProvider);
    final rolesAsync = ref.watch(availableRolesProvider);
    final officersAsync = ref.watch(organizationOfficersProvider(widget.orgId));

    const royalBlue = Color(0xFF041E42);
    const gold = Color(0xFFC5A059);

    return orgAsync.when(
      data: (org) {
        if (org == null) {
          return const DashboardLayout(
            title: 'Assign Roles',
            child: Center(child: Text('Organization not found')),
          );
        }

        return DashboardLayout(
          title: 'Assign Roles',
          onBack: () => context.goNamed(
            RouteNames.organizationDetails,
            pathParameters: {'id': widget.orgId},
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs
                Row(
                  children: [
                    Icon(Icons.business_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => context.goNamed(RouteNames.organizations),
                      child: Text(
                        'Organizations',
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
                        RouteNames.organizationDetails,
                        pathParameters: {'id': widget.orgId},
                      ),
                      child: Text(
                        org.code,
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
                        'Assign Leadership & Adviser Roles',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Assign users directly to specific roles for the selected academic term.',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Academic Term Selector
                      Text('Academic Term', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      termsAsync.when(
                        data: (terms) => DropdownButtonFormField<AcademicTermModel>(
                          value: _selectedTerm,
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

                      // Static Roles List
                      Text('Available Positions', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      rolesAsync.when(
                        data: (roles) {
                          final userProfile = ref.watch(userProfileProvider).value;
                          final isSuperAdmin = userProfile?.role == 'super_admin';

                          // Filter governance roles
                          final governanceRoles = roles.where((r) {
                            final name = r['name'].toString().toLowerCase();
                            final level = r['hierarchy_level'] as int? ?? 0;
                            final isBaseRole = ['super admin', 'students', 'member', 'instructor'].contains(name);
                            if (isBaseRole) return false;
                            if (!isSuperAdmin && level > 15) return false;
                            return true;
                          }).toList();

                          // Create a combined list containing Adviser first, then governance roles
                          return officersAsync.when(
                            data: (currentOfficers) {
                              final activeOfficers = currentOfficers.where((o) =>
                                o.status == 'active' && o.academicTermId == _selectedTerm?.id
                              ).toList();

                              // Get Adviser Role
                              final adviserRole = roles.firstWhere(
                                (r) => r['name'].toString().toLowerCase() == 'adviser',
                                orElse: () => {'id': '', 'name': 'Adviser'},
                              );

                              return ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  // Adviser Row
                                  _buildRoleAssignmentRow(
                                    roleId: adviserRole['id'] ?? '',
                                    roleName: 'Adviser',
                                    isAdviser: true,
                                    org: org,
                                    activeOfficers: activeOfficers,
                                    royalBlue: royalBlue,
                                    gold: gold,
                                  ),
                                  const Divider(height: 24),
                                  // Governance Positions
                                  ...governanceRoles.map((role) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: _buildRoleAssignmentRow(
                                        roleId: role['id'],
                                        roleName: role['name'],
                                        isAdviser: false,
                                        org: org,
                                        activeOfficers: activeOfficers,
                                        royalBlue: royalBlue,
                                        gold: gold,
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                            loading: () => const Center(child: FlickrLoader()),
                            error: (err, _) => Text('Error loading assignees: $err', style: const TextStyle(color: AppColors.error)),
                          );
                        },
                        loading: () => const Center(child: FlickrLoader()),
                        error: (err, _) => Text('Error loading roles: $err', style: const TextStyle(color: AppColors.error)),
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
        title: 'Assign Roles',
        child: Center(child: FlickrLoader()),
      ),
      error: (err, _) => DashboardLayout(
        title: 'Assign Roles',
        child: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildRoleAssignmentRow({
    required String roleId,
    required String roleName,
    required bool isAdviser,
    required OrganizationModel org,
    required List<dynamic> activeOfficers,
    required Color royalBlue,
    required Color gold,
  }) {
    OrganizationMembershipModel? assignment;
    for (final o in activeOfficers) {
      if (o.roleId == roleId) {
        assignment = o;
        break;
      }
    }

    final assignedUser = assignment?.user;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            isAdviser ? Icons.school_rounded : Icons.military_tech_rounded,
            color: royalBlue,
            size: 28,
          ),
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
                if (assignedUser != null)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.border,
                        backgroundImage: assignedUser.avatarUrl != null ? NetworkImage(assignedUser.avatarUrl!) : null,
                        child: assignedUser.avatarUrl == null ? const Icon(Icons.person, size: 10, color: AppColors.textGrey) : null,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${assignedUser.fullName} (${assignedUser.schoolId})',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                else
                  Text(
                    'No assignee currently',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          FilledButton(
            onPressed: _selectedTerm == null
                ? null
                : () => _showAssignUserModal(roleId, roleName, isAdviser, org, royalBlue, gold),
            style: FilledButton.styleFrom(
              backgroundColor: royalBlue,
              foregroundColor: gold,
            ),
            child: Text(assignedUser != null ? 'Reassign' : 'Assign'),
          ),
        ],
      ),
    );
  }

  void _showAssignUserModal(
    String roleId,
    String roleName,
    bool isAdviser,
    OrganizationModel org,
    Color royalBlue,
    Color gold,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _AssignRoleSearchModal(
          roleId: roleId,
          roleName: roleName,
          isAdviser: isAdviser,
          org: org,
          selectedTerm: _selectedTerm!,
          royalBlue: royalBlue,
          gold: gold,
          onSuccess: () {
            // Refresh officers provider to load newly assigned roles
            ref.invalidate(organizationOfficersProvider(widget.orgId));
            ref.invalidate(organizationMembersProvider(widget.orgId));
            ref.invalidate(organizationProvider(widget.orgId));
            ref.invalidate(organizationsProvider);
            ref.invalidate(userOrganizationsProvider);
          },
        );
      },
    );
  }
}

class _AssignRoleSearchModal extends ConsumerStatefulWidget {
  final String roleId;
  final String roleName;
  final bool isAdviser;
  final OrganizationModel org;
  final AcademicTermModel selectedTerm;
  final Color royalBlue;
  final Color gold;
  final VoidCallback onSuccess;

  const _AssignRoleSearchModal({
    required this.roleId,
    required this.roleName,
    required this.isAdviser,
    required this.org,
    required this.selectedTerm,
    required this.royalBlue,
    required this.gold,
    required this.onSuccess,
  });

  @override
  ConsumerState<_AssignRoleSearchModal> createState() => _AssignRoleSearchModalState();
}

class _AssignRoleSearchModalState extends ConsumerState<_AssignRoleSearchModal> {
  Timer? _debounce;
  String _searchQuery = '';
  int _currentPage = 0;
  UserModel? _selectedUser;
  bool _isSubmitting = false;

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

  String? _getEligibilityError(UserModel user) {
    if (widget.isAdviser) {
      if (user.campusId != widget.org.campusId) {
        return 'Adviser does not belong to this campus';
      }
    } else {
      if (widget.org.type == 'campus-based' || widget.org.type == 'comselec') {
        if (user.campusId != widget.org.campusId) {
          return 'Student does not belong to this campus';
        }
      } else if (widget.org.type == 'faculty-based') {
        if (user.facultyId != widget.org.facultyId) {
          return 'Student does not belong to this faculty';
        }
      } else if (widget.org.type == 'program-based') {
        if (user.programId != widget.org.programId) {
          return 'Student does not belong to this program';
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userSearchConfig = UserSearchConfig(
      query: _searchQuery,
      page: _currentPage,
      pageSize: 5,
      isAdviser: widget.isAdviser,
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
            Icon(
              widget.isAdviser ? Icons.person_add_alt_1_rounded : Icons.assignment_ind_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Text('Assign ${widget.roleName}'),
          ],
        ),
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select a user to assign to the position of ${widget.roleName} for academic term ${widget.selectedTerm.academicYear} - ${widget.selectedTerm.semester}.',
              style: const TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Search Box and List
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: widget.isAdviser ? 'Search name or school ID...' : 'Search name, email, or school ID...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textGrey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  if (_searchQuery.trim().isEmpty)
                    const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'Type a name or ID to search',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                    )
                  else
                    usersAsync.when(
                    data: (users) {
                      return Column(
                        children: [
                          Container(
                            height: 180,
                            child: users.isEmpty
                                ? const Center(child: Text('No users found matching query', style: TextStyle(color: AppColors.textGrey)))
                                : ListView.builder(
                                    itemCount: users.length,
                                    itemBuilder: (context, index) {
                                      final user = users[index];
                                      final error = _getEligibilityError(user);
                                      final isSelected = _selectedUser?.id == user.id;

                                      return ListTile(
                                        dense: true,
                                        enabled: error == null,
                                        hoverColor: AppColors.primary.withOpacity(0.05),
                                        selectedTileColor: widget.royalBlue.withOpacity(0.08),
                                        selected: isSelected,
                                        leading: CircleAvatar(
                                          backgroundColor: isSelected ? widget.royalBlue : AppColors.border,
                                          foregroundColor: isSelected ? widget.gold : widget.royalBlue,
                                          radius: 14,
                                          child: Text(
                                            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ),
                                        title: Text(
                                          user.fullName,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? widget.royalBlue : (error != null ? AppColors.textGrey.withOpacity(0.5) : AppColors.textDark),
                                          ),
                                        ),
                                        subtitle: Text('${user.schoolId} • ${user.email}'),
                                        trailing: isSelected
                                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18)
                                            : (error != null
                                                ? Tooltip(
                                                    message: error,
                                                    child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                                                  )
                                                : null),
                                        onTap: () {
                                          setState(() => _selectedUser = user);
                                        },
                                      );
                                    },
                                  ),
                          ),
                          const Divider(height: 1, color: AppColors.border),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: _currentPage == 0
                                      ? null
                                      : () {
                                          setState(() {
                                            _currentPage--;
                                          });
                                        },
                                  icon: const Icon(Icons.chevron_left_rounded, size: 18),
                                  label: const Text('Prev'),
                                ),
                                Text('Page ${_currentPage + 1}'),
                                TextButton(
                                  onPressed: users.length < 5
                                      ? null
                                      : () {
                                          setState(() {
                                            _currentPage++;
                                          });
                                        },
                                  child: Row(
                                    children: [
                                      const Text('Next'),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.chevron_right_rounded, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error: $err', style: const TextStyle(color: AppColors.error)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting || _selectedUser == null
              ? null
              : () => _handleAssign(context),
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

  Future<void> _handleAssign(BuildContext context) async {
    setState(() => _isSubmitting = true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) throw Exception('Authentication required');

      await ref.read(organizationRepositoryProvider).assignOfficer(
        userId: _selectedUser!.id!,
        orgId: widget.org.id,
        roleId: widget.roleId,
        termId: widget.selectedTerm.id,
        assignedBy: currentUser.id!,
        workspaceType: widget.org.type,
      );

      widget.onSuccess();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully assigned ${_selectedUser!.fullName} as ${widget.roleName}'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
