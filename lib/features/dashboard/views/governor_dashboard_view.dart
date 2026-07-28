import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/offline_image_cache.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../organizations/providers/organization_provider.dart';
import '../../auth/models/user_model.dart';
import '../../events/models/event_model.dart';
import '../../events/providers/event_provider.dart';
import '../../events/views/student_event_details_page.dart';
import '../../finance/providers/finance_provider.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../core/providers/connectivity_provider.dart';

class GovernorDashboardView extends ConsumerWidget {
  const GovernorDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final org = workspace.selectedOrganization;
    final activeRole = workspace.activeRole;
    final isOffline = ref.watch(connectivityProvider).value == false;

    if (org == null) {
      return const Center(
        child: Text('No organization selected.'),
      );
    }

    final membersAsync = ref.watch(organizationMembersProvider(org.id));
    final eventsAsync = ref.watch(workspaceEventsProvider);
    final officersAsync = ref.watch(organizationOfficersProvider(org.id));
    final feesAsync = ref.watch(workspaceFeesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline indicator
              if (isOffline) ..._buildOfflineNotice(context),

              _buildOrgHeader(context, org, activeRole?.roleName ?? 'Member'),
              const SizedBox(height: AppSpacing.xl),
              
              eventsAsync.when(
                data: (events) => membersAsync.when(
                  data: (members) {
                    final upcomingEvents = events.where((e) => !e.isPastTimeout).toList();
                    upcomingEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));

                    final totalOfficers = officersAsync.valueOrNull?.length ?? 0;
                    final mandatoryFeesCount = feesAsync.valueOrNull?.where((f) => f.isMandatory).length ?? 0;

                    return Column(
                      children: [
                        if (isDesktop) 
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildKpiSection(context, org, activeRole?.roleName, members, events, totalOfficers, mandatoryFeesCount),
                                    const SizedBox(height: AppSpacing.lg),
                                    _buildUpcomingEvents(context, org, upcomingEvents),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildRecentActivity(org, members),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildKpiSection(context, org, activeRole?.roleName, members, events, totalOfficers, mandatoryFeesCount),
                              const SizedBox(height: AppSpacing.lg),
                              _buildUpcomingEvents(context, org, upcomingEvents),
                              const SizedBox(height: AppSpacing.lg),
                              _buildRecentActivity(org, members),
                            ],
                          ),
                      ],
                    );
                  },
                  loading: () => const Center(child: FlickrLoader()),
                  error: (err, _) => Center(child: Text('Error members: $err')),
                ),
                loading: () => const Center(child: FlickrLoader()),
                error: (err, _) => Center(child: Text('Error events: $err')),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildOfflineNotice(BuildContext context) {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'You\'re offline. Showing cached content.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
    ];
  }

  /// Builds the org banner using OfflineImageCache so it is cached for offline use.
  Widget _buildBanner(String? bannerUrl) {
    final fallback = Container(
      height: 120,
      width: double.infinity,
      color: AppColors.primary,
      child: const Opacity(
        opacity: 0.1,
        child: Icon(Icons.hub_rounded, size: 100, color: Colors.white),
      ),
    );

    if (bannerUrl == null || bannerUrl.trim().isEmpty) return fallback;

    final imageProvider = OfflineImageCache.get(bannerUrl);
    if (imageProvider == null) return fallback;

    return Image(
      image: imageProvider,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }

  Widget _buildOrgHeader(BuildContext context, dynamic org, String roleName) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: _buildBanner(org.bannerUrl),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 80, AppSpacing.xl, AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: OfflineImageCache.get(org.logoUrl),
                        child: org.logoUrl == null ? const Icon(Icons.business, color: Colors.white, size: 40) : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleName.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Container(
                    height: 140,
                    padding: const EdgeInsets.only(top: 40),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      org.name,
                      style: (MediaQuery.of(context).size.width >= 1024
                              ? AppTextStyles.displaySmall
                              : (MediaQuery.of(context).size.width >= 600
                                  ? AppTextStyles.headlineLarge
                                  : AppTextStyles.headlineSmall))
                          .copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSection(
    BuildContext context, 
    dynamic org, 
    String? roleName, 
    List<UserModel> members, 
    List<EventModel> events,
    int totalOfficers,
    int mandatoryFeesCount,
  ) {
    final bool isOfficer = roleName != null && roleName != 'Student';
    final totalMembers = members.length;
    final activeMembers = members.where((m) => m.status.toLowerCase() == 'active').length;
    final upcomingCount = events.where((e) => !e.isPastTimeout).length;
    final mandatoryEventsCount = events.where((e) => e.isMandatory).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final crossAxisCount = isMobile ? 1 : (constraints.maxWidth < 800 ? 2 : 3);
        final childAspectRatio = isMobile ? 3.5 : 1.5;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: childAspectRatio,
          children: [
            if (isOfficer) ...[
              _buildKpiCard(context, 'Total Members', totalMembers.toString(), Icons.people_outline_rounded, Colors.blue),
              _buildKpiCard(context, 'Active Members', activeMembers.toString(), Icons.check_circle_rounded, Colors.green),
              _buildKpiCard(context, 'Number of Officers', totalOfficers.toString(), Icons.badge_outlined, Colors.green),
              _buildKpiCard(context, 'Mandatory Event', mandatoryEventsCount.toString(), Icons.event_available_outlined, Colors.teal),
              _buildKpiCard(context, 'Upcoming Events', upcomingCount.toString(), Icons.event_outlined, Colors.purple),
              _buildKpiCard(context, 'Mandatory Fees', mandatoryFeesCount.toString(), Icons.receipt_long_outlined, Colors.red),
            ] else ...[
              _buildKpiCard(context, 'My Attendance', '92%', Icons.how_to_reg_outlined, Colors.green),
              _buildKpiCard(context, 'Pending Fees', '₱0', Icons.payments_outlined, Colors.teal),
              _buildKpiCard(context, 'Events Attended', '15', Icons.event_available_rounded, Colors.blue),
            ],
          ],
        );
      }
    );
  }


  Widget _buildKpiCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      final theme = Theme.of(context);
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Icon(Icons.trending_up_rounded, color: Colors.green, size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context, dynamic org, List<EventModel> events) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Events', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(child: Text('No upcoming events.')),
            )
          else
            ...events.take(3).map((e) => Column(
              children: [
                _buildEventTile(
                  context,
                  e, 
                  '${DateFormat.yMMMd().format(e.eventDate)} • ${TimeFormatter.formatDbTimeTo12Hour(e.timeInStart)}', 
                  e.isMandatory ? 'Mandatory' : 'Optional'
                ),
                if (e != events.take(3).last) const Divider(),
              ],
            )),
        ],
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, EventModel event, String date, String type) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentEventDetailsPage(event: event),
        ),
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
      ),
      title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$date • ${event.location}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: type == 'Mandatory' ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: type == 'Mandatory' ? Colors.red : Colors.green,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  Widget _buildRecentActivity(dynamic org, List<UserModel> members) {
    final recentMembers = [...members];
    recentMembers.sort((a, b) => (b.joinedAt ?? DateTime(2000)).compareTo(a.joinedAt ?? DateTime(2000)));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activities', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          if (recentMembers.isNotEmpty)
            _buildActivityItem('Member Joined', '${recentMembers.first.fullName} joined the organization.', 'Recently')
          else
            const Center(child: Text('No recent activities.')),
          
          _buildActivityItem('System Update', 'Workspace synchronization complete.', 'Today'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String desc, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
