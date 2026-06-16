import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/organizations/providers/workspace_provider.dart';
import '../../../../features/organizations/providers/organization_provider.dart';
import '../../../../features/organizations/models/organization_model.dart';

class OrganizationSwitcher extends ConsumerStatefulWidget {
  const OrganizationSwitcher({super.key});

  @override
  ConsumerState<OrganizationSwitcher> createState() => _OrganizationSwitcherState();
}

class _OrganizationSwitcherState extends ConsumerState<OrganizationSwitcher> {
  bool _isSwitching = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final userOrgsAsync = ref.watch(userOrganizationsProvider);

    return userOrgsAsync.when(
      data: (orgs) => Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedOrg == null 
                  ? AppColors.primary.withValues(alpha: 0.3) 
                  : Colors.grey.shade200,
                width: selectedOrg == null ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: PopupMenuButton<OrganizationModel?>(
              offset: const Offset(0, 60),
              padding: EdgeInsets.zero,
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              itemBuilder: (context) => [
                ...orgs.map((org) => PopupMenuItem<OrganizationModel?>(
                      value: org,
                      child: _OrgItem(
                        name: org.name,
                        role: org.code,
                        logoUrl: org.logoUrl,
                        isSelected: selectedOrg?.id == org.id,
                      ),
                    )),
              ],
              onSelected: (org) async {
                if (org?.id == selectedOrg?.id && org != null) return;
                if (org == null) return;

                setState(() => _isSwitching = true);
                
                // Wait for the state update to be processed
                await ref.read(workspaceProvider.notifier).selectOrganization(org);
                
                if (mounted) {
                  // Always navigate to dashboard when switching workspaces to ensure view resets
                  context.go(RoutePaths.dashboard);
                  
                  setState(() => _isSwitching = false);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    _OrgAvatar(
                      logoUrl: selectedOrg?.logoUrl,
                      isGlobal: selectedOrg == null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedOrg?.name ?? 'Select Organization',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            selectedOrg != null 
                              ? (workspace.activeRole?.roleName ?? 'Member')
                              : 'Switch Workspace',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: selectedOrg == null ? AppColors.primary : AppColors.textGrey,
                              fontWeight: selectedOrg == null ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isSwitching)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: FlickrLoader(),
                      )
                    else
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey, size: 20),
                  ],
                ),
              ),
            ),
          ),
          if (_isSwitching)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
        ],
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: SizedBox(width: 20, height: 20, child: FlickrLoader())),
      ),
      error: (err, _) => const SizedBox.shrink(),
    );
  }
}

class _OrgAvatar extends StatelessWidget {
  final String? logoUrl;
  final bool isGlobal;

  const _OrgAvatar({this.logoUrl, this.isGlobal = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isGlobal ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        image: logoUrl != null
            ? DecorationImage(image: NetworkImage(logoUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: logoUrl == null
          ? Icon(
              isGlobal ? Icons.business_rounded : Icons.corporate_fare_rounded,
              color: isGlobal ? AppColors.primary : Colors.grey.shade400,
              size: 20,
            )
          : null,
    );
  }
}

class _OrgItem extends StatelessWidget {
  final String name;
  final String role;
  final String? logoUrl;
  final bool isGlobal;
  final bool isSelected;

  const _OrgItem({
    required this.name,
    required this.role,
    this.logoUrl,
    this.isGlobal = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OrgAvatar(logoUrl: logoUrl, isGlobal: isGlobal),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                role,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.7) : AppColors.textGrey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (isSelected)
          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
      ],
    );
  }
}
