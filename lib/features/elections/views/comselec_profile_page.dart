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
import '../models/comselec_model.dart';
import '../providers/comselec_provider.dart';

class ComselecProfilePage extends ConsumerWidget {
  final String id;

  const ComselecProfilePage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comselecAsync = ref.watch(comselecDetailsProvider(id));

    return DashboardLayout(
      title: 'COMSELEC Branch Profile',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.comselecsManager);
        }
      },
      child: comselecAsync.when(
        data: (comselec) {
          if (comselec == null) {
            return const Center(child: Text('COMSELEC Branch not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Breadcrumbs
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                  child: Row(
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
                      Text(
                        comselec.code,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 2. Profile Hero Header
                _ComselecProfileHeader(comselec: comselec),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3. Analytics Metric Cards
                      _ComselecProfileAnalyticsCards(comselec: comselec),
                      const SizedBox(height: AppSpacing.xl),

                      // 4. Main Tabbed Content Area
                      _ComselecProfileTabsView(comselec: comselec),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (err, _) => Center(child: Text('Error loading COMSELEC profile: $err')),
      ),
    );
  }
}

class _ComselecProfileHeader extends StatelessWidget {
  final ComselecModel comselec;

  const _ComselecProfileHeader({required this.comselec});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner Area
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: comselec.bannerUrl != null
                  ? DecorationImage(
                      image: NetworkImage(comselec.bannerUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),

          // Main Header Info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: comselec.logoUrl != null
                        ? Image.network(comselec.logoUrl!, fit: BoxFit.cover)
                        : Image.asset('assets/logos/vouch.webp', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Name & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comselec.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              comselec.type.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${comselec.code} • ${comselec.campusName ?? 'All Campuses'}',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[700]),
                      ),
                      if (comselec.description != null && comselec.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          comselec.description!,
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Assign Roles Action Button
                FilledButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      RouteNames.comselecAssignRoles,
                      pathParameters: {'id': comselec.id},
                    );
                  },
                  icon: const Icon(Icons.manage_accounts_rounded, size: 18),
                  label: const Text('Assign Commissioners & Roles'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComselecProfileAnalyticsCards extends StatelessWidget {
  final ComselecModel comselec;

  const _ComselecProfileAnalyticsCards({required this.comselec});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Registered Voters',
            value: '${comselec.memberCount}',
            icon: Icons.people_outline_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: _MetricCard(
            title: 'Active Elections',
            value: '3',
            icon: Icons.how_to_vote_rounded,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: _MetricCard(
            title: 'Assigned Officials',
            value: '6',
            icon: Icons.group_work_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: _MetricCard(
            title: 'Offline Stations',
            value: '2',
            icon: Icons.edgesensor_high_outlined,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComselecProfileTabsView extends StatelessWidget {
  final ComselecModel comselec;

  const _ComselecProfileTabsView({required this.comselec});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textGrey,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(icon: Icon(Icons.group_work_outlined), text: 'Commissioners & Officials'),
                Tab(icon: Icon(Icons.how_to_vote_rounded), text: 'Elections List'),
                Tab(icon: Icon(Icons.settings_outlined), text: 'Branch Settings'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 400,
            child: TabBarView(
              children: [
                _CommissionersRosterTab(comselecId: comselec.id),
                _ElectionsListTab(comselecId: comselec.id),
                _SettingsTab(comselec: comselec),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommissionersRosterTab extends StatelessWidget {
  final String comselecId;

  const _CommissionersRosterTab({required this.comselecId});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('COMSELEC Chairman', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Dr. Maria Santos • Chairmanship Office'),
            trailing: Chip(label: Text('CHAIRMAN'), backgroundColor: AppColors.accent),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text('COMSELEC Co-Chairman', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Prof. Juan Dela Cruz • Co-Chairmanship Office'),
            trailing: Chip(label: Text('CO-CHAIRMAN')),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.badge_outlined)),
            title: Text('Campus Commissioner', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Alex Rivera • Main Campus'),
            trailing: Chip(label: Text('CAMPUS COMMISSIONER')),
          ),
        ],
      ),
    );
  }
}

class _ElectionsListTab extends StatelessWidget {
  final String comselecId;

  const _ElectionsListTab({required this.comselecId});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: const Center(
        child: Text('Active elections under this branch will be displayed here.'),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  final ComselecModel comselec;

  const _SettingsTab({required this.comselec});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Require Chairman Signature'),
              subtitle: const Text('Enforce digital signature verification from Chairman on certification.'),
              value: comselec.requiresChairmanSignature,
              onChanged: null,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Require Commissioner Signature'),
              subtitle: const Text('Enforce commissioner digital signature on election reports.'),
              value: comselec.requiresCommissionerSignature,
              onChanged: null,
            ),
          ],
        ),
      ),
    );
  }
}
