import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/organization_model.dart';
import '../../models/organization_membership_model.dart';
import 'package:vouch_v2/features/organizations/providers/organization_provider.dart';
import 'package:vouch_v2/features/organizations/providers/workspace_provider.dart';
import '../../../auth/models/user_model.dart';
import '../../../academic_structure/providers/term_provider.dart';
import '../../../academic_structure/models/academic_term_model.dart';
import '../../../../core/config/supabase_config.dart';
import './assign_officer_dialog.dart';
import './assign_adviser_dialog.dart';
import '../../../sanctions/views/sanction_rules_page.dart';
import './organization_settings_panel.dart';

class OrgDetailsTabsView extends StatefulWidget {
  final OrganizationModel org;

  const OrgDetailsTabsView({super.key, required this.org});

  @override
  State<OrgDetailsTabsView> createState() => _OrgDetailsTabsViewState();
}

class _OrgDetailsTabsViewState extends State<OrgDetailsTabsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Overview',
    'Members',
    'Officers',
    'Events',
    'Attendance',
    'Finance',
    'Announcements',
    'Governance',
    'Analytics',
    'Documents',
    'Audit Logs',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.bodyMedium,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        SizedBox(
          height: 800, // Fixed height for demo, should be flexible in real app
          child: TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) => _buildTabContent(tab)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(String tabName) {
    switch (tabName) {
      case 'Overview':
        return _OverviewTab(org: widget.org);
      case 'Members':
        return _MembersTab(orgId: widget.org.id);
      case 'Officers':
        return _OfficersTab(org: widget.org);
      case 'Governance':
        return _GovernanceTab(org: widget.org);
      case 'Settings':
        return _SettingsTab(org: widget.org);
      case 'Attendance':
        return _AttendanceTab();
      case 'Finance':
        return _FinanceTab();
      case 'Audit Logs':
        return _AuditLogsTab(org: widget.org);
      default:
        return _PlaceholderTab(name: tabName);
    }
  }
}

