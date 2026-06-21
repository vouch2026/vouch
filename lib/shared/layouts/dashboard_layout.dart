import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar/dynamic_sidebar.dart';
import '../widgets/navbar/profile_dropdown.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/organizations/providers/workspace_provider.dart';
import '../../core/providers/sidebar_provider.dart';
import '../../core/theme/app_colors.dart';

class DashboardLayout extends ConsumerWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final VoidCallback? onBack;

  const DashboardLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';
    final isSidebarVisible = ref.watch(sidebarVisibleProvider);

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
    final isDesktop = size.width >= 1024;

    final hasSubtitle = (selectedOrg != null && !isSuperAdmin) || isSuperAdmin;
    final double containerHeight = hasSubtitle 
        ? (isMobile ? 58.0 : (isTablet ? 64.0 : 68.0)) 
        : (isMobile ? 50.0 : 56.0);
    final double topMargin = isMobile ? 8.0 : (isTablet ? 12.0 : 16.0);
    final double bottomMargin = isMobile ? 4.0 : (isTablet ? 6.0 : 8.0);
    final double horizontalMargin = isMobile ? 8.0 : (isTablet ? 12.0 : 16.0);
    final double totalAppBarHeight = containerHeight + topMargin + bottomMargin;
    final double borderRadius = isMobile ? 12.0 : 16.0;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                width: (isDesktop && isSidebarVisible) ? 250.0 : 0.0,
                child: ClipRect(
                  child: OverflowBox(
                    minWidth: 250.0,
                    maxWidth: 250.0,
                    alignment: Alignment.topLeft,
                    child: const SizedBox(
                      width: 250.0,
                      child: DynamicSidebar(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(totalAppBarHeight),
                    child: Container(
                      margin: EdgeInsets.only(
                        top: topMargin,
                        left: horizontalMargin,
                        right: horizontalMargin,
                        bottom: bottomMargin,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16.0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          scrolledUnderElevation: 0,
                          toolbarHeight: containerHeight,
                          leadingWidth: onBack != null
                              ? (isMobile ? 52.0 : 60.0)
                              : ((!isSidebarVisible || !isDesktop)
                                  ? (isMobile ? 52.0 : 60.0)
                                  : 0.0),
                          leading: onBack != null
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: isMobile ? 6.0 : 10.0),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Container(
                                        width: isMobile ? 34 : 38,
                                        height: isMobile ? 34 : 38,
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_rounded,
                                          color: AppColors.primary,
                                          size: isMobile ? 18 : 20,
                                        ),
                                      ),
                                      onPressed: onBack,
                                    ),
                                  ),
                                )
                              : ((!isSidebarVisible || !isDesktop)
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: isMobile ? 6.0 : 10.0),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Container(
                                            width: isMobile ? 34 : 38,
                                            height: isMobile ? 34 : 38,
                                            decoration: BoxDecoration(
                                              color: AppColors.accent.withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.primary.withValues(alpha: 0.1),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.menu_rounded,
                                              color: AppColors.primary,
                                              size: isMobile ? 18 : 20,
                                            ),
                                          ),
                                          onPressed: () => ref
                                              .read(sidebarVisibleProvider.notifier)
                                              .state = true,
                                        ),
                                      ),
                                    )
                                  : null),
                          titleSpacing: (onBack != null || !isSidebarVisible || !isDesktop)
                              ? (isMobile ? 4.0 : 8.0)
                              : (isMobile ? 12.0 : 16.0),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 15 : (isTablet ? 16 : 18),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              _buildSubtitleBadges(context, isSuperAdmin, workspace, selectedOrg, isMobile),
                            ],
                          ),
                          actions: [
                            if (actions != null)
                              ...actions!.map((action) {
                                if (action is IconButton) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: isMobile ? 4.0 : 8.0),
                                    child: Container(
                                      width: isMobile ? 34 : 38,
                                      height: isMobile ? 34 : 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.05),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.08),
                                          width: 1,
                                        ),
                                      ),
                                      child: action,
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: EdgeInsets.only(right: isMobile ? 4.0 : 8.0),
                                  child: action,
                                );
                              }),
                            const ProfileDropdown(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: child,
                  floatingActionButton: floatingActionButton,
                ),
              ),
            ],
          ),
          
          // Mobile/Tablet Sidebar Overlay
          if (!isDesktop)
            IgnorePointer(
              ignoring: !isSidebarVisible,
              child: Stack(
                children: [
                  // Scrim
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    opacity: isSidebarVisible ? 1.0 : 0.0,
                    child: GestureDetector(
                      onTap: () => ref.read(sidebarVisibleProvider.notifier).state = false,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // Sliding Sidebar
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    left: isSidebarVisible ? 0.0 : -250.0,
                    top: 0,
                    bottom: 0,
                    width: 250,
                    child: const DynamicSidebar(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubtitleBadges(
      BuildContext context, bool isSuperAdmin, dynamic workspace, dynamic selectedOrg, bool isMobile) {
    if (isSuperAdmin) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'SYSTEM ADMIN',
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    if (selectedOrg != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3), width: 1),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 100 : 180),
                  child: Text(
                    isMobile ? (selectedOrg.code ?? selectedOrg.name) : selectedOrg.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15), width: 1),
                ),
                child: Text(
                  workspace.activeRole?.roleName ?? 'Member',
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
