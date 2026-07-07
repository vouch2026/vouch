import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/route_paths.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../providers/user_profile_provider.dart';
import '../controllers/user_controller.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart' as auth;

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
    _tabController = TabController(length: 6, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider(widget.id));

    return DashboardLayout(
      title: 'User Profile',
      child: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          
          return Column(
            children: [
              _buildBreadcrumbs(user),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHero(user),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTabBar(user),
                      Container(
                        constraints: const BoxConstraints(minHeight: 600),
                        color: AppColors.background,
                        child: [
                          _OverviewTab(user: user),
                          _OrganizationsTab(user: user),
                          _AttendanceTab(user: user),
                          _EventsTab(user: user),
                          _PaymentsTab(user: user),
                          _ActivityCardsTab(user: user),
                        ][_tabController.index],
                      ),
                    ],
                  ),
                ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
      child: Row(
        children: [
          Icon(Icons.people_outline_rounded, size: 16, color: AppColors.textGrey.withOpacity(0.5)),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => context.go(RoutePaths.users),
            child: Text('Users', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textGrey.withOpacity(0.5)),
          const SizedBox(width: 8),
          Text(user.fullName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProfileHero(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          
          if (isMobile) {
            return Column(
              children: [
                _buildAvatar(user, size: 100),
                const SizedBox(height: AppSpacing.md),
                _buildProfileInfo(user, isCenter: true),
                const SizedBox(height: AppSpacing.lg),
                _buildQuickActions(user, isFullWidth: true),
              ],
            );
          }
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(user, size: 120),
              const SizedBox(width: AppSpacing.xl),
              Expanded(child: _buildProfileInfo(user)),
              _buildQuickActions(user),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar(UserModel user, {double size = 120}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Icon(Icons.person_rounded, size: size * 0.5, color: AppColors.primary)
            : null,
      ),
    );
  }

  Widget _buildProfileInfo(UserModel user, {bool isCenter = false}) {
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
            _buildCountBadge(Icons.corporate_fare_outlined, '${user.organizationIds.length} Organizations'),
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
      if (user.status != 'archived')
        _ActionBtn(
          label: 'Archive User',
          icon: Icons.archive_outlined,
          onPressed: isLoading ? () {} : () => _updateUserStatus(user, 'archived'),
        ),
      if (user.status == 'archived')
        _ActionBtn(
          label: 'Restore User',
          icon: Icons.unarchive_outlined,
          onPressed: isLoading ? () {} : () => _updateUserStatus(user, 'active'),
          color: AppColors.success,
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
          Tab(text: 'Events'),
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          
          final content = [
            Expanded(
              flex: isDesktop ? 2 : 1,
              child: Column(
                children: [
                  _buildInfoCard(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    items: [
                      _InfoRow(label: 'Email', value: user.email),
                      const _InfoRow(label: 'Contact', value: '+63 912 345 6789'), // Mock
                      const _InfoRow(label: 'Address', value: 'Mati City, Davao Oriental'), // Mock
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInfoCard(
                    title: 'Academic Information',
                    icon: Icons.school_outlined,
                    items: [
                      const _InfoRow(label: 'Campus', value: 'DORSU Main Campus'),
                      _InfoRow(label: 'Faculty', value: user.facultyName ?? 'N/A'),
                      _InfoRow(label: 'Program', value: user.programName ?? 'N/A'),
                      if (user.yearLevel != null) _InfoRow(label: 'Year Level', value: user.yearLevelDisplay),
                    ],
                  ),

                ],
              ),
            ),
            if (isDesktop) const SizedBox(width: AppSpacing.lg),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildAnalyticsSummary(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildGovernanceSummary(),
                ],
              ),
            ),
          ];

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            );
          }
          
          return Column(
            children: [
              content[0],
              const SizedBox(height: AppSpacing.lg),
              _buildAnalyticsSummary(),
              const SizedBox(height: AppSpacing.lg),
              _buildGovernanceSummary(),
            ],
          );
        },
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

  Widget _buildAnalyticsSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Participation Metrics', style: AppTextStyles.titleSmall.copyWith(color: AppColors.white)),
          const SizedBox(height: AppSpacing.lg),
          const _AnalyticsItem(label: 'Attendance', value: '92%', icon: Icons.how_to_reg_outlined),
          const _AnalyticsItem(label: 'Payment Compliance', value: '100%', icon: Icons.payments_outlined),
          const _AnalyticsItem(label: 'Event Participation', value: '15', icon: Icons.event_available_outlined),
        ],
      ),
    );
  }

  Widget _buildGovernanceSummary() {
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
          Text('Governance Summary', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          const _GovernanceRoleItem(org: 'CSS Society', role: 'Treasurer'),
          const _GovernanceRoleItem(org: 'COMSELEC', role: 'Staff'),
          const _GovernanceRoleItem(org: 'SSC', role: 'Secretary'),
        ],
      ),
    );
  }
}

class _OrganizationsTab extends StatelessWidget {
  final UserModel user;
  const _OrganizationsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader('Joined Organizations', 'View and manage user memberships'),
          const SizedBox(height: AppSpacing.lg),
          _buildOrganizationTable(context),
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

  Widget _buildOrganizationTable(BuildContext context) {
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
            DataColumn(label: Text('Actions')),
          ],
          rows: [
            _buildOrgRow('CSS Society', 'Treasurer', 'Active', 'Sept 15, 2024'),
            _buildOrgRow('SSC', 'Secretary', 'Active', 'Aug 20, 2024'),
            _buildOrgRow('COMSELEC', 'Staff', 'Active', 'Oct 05, 2024'),
          ],
        ),
      ),
    );
  }

  DataRow _buildOrgRow(String org, String role, String status, String date) {
    return DataRow(cells: [
      DataCell(Text(org, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(role)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Text(status, style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(date)),
      DataCell(PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(child: Text('Change Role')),
          const PopupMenuItem(child: Text('Remove Membership')),
          const PopupMenuItem(child: Text('View Details')),
        ],
      )),
    ]);
  }
}