class _AttendanceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance Analytics', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.lg),
          _buildAttendanceStats(),
          const SizedBox(height: AppSpacing.xl),
          _buildAttendanceLog(),
        ],
      ),
    );
  }

  Widget _buildAttendanceStats() {
    return Row(
      children: [
        Expanded(child: _buildMiniStat('Overall Rate', '88.4%', AppColors.success)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildMiniStat('On-time Rate', '72.1%', AppColors.primary)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildMiniStat('Excused Rate', '4.2%', AppColors.info)),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildAttendanceLog() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Events Attendance', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const ListTile(title: Text('Tech Summit 2026'), subtitle: Text('Date: May 12, 2026'), trailing: Text('94% Present', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
            const Divider(),
            const ListTile(title: Text('Web Dev Workshop'), subtitle: Text('Date: April 28, 2026'), trailing: Text('82% Present', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}

class _FinanceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Financial Overview', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add_card_rounded), label: const Text('Manage Fees')),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _buildFinancialCard('Available Funds', '₱124,500.00', Icons.account_balance_wallet_rounded, AppColors.success)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildFinancialCard('Pending Collections', '₱12,400.00', Icons.pending_actions_rounded, AppColors.warning)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Recent Fees', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          _buildFeesList(),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.8))),
          Text(amount, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeesList() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            title: const Text('Membership Fee 2026'),
            subtitle: const Text('Due: June 30, 2026'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('₱100.00', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('92% Collected', style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MembersTab extends ConsumerWidget {
  final String orgId;
  const _MembersTab({required this.orgId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(organizationMembersProvider(orgId));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Organization Members', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Member'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          membersAsync.when(
            data: (members) => _buildMembersTable(context, members),
            loading: () => const Center(child: FlickrLoader()),
            error: (err, _) => Center(child: Text('Error loading members: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTable(BuildContext context, List<UserModel> members) {
    if (members.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textGrey.withOpacity(0.3)),
                const SizedBox(height: AppSpacing.md),
                Text('No members found', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey)),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: members.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = members[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            leading: CircleAvatar(
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null ? const Icon(Icons.person) : null,
            ),
            title: Text(user.fullName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('${user.schoolId} • ${user.programName ?? user.roleDisplay} • ${user.yearLevel ?? ""}${user.yearLevel != null ? " Year" : ""}', style: AppTextStyles.bodySmall),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusBadge(user.status),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.warning).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(), 
        style: TextStyle(
          color: isActive ? AppColors.success : AppColors.warning, 
          fontSize: 10, 
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _OfficersTab extends ConsumerWidget {
  final OrganizationModel org;
  const _OfficersTab({required this.org});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officersAsync = ref.watch(organizationOfficersProvider(org.id));
    final activeTermAsync = ref.watch(activeTermProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Leadership', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                  activeTermAsync.when(
                    data: (term) => Text(
                      term != null ? '${term.academicYear} - ${term.semester}' : 'No active term',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
              Row(
                children: [
                  if (org.type != 'comselec') ...[
                    OutlinedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AssignAdviserDialog(org: org),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Assign Adviser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF041E42),
                        side: const BorderSide(color: Color(0xFF041E42)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  FilledButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AssignOfficerDialog(org: org),
                    ),
                    icon: const Icon(Icons.assignment_ind_rounded, size: 18),
                    label: const Text('Assign Officer'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF041E42), // Royal Blue
                      foregroundColor: const Color(0xFFC5A059), // Gold
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          officersAsync.when(
            data: (officers) {
              final activeTerm = activeTermAsync.value;
              final currentTermOfficers = officers.where((o) => 
                o.status == 'active' && 
                (activeTerm == null || o.academicTermId == activeTerm.id)
              ).toList();
              
              if (currentTermOfficers.isEmpty) {
                return _buildEmptyState('No active officers assigned for this term.');
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 2.5,
                ),
                itemCount: currentTermOfficers.length,
                itemBuilder: (context, index) => _buildOfficerCard(currentTermOfficers[index]),
              );
            },
            loading: () => const Center(child: FlickrLoader()),
            error: (err, _) => Center(child: Text('Error loading officers: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl * 2),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.assignment_late_rounded, size: 64, color: AppColors.textGrey.withOpacity(0.2)),
              const SizedBox(height: AppSpacing.md),
              Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficerCard(OrganizationMembershipModel officer) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.primary.withOpacity(0.02),
            ],
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Hero(
              tag: 'officer-${officer.id}',
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: officer.user?.avatarUrl != null ? NetworkImage(officer.user!.avatarUrl!) : null,
                child: officer.user?.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      officer.roleName ?? 'OFFICER',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    officer.user?.fullName ?? 'Unknown',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    officer.user?.schoolId ?? '',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _GovernanceTab extends ConsumerWidget {
  final OrganizationModel org;
  const _GovernanceTab({required this.org});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officersAsync = ref.watch(organizationOfficersProvider(org.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Governance Hierarchy', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.lg),
          _buildHierarchyView(officersAsync, ref),
          const SizedBox(height: AppSpacing.xl * 2),
          Text('Governance History', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.lg),
          _buildHistoryTable(officersAsync),
        ],
      ),
    );
  }

  Widget _buildHierarchyView(AsyncValue<List<OrganizationMembershipModel>> officersAsync, WidgetRef ref) {
    final activeTermAsync = ref.watch(activeTermProvider);
    
    return officersAsync.when(
      data: (officers) {
        final activeTerm = activeTermAsync.value;
        final activeOfficers = officers.where((o) => 
          o.status == 'active' && 
          (activeTerm == null || o.academicTermId == activeTerm.id)
        ).toList();
        
        // Sort by hierarchy level
        activeOfficers.sort((a, b) => (b.hierarchyLevel ?? 0).compareTo(a.hierarchyLevel ?? 0));

        if (activeOfficers.isEmpty) return const Center(child: Text('No active governance structure for this term.'));

        return Center(
          child: Column(
            children: [
              if (activeOfficers.isNotEmpty) _buildHierarchyNode(activeOfficers.first),
              if (activeOfficers.length > 1) ...[
                const Icon(Icons.arrow_downward_rounded, color: AppColors.primary),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  alignment: WrapAlignment.center,
                  children: activeOfficers.skip(1).map((o) => _buildHierarchyNode(o, isSmall: true)).toList(),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildHierarchyNode(OrganizationMembershipModel officer, {bool isSmall = false}) {
    return Container(
      width: isSmall ? 200 : 300,
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            officer.roleName?.toUpperCase() ?? 'OFFICER',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          CircleAvatar(
            radius: isSmall ? 20 : 30,
            backgroundImage: officer.user?.avatarUrl != null ? NetworkImage(officer.user!.avatarUrl!) : null,
            child: officer.user?.avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(height: 8),
          Text(
            officer.user?.fullName ?? 'Unknown',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(AsyncValue<List<OrganizationMembershipModel>> officersAsync) {
    return officersAsync.when(
      data: (officers) {
        if (officers.isEmpty) return const Center(child: Text('No governance history available.'));

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: officers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final officer = officers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: officer.user?.avatarUrl != null ? NetworkImage(officer.user!.avatarUrl!) : null,
                  child: officer.user?.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(officer.user?.fullName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${officer.roleName} • ${officer.term?.academicYear ?? "N/A"} ${officer.term?.semester ?? ""}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (officer.status == 'active' ? AppColors.success : AppColors.textGrey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    officer.status.toUpperCase(),
                    style: TextStyle(
                      color: officer.status == 'active' ? AppColors.success : AppColors.textGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final OrganizationModel org;
  const _OverviewTab({required this.org});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Organization Summary'),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      org.description ?? 'No description provided for this organization.',
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionTitle('Mission & Vision'),
                    const SizedBox(height: AppSpacing.md),
                    _buildMissionVisionCard(),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                flex: 1,
                child: _buildInfoCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMissionVisionCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mission', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text('To empower students through technology and community-driven innovation.', style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Text('Vision', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text('A globally recognized society of tech-driven leaders and innovators.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Information', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            _buildInfoRow('Code', org.code),
            _buildInfoRow('Category', org.type.toUpperCase()),
            _buildInfoRow('Campus', 'Mati Main Campus'),
            _buildInfoRow('Faculty', org.facultyProgram ?? 'N/A'),
            _buildInfoRow('Created', 'Sept 12, 2022'),
            _buildInfoRow('Status', 'Active'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
          Text(value, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  final OrganizationModel org;
  const _SettingsTab({required this.org});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OrganizationSettingsPanel(org: org);
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String name;
  const _PlaceholderTab({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 48, color: AppColors.textGrey.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          Text('$name module is under development', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey)),
        ],
      ),
    );
  }
}

class _AuditLogsTab extends ConsumerWidget {
  final OrganizationModel org;
  const _AuditLogsTab({required this.org});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = FutureProvider((ref) async {
      final client = SupabaseConfig.client;
      final response = await client
          .from('governance_audit_logs')
          .select('''
            *,
            performed_by:users!governance_audit_logs_performed_by_user_id_fkey (*),
            target_user:users!governance_audit_logs_target_user_id_fkey (*)
          ''')
          .eq('organization_id', org.id)
          .order('created_at', ascending: false);
      return response as List;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Governance Audit Logs', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          const Text('Tracking all leadership changes and governance actions.', style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: AppSpacing.lg),
          ref.watch(logsAsync).when(
            data: (logs) {
              if (logs.isEmpty) return const Center(child: Text('No audit logs found.'));
              
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final performedBy = log['performed_by']?['first_name'] ?? 'System';
                  final target = log['target_user']?['first_name'] ?? 'Unknown';
                  
                  return ListTile(
                    leading: const Icon(Icons.history_edu_rounded, color: AppColors.primary),
                    title: Text('Officer Assigned: $target'),
                    subtitle: Text('Performed by: $performedBy • ${DateTime.parse(log['created_at']).toLocal()}'),
                  );
                },
              );
            },
            loading: () => const Center(child: FlickrLoader()),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}
