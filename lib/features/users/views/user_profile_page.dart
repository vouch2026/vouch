import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/route_paths.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../providers/user_profile_provider.dart';
import '../controllers/user_controller.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart' as auth;
import '../../organizations/providers/organization_provider.dart';
import '../../organizations/repositories/organization_repository.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../finance/providers/finance_provider.dart';
import '../../finance/models/student_payment_model.dart';
import '../../activity_cards/providers/activity_card_provider.dart';
import '../../activity_cards/models/activity_card_models.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  final String id;
  const UserProfilePage({super.key, required this.id});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateUserStatus(UserModel user, String status) async {
    final success = await ref.read(userControllerProvider.notifier).updateStatus(user.id!, status);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Account status updated to $status' : 'Failed to update status'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation(UserModel user) async {
    final pageContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete User Entirely'),
        content: Text(
          'Are you sure you want to delete ${user.fullName} (${user.schoolId})? '
          'This action is permanent and will delete the user from both the database and authentication.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref.read(userControllerProvider.notifier).deleteUser(user.id!);
                if (pageContext.mounted) {
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  pageContext.pop();
                }
              } catch (e) {
                if (pageContext.mounted) {
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete user: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: 60,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(140),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(120),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider(widget.id));

    return DashboardLayout(
      title: 'User Profile',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/users');
        }
      },
      child: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          
          final membershipsAsync = ref.watch(userMembershipsProvider(user.id!));
          final orgsCount = membershipsAsync.valueOrNull?.length ?? user.organizationIds.length;
          
          return Stack(
            children: [
              Positioned.fill(child: _buildBackgroundDecorations()),
              Column(
                children: [
                  _buildBreadcrumbs(user),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildProfileHero(user, orgsCount: orgsCount),
                          const SizedBox(height: AppSpacing.lg),
                          _buildTabBar(user),
                          Container(
                            constraints: const BoxConstraints(minHeight: 600),
                            color: Colors.transparent,
                            child: [
                              _OverviewTab(user: user),
                              _OrganizationsTab(user: user),
                              _AttendanceTab(user: user),
                              _PaymentsTab(user: user),
                              _ActivityCardsTab(user: user),
                            ][_tabController.index],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBreadcrumbs(UserModel user) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final topPadding = isMobile ? 16.0 : 24.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, topPadding, AppSpacing.lg, 0),
      child: Row(
        children: [
          Icon(Icons.people_outline_rounded, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/users');
              }
            },
            child: Text(
              'Users',
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
            user.fullName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHero(UserModel user, {required int orgsCount}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.white,
                AppColors.primary.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              
              if (isMobile) {
                return Column(
                  children: [
                    _buildAvatar(user, size: 100),
                    const SizedBox(height: AppSpacing.md),
                    _buildProfileInfo(user, orgsCount: orgsCount, isCenter: true),
                    const SizedBox(height: AppSpacing.lg),
                    _buildQuickActions(user, isFullWidth: true),
                  ],
                );
              }
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(user, size: 120),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(child: _buildProfileInfo(user, orgsCount: orgsCount)),
                  const SizedBox(width: AppSpacing.lg),
                  _buildQuickActions(user),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel user, {double size = 120}) {
    final placeholder = user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Text(
                placeholder,
                style: GoogleFonts.poppins(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildProfileInfo(UserModel user, {required int orgsCount, bool isCenter = false}) {
    return Column(
      crossAxisAlignment: isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.fullName,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildStatusChip(user.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'ID: ${user.schoolId}',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          alignment: isCenter ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _buildRoleBadge(user.roleDisplay),
            if (user.programName != null) _buildRoleBadge(user.programName!),
            _buildCountBadge(Icons.corporate_fare_outlined, '$orgsCount Organization${orgsCount == 1 ? "" : "s"}'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'suspended':
      case 'rejected':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCountBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(UserModel user, {bool isFullWidth = false}) {
    final currentUserAsync = ref.watch(auth.userProfileProvider);
    final isSuperAdmin = currentUserAsync.value?.role == 'super_admin';
    
    // Only super admins can see and perform these actions
    if (!isSuperAdmin) return const SizedBox.shrink();

    final userController = ref.watch(userControllerProvider);
    final isLoading = userController.isLoading;

    final actions = [
      _ActionBtn(
        label: 'Edit User',
        icon: Icons.edit_outlined,
        onPressed: isLoading ? () {} : () {},
        isPrimary: true,
      ),
      if (user.status == 'pending' || user.status == 'rejected')
        _ActionBtn(
          label: 'Activate Account',
          icon: Icons.check_circle_outline,
          onPressed: isLoading ? () {} : () => _updateUserStatus(user, 'active'),
          color: AppColors.success,
        ),
      if (user.status == 'suspended')
        _ActionBtn(
          label: 'Approve User',
          icon: Icons.check_circle_outline,
          onPressed: isLoading ? () {} : () => _updateUserStatus(user, 'active'),
          color: AppColors.success,
        ),
      if (user.status == 'active')
        _ActionBtn(
          label: 'Suspend Account',
          icon: Icons.block_flipped,
          onPressed: isLoading ? () {} : () => _updateUserStatus(user, 'suspended'),
          color: AppColors.error,
        ),
      _ActionBtn(
        label: 'Delete User',
        icon: Icons.delete_forever_outlined,
        onPressed: isLoading ? () {} : () => _showDeleteConfirmation(user),
        color: AppColors.error,
      ),
    ];

    if (isFullWidth) {
      return Column(
        children: actions.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: SizedBox(width: double.infinity, child: a),
        )).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 200,
          child: Column(
            children: actions.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SizedBox(width: double.infinity, child: a),
            )).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        PopupMenuButton(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('More Actions', style: AppTextStyles.labelMedium),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text('Assign Organization')),
            const PopupMenuItem(child: Text('View Audit Logs')),
            const PopupMenuItem(child: Text('Manage Permissions')),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar(UserModel user) {
    return Container(
      color: AppColors.white,
      width: double.infinity,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textGrey,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        onTap: (index) => setState(() {}),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Organizations'),
          Tab(text: 'Attendance'),
          Tab(text: 'Payments'),
          Tab(text: 'Activity Cards'),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color? color;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    final effectiveColor = color ?? AppColors.textDark;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: effectiveColor),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveColor,
        side: BorderSide(color: color?.withOpacity(0.5) ?? AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final UserModel user;
  const _OverviewTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    final personalCard = _buildInfoCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      items: [
        _InfoRow(label: 'ID No.', value: user.schoolId),
        _InfoRow(label: 'Name', value: user.fullName),
        _InfoRow(label: 'Email', value: user.email),
      ],
    );

    final academicCard = _buildInfoCard(
      title: 'Academic Information',
      icon: Icons.school_outlined,
      items: [
        const _InfoRow(label: 'Campus', value: 'DORSU Main Campus'),
        _InfoRow(label: 'Faculty', value: user.facultyName ?? 'N/A'),
        _InfoRow(label: 'Program', value: user.programName ?? 'N/A'),
        _InfoRow(label: 'Year Level', value: user.yearLevelDisplay),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: personalCard),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: academicCard),
              ],
            )
          : Column(
              children: [
                personalCard,
                const SizedBox(height: AppSpacing.lg),
                academicCard,
              ],
            ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required List<_InfoRow> items}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _OrganizationsTab extends ConsumerWidget {
  final UserModel user;
  const _OrganizationsTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(userMembershipsProvider(user.id!));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader('Joined Organizations', 'View and manage user memberships'),
          const SizedBox(height: AppSpacing.lg),
          membershipsAsync.when(
            data: (memberships) {
              if (memberships.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(child: Text('Not a member of any organization yet.')),
                );
              }
              return _buildOrganizationTable(context, memberships);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
        Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildOrganizationTable(BuildContext context, List<UserOrganizationMembershipInfo> memberships) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Organization')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Joined Date')),
          ],
          rows: memberships.map((m) {
            final dateStr = m.membership.joinedAt != null
                ? DateFormat('MMM dd, yyyy').format(m.membership.joinedAt!)
                : 'N/A';
            return _buildOrgRow(
              m.organization.name,
              m.membership.roleName ?? 'Member',
              m.membership.status.toUpperCase(),
              dateStr,
            );
          }).toList(),
        ),
      ),
    );
  }

  DataRow _buildOrgRow(String org, String role, String status, String date) {
    final isActive = status.toLowerCase() == 'active';
    final statusColor = isActive ? AppColors.success : AppColors.textGrey;
    
    return DataRow(cells: [
      DataCell(Text(org, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(role)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      )),
      DataCell(Text(date)),
    ]);
  }
}

class _AttendanceTab extends ConsumerWidget {
  final UserModel user;
  const _AttendanceTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(userAttendanceHistoryProvider(user.id!));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: attendanceAsync.when(
        data: (history) {
          int presentCount = 0;
          int lateCount = 0;
          int absentCount = 0;
          int excusedCount = 0;

          for (var att in history) {
            final status = (att['status'] as String? ?? '').toLowerCase();
            if (status == 'present') {
              presentCount++;
            } else if (status == 'late') {
              lateCount++;
            } else if (status == 'absent') {
              absentCount++;
            } else if (status == 'excused') {
              excusedCount++;
            }
          }

          final totalEvents = history.length;
          final rate = totalEvents == 0
              ? 100
              : ((presentCount + lateCount + excusedCount) / totalEvents * 100).round();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Attendance History', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                      Text('Overall participation rate: $rate%', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final cards = [
                    _AnalyticsCard(title: 'Present', value: presentCount.toString(), color: AppColors.success, icon: Icons.check_circle_outline),
                    _AnalyticsCard(title: 'Late', value: lateCount.toString(), color: AppColors.warning, icon: Icons.access_time),
                    _AnalyticsCard(title: 'Absent', value: absentCount.toString(), color: AppColors.error, icon: Icons.cancel_outlined),
                    _AnalyticsCard(title: 'Excused', value: excusedCount.toString(), color: AppColors.primary, icon: Icons.info_outline),
                  ];

                  if (screenWidth > 900) {
                    return Row(
                      children: [
                        cards[0],
                        const SizedBox(width: AppSpacing.md),
                        cards[1],
                        const SizedBox(width: AppSpacing.md),
                        cards[2],
                        const SizedBox(width: AppSpacing.md),
                        cards[3],
                      ],
                    );
                  } else if (screenWidth > 550) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            cards[0],
                            const SizedBox(width: AppSpacing.md),
                            cards[1],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            cards[2],
                            const SizedBox(width: AppSpacing.md),
                            cards[3],
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Row(children: [cards[0]]),
                        const SizedBox(height: AppSpacing.md),
                        Row(children: [cards[1]]),
                        const SizedBox(height: AppSpacing.md),
                        Row(children: [cards[2]]),
                        const SizedBox(height: AppSpacing.md),
                        Row(children: [cards[3]]),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              if (history.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(child: Text('No attendance records found.')),
                )
              else
                _buildAttendanceTable(history),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildAttendanceTable(List<Map<String, dynamic>> history) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Event')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Time In')),
            DataColumn(label: Text('Time Out')),
          ],
          rows: history.map((att) {
            final event = att['event'] as Map<String, dynamic>?;
            final eventName = event?['name'] as String? ?? 'Unknown Event';
            final eventDateRaw = event?['event_date'] as String?;
            final dateStr = eventDateRaw != null
                ? DateFormat('MMM dd, yyyy').format(DateTime.parse(eventDateRaw))
                : 'N/A';
            final status = att['status'] as String? ?? 'Pending';
            final timeInRaw = att['actual_time_in'] as String?;
            final timeOutRaw = att['actual_time_out'] as String?;

            final timeInStr = timeInRaw != null
                ? DateFormat('hh:mm a').format(DateTime.parse(timeInRaw))
                : '---';
            final timeOutStr = timeOutRaw != null
                ? DateFormat('hh:mm a').format(DateTime.parse(timeOutRaw))
                : '---';

            return _buildAttendanceRow(eventName, dateStr, status, timeInStr, timeOutStr);
          }).toList(),
        ),
      ),
    );
  }

  DataRow _buildAttendanceRow(String event, String date, String status, String timeIn, String timeOut) {
    final statusLower = status.toLowerCase();
    final statusColor = statusLower == 'present'
        ? AppColors.success
        : (statusLower == 'late' ? AppColors.warning : AppColors.error);

    return DataRow(cells: [
      DataCell(Text(event, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(date)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
        child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(timeIn)),
      DataCell(Text(timeOut)),
    ]);
  }
}

class _PaymentsTab extends ConsumerWidget {
  final UserModel user;
  const _PaymentsTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(userStudentPaymentsProvider(user.id!));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: paymentsAsync.when(
        data: (payments) {
          double totalPaid = 0;
          double totalBalance = 0;

          for (var payment in payments) {
            if (payment.status == 'Paid') {
              totalPaid += payment.amountPaid;
            } else if (payment.status == 'Pending' || payment.status == 'Unpaid') {
              totalBalance += payment.amountPaid;
            }
          }

          final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱ ');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final cards = [
                    _AnalyticsCard(title: 'Total Paid', value: formatter.format(totalPaid), color: AppColors.success, icon: Icons.payments_outlined),
                    _AnalyticsCard(title: 'Balance / Pending', value: formatter.format(totalBalance), color: AppColors.error, icon: Icons.account_balance_wallet_outlined),
                  ];

                  if (screenWidth > 600) {
                    return Row(
                      children: [
                        cards[0],
                        const SizedBox(width: AppSpacing.md),
                        cards[1],
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Row(children: [cards[0]]),
                        const SizedBox(height: AppSpacing.md),
                        Row(children: [cards[1]]),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Payment History', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              if (payments.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(child: Text('No payment records found.')),
                )
              else
                _buildPaymentsTable(payments, formatter),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildPaymentsTable(List<StudentPaymentModel> payments, NumberFormat formatter) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Fee Name')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Date Paid')),
            DataColumn(label: Text('Reference')),
          ],
          rows: payments.map((payment) {
            final fee = payment.feeName ?? 'Unknown Fee';
            final amount = formatter.format(payment.amountPaid);
            final status = payment.status;
            final dateStr = payment.paidAt != null
                ? DateFormat('MMM dd, yyyy').format(payment.paidAt!)
                : '---';
            final ref = payment.referenceNumber;

            return _buildPaymentRow(fee, amount, status, dateStr, ref);
          }).toList(),
        ),
      ),
    );
  }

  DataRow _buildPaymentRow(String fee, String amount, String status, String date, String ref) {
    final statusColor = status == 'Paid' ? AppColors.success : AppColors.warning;
    return DataRow(cells: [
      DataCell(Text(fee, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(amount)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
        child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(date)),
      DataCell(Text(ref)),
    ]);
  }
}

