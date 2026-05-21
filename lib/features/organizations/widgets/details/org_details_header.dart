import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/organization_model.dart';

class OrgDetailsHeader extends StatelessWidget {
  final OrganizationModel org;

  const OrgDetailsHeader({super.key, required this.org});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Banner and Logo Section
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Banner
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                image: org.bannerUrl != null
                    ? DecorationImage(
                        image: NetworkImage(org.bannerUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: org.bannerUrl == null
                  ? Center(
                      child: Icon(
                        Icons.business_rounded,
                        size: 64,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    )
                  : null,
            ),
            // Logo overlay
            Positioned(
              bottom: -40,
              left: AppSpacing.xl,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.background,
                  backgroundImage: org.logoUrl != null ? NetworkImage(org.logoUrl!) : null,
                  child: org.logoUrl == null
                      ? Text(
                          org.code[0],
                          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        // Title and Info Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          org.name,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _buildStatusBadge(org.status),
                        const SizedBox(width: AppSpacing.sm),
                        _buildPremiumBadge('Accredited', Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${org.code} • ${org.facultyProgram ?? "General"} • ${org.type.replaceAll('-', ' ').toUpperCase()}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        _buildInfoChip(Icons.person_outline_rounded, 'Adviser: ${org.adviserName ?? "Not Assigned"}'),
                        _buildInfoChip(Icons.people_outline_rounded, '${org.memberCount} Members'),
                        _buildInfoChip(Icons.event_available_rounded, '12 Upcoming Events'),
                        _buildPremiumBadge('Top Performing', AppColors.primary, isSmall: true),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBadge(String label, Color color, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 8 : 10, vertical: isSmall ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: isSmall ? 9 : 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz_rounded),
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'add_member', child: Text('Add Member')),
            const PopupMenuItem(value: 'assign_officer', child: Text('Assign Officer')),
            const PopupMenuItem(value: 'create_event', child: Text('Create Event')),
            const PopupMenuItem(value: 'manage_fees', child: Text('Manage Fees')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'archive', child: Text('Archive Organization', style: TextStyle(color: AppColors.error))),
          ],
        ),
      ],
    );
  }
}
