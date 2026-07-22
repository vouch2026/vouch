import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/organization_provider.dart';
import '../../models/organization_model.dart';
import '../../../events/models/event_model.dart';
import '../../../finance/models/fee_model.dart';
import '../../../../core/config/supabase_config.dart';

final orgEventsProvider = FutureProvider.family<List<EventModel>, OrganizationModel>((ref, org) async {
  final isInstitutional = org.type == 'campus-based' || org.type == 'institutional';
  final isFaculty = org.type == 'faculty-based' || org.type == 'faculty';
  
  final scopeType = isInstitutional 
      ? 'Institutional' 
      : (isFaculty ? 'Faculty' : 'Program');
  
  final scopeId = isInstitutional 
      ? org.campusId 
      : (isFaculty ? org.facultyId : org.programId);

  if (scopeId == null) return [];
  
  final response = await SupabaseConfig.client
      .from('events')
      .select()
      .eq('scope_type', scopeType)
      .eq('scope_id', scopeId);
      
  return (response as List).map((json) => EventModel.fromJson(json)).toList();
});

final orgFeesProvider = FutureProvider.family<List<FeeModel>, OrganizationModel>((ref, org) async {
  final isInstitutional = org.type == 'campus-based' || org.type == 'institutional';
  final isFaculty = org.type == 'faculty-based' || org.type == 'faculty';
  
  final scopeType = isInstitutional 
      ? 'Institutional' 
      : (isFaculty ? 'Faculty' : 'Program');
  
  final scopeId = isInstitutional 
      ? org.campusId 
      : (isFaculty ? org.facultyId : org.programId);

  if (scopeId == null) return [];
  
  final response = await SupabaseConfig.client
      .from('fees')
      .select()
      .eq('scope_type', scopeType)
      .eq('scope_id', scopeId);
      
  return (response as List).map((json) => FeeModel.fromJson(json)).toList();
});

class OrgDetailsAnalyticsCards extends ConsumerWidget {
  final String orgId;
  const OrgDetailsAnalyticsCards({super.key, required this.orgId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(organizationProvider(orgId));
    final membersAsync = ref.watch(organizationMembersProvider(orgId));
    final officersAsync = ref.watch(organizationOfficersProvider(orgId));

    return orgAsync.when(
      data: (org) {
        if (org == null) return const SizedBox.shrink();

        final eventsAsync = ref.watch(orgEventsProvider(org));
        final feesAsync = ref.watch(orgFeesProvider(org));

        final totalMembers = membersAsync.valueOrNull?.length ?? 0;
        final totalOfficers = officersAsync.valueOrNull?.length ?? 0;
        final mandatoryEvents = eventsAsync.valueOrNull?.where((e) => e.isMandatory).length ?? 0;
        final mandatoryFees = feesAsync.valueOrNull?.where((f) => f.isMandatory).length ?? 0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
            
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: constraints.maxWidth > 1200 ? 1.8 : 2.5,
              children: [
                _AnalyticsCard(
                  title: 'Total Members',
                  value: totalMembers.toString(),
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primary,
                ),
                _AnalyticsCard(
                  title: 'Total Officers',
                  value: totalOfficers.toString(),
                  icon: Icons.admin_panel_settings_rounded,
                  color: Colors.orange,
                ),
                _AnalyticsCard(
                  title: 'Mandatory Events',
                  value: mandatoryEvents.toString(),
                  icon: Icons.event_available_rounded,
                  color: Colors.purple,
                ),
                _AnalyticsCard(
                  title: 'Mandatory Fees',
                  value: mandatoryFees.toString(),
                  icon: Icons.payments_rounded,
                  color: Colors.green,
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: FlickrLoader()),
      error: (err, _) => Center(child: Text('Error loading stats: $err')),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
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
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
