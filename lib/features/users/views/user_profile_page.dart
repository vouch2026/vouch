import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../providers/user_profile_provider.dart';
import '../../auth/models/user_model.dart';
import '../models/student_profile_model.dart';
import '../models/instructor_profile_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider(widget.id));

    return DashboardLayout(
      title: 'User Profile',
      child: userAsync.when(
        data: (data) {
          if (data == null) return const Center(child: Text('User not found'));
          
          final user = data['user'] as UserModel;
          final dynamic profile = data['profile'];
          
          return Column(
            children: [
              _buildProfileHeader(user, profile),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(user: user, profile: profile),
                    const _PlaceholderTab(name: 'Organizations'),
                    const _PlaceholderTab(name: 'Attendance'),
                    const _PlaceholderTab(name: 'Payments'),
                    const _PlaceholderTab(name: 'Governance'),
                    const _PlaceholderTab(name: 'Settings'),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, dynamic profile) {
    final theme = Theme.of(context);
    final status = profile is StudentProfileModel ? profile.status : (profile as InstructorProfileModel).status;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null ? const Icon(Icons.person_rounded, size: 40) : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.fullName ?? 'Unknown', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: AppSpacing.sm),
                    _StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(user.email, style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Text(
                  profile is StudentProfileModel 
                    ? '${profile.studentNumber} • ${profile.programName} • Year ${profile.yearLevel}'
                    : '${(profile as InstructorProfileModel).instructorId} • ${profile.position.toUpperCase()} • ${profile.facultyName}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Account'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.lock_reset_rounded, size: 18),
                label: const Text('Reset PW'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Organizations'),
          Tab(text: 'Attendance'),
          Tab(text: 'Payments'),
          Tab(text: 'Governance'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final UserModel user;
  final dynamic profile;
  const _OverviewTab({required this.user, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Academic Assignment', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _buildInfoGrid(context),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.lg,
      children: [
        _InfoItem(label: 'Campus', value: profile.campusName ?? 'Not Assigned'),
        _InfoItem(label: 'Faculty', value: profile.facultyName ?? 'Not Assigned'),
        if (profile is StudentProfileModel) ...[
          _InfoItem(label: 'Program', value: profile.programName ?? 'Not Assigned'),
          _InfoItem(label: 'Year Level', value: '${profile.yearLevel}'),
          _InfoItem(label: 'Student Number', value: profile.studentNumber),
        ] else ...[
          _InfoItem(label: 'Position', value: (profile as InstructorProfileModel).position.toUpperCase()),
          _InfoItem(label: 'Instructor ID', value: profile.instructorId),
        ],
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
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
    return Center(child: Text('$name Content Placeholder'));
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'active' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