class _ActivityCardsTab extends ConsumerWidget {
  final UserModel user;
  const _ActivityCardsTab({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(studentActivityCardsByIdProvider(user.id!));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(child: Text('No active activity cards found for this student.')),
            );
          }

          final card = cards.first;
          final signedCount = card.signatures.where((s) => s.status == SignatureStatus.signed).length;
          final pendingCount = card.signatures.where((s) => s.status == SignatureStatus.pending).length;
          
          final double progress = card.completionPercentage / 100.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${card.organizationName} Activity Card Progress', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Overall Clearance Status', style: AppTextStyles.titleMedium),
                        Text(
                          '${card.completionPercentage.round()}%',
                          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _StatusBadge(label: '$signedCount Signed', color: AppColors.success),
                        const SizedBox(width: AppSpacing.sm),
                        _StatusBadge(label: '$pendingCount Pending', color: AppColors.warning),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Required Signatures Workflow', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              _buildSignaturesTable(card.signatures),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSignaturesTable(List<ActivityCardSignature> signatures) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Required Signature')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Signatory')),
          DataColumn(label: Text('Date Signed')),
        ],
        rows: signatures.map((sig) {
          final role = sig.roleName;
          final statusStr = sig.status.name.toUpperCase();
          final statusColor = sig.status == SignatureStatus.signed
              ? AppColors.success
              : (sig.status == SignatureStatus.pending ? AppColors.warning : AppColors.error);
          final signatory = sig.signedByUserName ?? '---';
          final dateStr = sig.signedAt != null
              ? DateFormat('MMM dd, yyyy').format(sig.signedAt!)
              : '---';

          return DataRow(cells: [
            DataCell(Text(role, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(statusStr, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))),
            DataCell(Text(signatory)),
            DataCell(Text(dateStr)),
          ]);
        }).toList(),
      ),
    );
  }
}



class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  const _AnalyticsCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey)),
                Text(value, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}