class _AttendanceTab extends StatelessWidget {
  final UserModel user;
  const _AttendanceTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attendance History', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                  Text('Overall participation rate: 92%', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Export Report'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildAttendanceAnalytics(),
          const SizedBox(height: AppSpacing.lg),
          _buildAttendanceTable(),
        ],
      ),
    );
  }

  Widget _buildAttendanceAnalytics() {
    return Row(
      children: [
        _AnalyticsCard(title: 'Present', value: '24', color: AppColors.success, icon: Icons.check_circle_outline),
        const SizedBox(width: AppSpacing.md),
        _AnalyticsCard(title: 'Late', value: '2', color: AppColors.warning, icon: Icons.access_time),
        const SizedBox(width: AppSpacing.md),
        _AnalyticsCard(title: 'Absent', value: '2', color: AppColors.error, icon: Icons.cancel_outlined),
        const SizedBox(width: AppSpacing.md),
        _AnalyticsCard(title: 'Excused', value: '1', color: AppColors.primary, icon: Icons.info_outline),
      ],
    );
  }

  Widget _buildAttendanceTable() {
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
          rows: [
            _buildAttendanceRow('Freshmen Orientation', 'Aug 25, 2024', 'Present', '08:00 AM', '05:00 PM'),
            _buildAttendanceRow('University Day', 'Sept 10, 2024', 'Late', '08:45 AM', '04:30 PM'),
            _buildAttendanceRow('General Assembly', 'Oct 12, 2024', 'Present', '01:00 PM', '04:00 PM'),
          ],
        ),
      ),
    );
  }

  DataRow _buildAttendanceRow(String event, String date, String status, String timeIn, String timeOut) {
    final statusColor = status == 'Present' ? AppColors.success : (status == 'Late' ? AppColors.warning : AppColors.error);
    return DataRow(cells: [
      DataCell(Text(event, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(date)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(timeIn)),
      DataCell(Text(timeOut)),
    ]);
  }
}

class _EventsTab extends StatelessWidget {
  final UserModel user;
  const _EventsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Event Participation', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.lg),
          _buildEventsTable(),
        ],
      ),
    );
  }

  Widget _buildEventsTable() {
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
            DataColumn(label: Text('Organization')),
            DataColumn(label: Text('Attendance')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Role')),
          ],
          rows: [
            const DataRow(cells: [
              DataCell(Text('Bootcamp 2024', style: TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text('CSS Society')),
              DataCell(Text('Present')),
              DataCell(Text('Oct 15, 2024')),
              DataCell(Text('Participant')),
            ]),
          ],
        ),
      ),
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  final UserModel user;
  const _PaymentsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AnalyticsCard(title: 'Total Paid', value: '₱ 2,500', color: AppColors.success, icon: Icons.payments_outlined),
              const SizedBox(width: AppSpacing.md),
              _AnalyticsCard(title: 'Balance', value: '₱ 500', color: AppColors.error, icon: Icons.account_balance_wallet_outlined),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Payment History', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          _buildPaymentsTable(),
        ],
      ),
    );
  }

  Widget _buildPaymentsTable() {
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
          rows: [
            _buildPaymentRow('CSS Membership Fee', '₱ 250.00', 'Paid', 'Aug 20, 2024', 'REF-00123'),
            _buildPaymentRow('SSG Development Fee', '₱ 150.00', 'Paid', 'Sept 05, 2024', 'REF-00456'),
            _buildPaymentRow('Acquaintance Party', '₱ 500.00', 'Pending', '---', '---'),
          ],
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
        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(date)),
      DataCell(Text(ref)),
    ]);
  }
}

class _ActivityCardsTab extends StatelessWidget {
  final UserModel user;
  const _ActivityCardsTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity Card Progress', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.lg),
          _buildProgressTracker(),
          const SizedBox(height: AppSpacing.xl),
          _buildSignaturesTable(),
        ],
      ),
    );
  }

  Widget _buildProgressTracker() {
    return Container(
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
              Text('75%', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: 0.75,
            minHeight: 12,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _StatusBadge(label: '6 Signed', color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              _StatusBadge(label: '2 Pending', color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturesTable() {
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
        rows: const [
          DataRow(cells: [
            DataCell(Text('Program Head', style: TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text('Signed', style: TextStyle(color: AppColors.success))),
            DataCell(Text('Dr. Jane Smith')),
            DataCell(Text('Nov 10, 2024')),
          ]),
          DataRow(cells: [
            DataCell(Text('Faculty Dean', style: TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text('Pending', style: TextStyle(color: AppColors.warning))),
            DataCell(Text('Dr. Robert Wilson')),
            DataCell(Text('---')),
          ]),
        ],
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

class _AnalyticsItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _AnalyticsItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.white.withOpacity(0.8))),
                Text(value, style: AppTextStyles.titleMedium.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GovernanceRoleItem extends StatelessWidget {
  final String org;
  final String role;
  const _GovernanceRoleItem({required this.org, required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text('$org → ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
          Text(role, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String name;
  final UserModel user;
  const _PlaceholderTab({required this.name, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 64, color: AppColors.textGrey.withOpacity(0.5)),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$name Tab coming soon',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Managing data for ${user.fullName}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
