import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/organization_model.dart';
import '../../providers/organization_provider.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../academic_structure/providers/term_provider.dart';
import '../../../academic_structure/models/academic_term_model.dart';
import '../../../users/providers/users_provider.dart';

class AssignAdviserDialog extends ConsumerStatefulWidget {
  final OrganizationModel? org;

  const AssignAdviserDialog({super.key, this.org});

  @override
  ConsumerState<AssignAdviserDialog> createState() => _AssignAdviserDialogState();
}

class _AssignAdviserDialogState extends ConsumerState<AssignAdviserDialog> {
  OrganizationModel? _selectedOrg;
  UserModel? _selectedUser;
  AcademicTermModel? _selectedTerm;
  bool _isSubmitting = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedOrg = widget.org;
    // Pre-select active term if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final activeTerm = await ref.read(activeTermProvider.future);
      if (mounted) setState(() => _selectedTerm = activeTerm);
    });
  }

  String? _getEligibilityError(UserModel user, OrganizationModel org) {
    // Adviser must belong to the same campus as the organization
    if (user.campusId != org.campusId) {
      return 'Adviser does not belong to this campus';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final orgsAsync = ref.watch(organizationsProvider);
    final termsAsync = ref.watch(academicTermsProvider);
    final usersAsync = ref.watch(allUsersProvider);

    const royalBlue = Color(0xFF041E42);
    const gold = Color(0xFFC5A059);

    return AlertDialog(
      title: Container(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            const Text('Assign Adviser'),
          ],
        ),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assign an Instructor/faculty member as the official Adviser of an organization.',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Term Selection
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

              const SizedBox(height: AppSpacing.lg),

              // Organization Selection (only if not passed from org details)
              if (widget.org == null) ...[
                Text('Organization', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                orgsAsync.when(
                  data: (orgs) => DropdownButtonFormField<OrganizationModel>(
                    value: _selectedOrg,
                    decoration: InputDecoration(
                      hintText: 'Select Organization',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.business_rounded, size: 20),
                    ),
                    items: orgs.map((org) => DropdownMenuItem(
                      value: org,
                      child: Text('${org.name} (${org.code})'),
                    )).toList(),
                    onChanged: (val) => setState(() {
                      _selectedOrg = val;
                      _selectedUser = null; // Reset user selection as eligibility might change
                    }),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading organizations: $err', style: const TextStyle(color: AppColors.error)),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Adviser Selection (Instructors/Faculty)
              Text('Adviser (Instructor / Faculty)', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              usersAsync.when(
                data: (users) {
                  // Filter for non-student and non-super-admin users
                  final eligibleUsers = users.where((u) {
                    final role = u.role.toLowerCase();
                    return !['student', 'voter', 'super_admin'].contains(role);
                  }).toList();

                  final filteredUsers = eligibleUsers.where((u) {
                    final query = _searchQuery.toLowerCase();
                    return u.fullName.toLowerCase().contains(query) ||
                        u.schoolId.toLowerCase().contains(query) ||
                        u.email.toLowerCase().contains(query);
                  }).toList();

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search by name, email, or school ID...',
                            prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.textGrey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        Container(
                          height: 200,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: filteredUsers.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(AppSpacing.md),
                                    child: Text('No matching advisers found', style: TextStyle(color: AppColors.textGrey)),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = filteredUsers[index];
                                    final error = _selectedOrg != null ? _getEligibilityError(user, _selectedOrg!) : null;
                                    final isSelected = _selectedUser?.id == user.id;

                                    return ListTile(
                                      dense: true,
                                      enabled: error == null,
                                      hoverColor: AppColors.primary.withOpacity(0.05),
                                      selectedTileColor: royalBlue.withOpacity(0.08),
                                      selected: isSelected,
                                      leading: CircleAvatar(
                                        backgroundColor: isSelected ? royalBlue : AppColors.border,
                                        foregroundColor: isSelected ? gold : royalBlue,
                                        radius: 16,
                                        child: Text(
                                          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      title: Text(
                                        user.fullName,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? royalBlue : (error != null ? AppColors.textGrey.withOpacity(0.5) : AppColors.textDark),
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${user.schoolId} • ${user.email}',
                                        style: TextStyle(
                                          color: isSelected ? royalBlue.withOpacity(0.7) : AppColors.textGrey,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                                          : (error != null
                                              ? Tooltip(
                                                  message: error,
                                                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                                                )
                                              : null),
                                      onTap: () {
                                        setState(() => _selectedUser = user);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading instructors: $err', style: const TextStyle(color: AppColors.error)),
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
        FilledButton.icon(
          onPressed: _isSubmitting || _selectedUser == null || _selectedOrg == null || _selectedTerm == null || _getEligibilityError(_selectedUser!, _selectedOrg!) != null
              ? null
              : _handleAssign,
          icon: _isSubmitting 
              ? const SizedBox(width: 20, height: 20, child: FlickrLoader())
              : const Icon(Icons.verified_user_rounded),
          label: const Text('Confirm Assignment'),
          style: FilledButton.styleFrom(
            backgroundColor: royalBlue,
            foregroundColor: gold,
          ),
        ),
      ],
    );
  }

  Future<void> _handleAssign() async {
    setState(() => _isSubmitting = true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) throw Exception('Authentication required');

      final roles = await ref.read(availableRolesProvider.future);
      final adviserRole = roles.firstWhere(
        (r) => r['name'].toString().toLowerCase() == 'adviser',
        orElse: () => throw Exception('Adviser role not found in database. Please run migrations/seed.'),
      );

      await ref.read(organizationRepositoryProvider).assignOfficer(
        userId: _selectedUser!.id!,
        orgId: _selectedOrg!.id,
        roleId: adviserRole['id'],
        termId: _selectedTerm!.id,
        assignedBy: currentUser.id!,
        workspaceType: _selectedOrg!.type,
      );

      if (mounted) {
        // Refresh providers to reflect new adviser assignment
        ref.invalidate(organizationOfficersProvider(_selectedOrg!.id));
        ref.invalidate(organizationMembersProvider(_selectedOrg!.id));
        ref.invalidate(organizationProvider(_selectedOrg!.id));
        ref.invalidate(organizationsProvider);
        ref.invalidate(userOrganizationsProvider);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully assigned ${_selectedUser!.fullName} as Adviser of ${_selectedOrg!.name} for ${_selectedTerm!.academicYear}'),
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
