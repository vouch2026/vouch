import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/organization_model.dart';

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
        return _MembersTab();
      case 'Officers':
        return _OfficersTab();
      case 'Attendance':
        return _AttendanceTab();
      case 'Finance':
        return _FinanceTab();
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

class _MembersTab extends StatelessWidget {
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
              Text('Organization Members', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Member'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildMembersTable(),
        ],
      ),
    );
  }

  Widget _buildMembersTable() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('Student Name $index', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('2022-00${100 + index} • BSIT • 3rd Year', style: AppTextStyles.bodySmall),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusBadge('Active'),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _OfficersTab extends StatelessWidget {
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
              Text('Organization Leadership', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.assignment_ind_rounded, size: 18),
                label: const Text('Assign Officer'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 3,
            children: [
              _buildOfficerCard('Governor', 'Juan Dela Cruz'),
              _buildOfficerCard('Vice Governor', 'Maria Clara'),
              _buildOfficerCard('Secretary', 'John Doe'),
              _buildOfficerCard('Treasurer', 'Jane Smith'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfficerCard(String role, String name) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const CircleAvatar(radius: 20, backgroundColor: AppColors.primary, child: Icon(Icons.security, color: Colors.white, size: 16)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(role, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
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
