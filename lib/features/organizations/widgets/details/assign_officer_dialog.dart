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

class AssignOfficerDialog extends ConsumerStatefulWidget {
  final OrganizationModel org;

  const AssignOfficerDialog({super.key, required this.org});

  @override
  ConsumerState<AssignOfficerDialog> createState() => _AssignOfficerDialogState();
}

class _AssignOfficerDialogState extends ConsumerState<AssignOfficerDialog> {
  UserModel? _selectedUser;
  Map<String, dynamic>? _selectedRole;
  AcademicTermModel? _selectedTerm;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-select active term if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final activeTerm = await ref.read(activeTermProvider.future);
      if (mounted) setState(() => _selectedTerm = activeTerm);
    });
  }

  String? _getEligibilityError(UserModel user) {
    if (widget.org.type == 'campus-based') {
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
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(organizationMembersProvider(widget.org.id));
    final termsAsync = ref.watch(academicTermsProvider);
    final rolesAsync = ref.watch(availableRolesProvider);
    
    const royalBlue = Color(0xFF041E42); // Example Royal Blue
    const gold = Color(0xFFC5A059); // Example Gold

    return AlertDialog(
      title: Container(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const Icon(Icons.gavel_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            const Text('Governance Assignment'),
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
                'Assign a student to a leadership position for a specific academic term.',
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
              
              // Member Selection
              Text('Student Officer', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              membersAsync.when(
                data: (members) => DropdownButtonFormField<UserModel>(
                  value: _selectedUser,
                  decoration: InputDecoration(
                    hintText: 'Choose an eligible member',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person_search_rounded, size: 20),
                  ),
                  items: members.map((user) {
                    final error = _getEligibilityError(user);
                    return DropdownMenuItem(
                      value: user,
                      enabled: error == null,
                      child: Row(
                        children: [
                          Text('${user.fullName} (${user.schoolId})'),
                          if (error != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedUser = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading members: $err', style: const TextStyle(color: AppColors.error)),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Role Selection
              Text('Governance Position', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              rolesAsync.when(
                data: (roles) {
                  final filteredRoles = roles.where((r) {
                    final name = r['name'].toString().toLowerCase();
                    return !['super admin', 'students', 'member', 'instructor'].contains(name);
                  }).toList();

                  return DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      hintText: 'Select position',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.military_tech_rounded, size: 20),
                    ),
                    items: filteredRoles.map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role['name']),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedRole = val),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading roles: $err', style: const TextStyle(color: AppColors.error)),
              ),
              
              if (_selectedUser != null && _getEligibilityError(_selectedUser!) != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _getEligibilityError(_selectedUser!)!,
                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                  ),
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
          onPressed: _isSubmitting || _selectedUser == null || _selectedRole == null || _selectedTerm == null || _getEligibilityError(_selectedUser!) != null
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

      await ref.read(organizationRepositoryProvider).assignOfficer(
        userId: _selectedUser!.id!,
        orgId: widget.org.id,
        roleId: _selectedRole!['id'],
        termId: _selectedTerm!.id,
        assignedBy: currentUser.id!,
      );

      if (mounted) {
        // Refresh providers
        ref.invalidate(organizationOfficersProvider(widget.org.id));
        ref.invalidate(organizationMembersProvider(widget.org.id));
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully assigned ${_selectedUser!.fullName} as ${_selectedRole!['name']} for ${_selectedTerm!.academicYear}'),
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
