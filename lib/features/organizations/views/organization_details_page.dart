import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../providers/organization_provider.dart';

class OrganizationDetailsPage extends ConsumerStatefulWidget {
  final String id;

  const OrganizationDetailsPage({super.key, required this.id});

  @override
  ConsumerState<OrganizationDetailsPage> createState() => _OrganizationDetailsPageState();
}

class _OrganizationDetailsPageState extends ConsumerState<OrganizationDetailsPage> with SingleTickerProviderStateMixin {
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
    final organizationAsync = ref.watch(organizationProvider(widget.id));

    return DashboardLayout(
      title: 'Organization Details',
      child: organizationAsync.when(
        data: (org) {
          if (org == null) return const Center(child: Text('Organization not found'));
          
          return Column(
            children: [
              _buildHeader(org),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Members'),
                  Tab(text: 'Officers'),
                  Tab(text: 'Events'),
                  Tab(text: 'Finance'),
                  Tab(text: 'Settings'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(org: org),
                    _PlaceholderTab(name: 'Members'),
                    _PlaceholderTab(name: 'Officers'),
                    _PlaceholderTab(name: 'Events'),
                    _PlaceholderTab(name: 'Finance'),
                    _PlaceholderTab(name: 'Settings'),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildHeader(org) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
            child: org.logoUrl == null ? Text(org.code[0], style: const TextStyle(fontSize: 24)) : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(org.name, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: AppSpacing.sm),
                    _StatusBadge(status: org.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${org.code} • ${org.facultyProgram ?? "General"}', 
                    style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 16),
                    const SizedBox(width: 4),
                    Text('Adviser: ${org.adviserName ?? "Not Assigned"}', style: AppTextStyles.bodySmall),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.people_outline_rounded, size: 16),
                    const SizedBox(width: 4),
                    Text('${org.memberCount} Members', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final dynamic org;
  const _OverviewTab({required this.org});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organization Summary', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Text(org.description ?? 'No description provided.', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          // More summary widgets...
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
    return Center(child: Text('$name Tab Content'));
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
