import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/organizations/providers/workspace_provider.dart';
import '../../../../core/providers/sidebar_provider.dart';
import 'organization_switcher.dart';
import '../../../../core/config/sidebars/sidebar_config.dart';

class DynamicSidebar extends ConsumerStatefulWidget {
  const DynamicSidebar({super.key});

  @override
  ConsumerState<DynamicSidebar> createState() => _DynamicSidebarState();
}

class _DynamicSidebarState extends ConsumerState<DynamicSidebar> {
  late ScrollController _scrollController;
  String _projectVersion = 'Version Loading...';

  @override
  void initState() {
    super.initState();
    final initialOffset = ref.read(sidebarScrollOffsetProvider);
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
    _loadProjectVersion();
  }

  Future<void> _loadProjectVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _projectVersion = 'Version ${packageInfo.version}+${packageInfo.buildNumber}';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _projectVersion = 'Version 1.0.0';
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      ref.read(sidebarScrollOffsetProvider.notifier).state = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';
    final selectedOrg = workspace.selectedOrganization;
    final activeRole = workspace.activeRole;

    // Resolve sidebar sections based on role or super admin status
    final List<SidebarSectionConfig> sections;
    if (isSuperAdmin) {
      sections = [
        const SidebarSectionConfig(
          title: 'PERSONAL HUB',
          items: [
            SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
            SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
            SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
            SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
            SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
          ],
        ),
        const SidebarSectionConfig(
          title: 'SYSTEM ADMINISTRATION',
          items: [
            SidebarItemConfig(
              label: 'My Organizations',
              icon: Icons.corporate_fare_outlined,
              path: RoutePaths.organizations,
            ),
            SidebarItemConfig(
              label: 'My Comselec',
              icon: Icons.gavel_rounded,
              path: RoutePaths.comselecsManager,
            ),
            SidebarItemConfig(
              label: 'Academic Structure',
              icon: Icons.account_tree_outlined,
              path: RoutePaths.academicStructure,
            ),
            SidebarItemConfig(
              label: 'All Users',
              icon: Icons.people_outline_rounded,
              path: RoutePaths.users,
            ),
            SidebarItemConfig(
              label: 'Global Elections',
              icon: Icons.how_to_vote_rounded,
              path: RoutePaths.comselecDashboard,
            ),
          ],
        ),
      ];
    } else if (selectedOrg != null) {
      final roleKey = getSidebarRoleKey(activeRole?.roleName ?? 'Member');
      sections = roleSidebars[roleKey] ?? roleSidebars['member']!;
    } else {
      sections = [
        const SidebarSectionConfig(
          title: 'PERSONAL HUB',
          items: [
            SidebarItemConfig(label: 'Home', icon: Icons.home_outlined, path: RoutePaths.dashboard),
            SidebarItemConfig(label: 'Tasks', icon: Icons.assignment_turned_in_outlined, path: RoutePaths.tasks),
            SidebarItemConfig(label: 'Calendar', icon: Icons.calendar_today_outlined, path: RoutePaths.calendar),
            SidebarItemConfig(label: 'Schedule', icon: Icons.schedule_outlined, path: RoutePaths.schedule),
            SidebarItemConfig(label: 'Notifications', icon: Icons.notifications_none_rounded, path: RoutePaths.notifications),
          ],
        ),
      ];
    }

    final personalHubSections = sections.where((s) => s.title == 'PERSONAL HUB').toList();
    final workspaceSections = sections.where((s) => s.title != 'PERSONAL HUB').toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildBackgroundDecorations(),
          Column(
            children: [
              _buildSidebarHeader(context),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    ...personalHubSections.map((section) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SidebarHeader(label: section.title),
                          ...section.items.map((item) {
                            return _SidebarItem(
                              icon: item.icon,
                              label: item.label,
                              path: item.path,
                            );
                          }),
                        ],
                      );
                    }),
                    if (!isSuperAdmin) ...[
                      const _SectionDivider(),
                      const _SidebarHeader(label: 'WORKSPACE'),
                      const OrganizationSwitcher(),
                      if (selectedOrg != null) ...[
                        ...workspaceSections.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final section = entry.value;
                          final String title = section.title == 'WORKSPACE: DETAILS'
                              ? 'WORKSPACE: ${selectedOrg.code}'
                              : section.title;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (idx > 0) const _SectionDivider(),
                              _SidebarHeader(label: title),
                              ...section.items.map((item) {
                                return _SidebarItem(
                                  icon: item.icon,
                                  label: item.label,
                                  path: item.path,
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    ] else ...[
                      if (workspaceSections.isNotEmpty) ...[
                        const _SectionDivider(),
                        ...workspaceSections.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final section = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (idx > 0) const _SectionDivider(),
                              _SidebarHeader(label: section.title),
                              ...section.items.map((item) {
                                return _SidebarItem(
                                  icon: item.icon,
                                  label: item.label,
                                  path: item.path,
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    ],
                    const _SectionDivider(),
                    const _SidebarHeader(label: 'VOUCH'),
                    const _SidebarItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      path: RoutePaths.help,
                    ),
                    const _SidebarItem(
                      icon: Icons.info_outline_rounded,
                      label: 'About Us',
                      path: RoutePaths.aboutUs,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg, top: AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logos/vouch.png',
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '© ${DateTime.now().year} Jeslito G. Geverola. All rights reserved.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _projectVersion,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -40,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        topPadding > 0 ? topPadding + AppSpacing.md : AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logos/vouch.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: AppSpacing.sm),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Vou',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    TextSpan(
                      text: 'ch',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.menu_open_rounded, color: AppColors.primary),
            tooltip: 'Close Sidebar',
            onPressed: () {
              ref.read(sidebarVisibleProvider.notifier).state = false;
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final String label;

  const _SidebarHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: AppColors.textGrey,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SidebarItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String path;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isSelected = false;
    try {
      final currentLoc = GoRouterState.of(context).matchedLocation;
      isSelected = currentLoc == path || 
          (path != '/' && currentLoc.startsWith('$path/'));
    } catch (_) {
      // Fallback or ignore if GoRouterState is not available
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.accent.withValues(alpha: 0.02),
                  ],
                )
              : null,
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                left: 0,
                top: 10,
                bottom: 10,
                width: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                selected: isSelected,
                selectedTileColor: Colors.transparent,
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isSelected ? AppColors.primary : Colors.grey.shade700,
                  ),
                ),
                title: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isSelected ? AppColors.primary : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                onTap: () {
                  context.go(path);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Divider(height: 1, thickness: 0.5),
    );
  }
}
