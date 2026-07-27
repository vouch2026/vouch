import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../routes/route_paths.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import '../../../core/widgets/states/offline_state_view.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final activeTermAsync = ref.watch(activeTermProvider);

    return userProfileAsync.when(
      data: (profile) {
        final isSuperAdmin = profile?.role == 'super_admin';
        final activeTerm = activeTermAsync.valueOrNull;

        return DashboardLayout(
          key: ValueKey(isSuperAdmin ? 'admin' : 'global'),
          title: 'Home',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double parentWidth = constraints.maxWidth;
              final double paddingValue = parentWidth >= 1024 ? AppSpacing.xl : AppSpacing.lg;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(paddingValue),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Banner
                      _buildWelcomeBanner(context, profile, parentWidth, activeTerm),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Section Header
                      Text(
                        'Personal Hub',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        height: 2,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Shortcut Hub Grid
                      _buildShortcutGrid(context, parentWidth),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: FlickrLoader())),
      error: (err, _) {
        if (OfflineStateView.isOfflineError(err)) {
          return Scaffold(
            body: OfflineStateView(
              onRetry: () => ref.invalidate(userProfileProvider),
            ),
          );
        }
        return Scaffold(body: Center(child: Text('Error: $err')));
      },
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, dynamic profile, double parentWidth, dynamic activeTerm) {
    final bool isCompact = parentWidth < 650;
    final bool isMedium = parentWidth >= 650 && parentWidth < 1000;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.03),
            AppColors.white,
            AppColors.accent.withValues(alpha: 0.01),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Abstract background circles matching Vouch sidebar UI
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Content Layout
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBannerTextContent(profile, activeTerm, isCompact: true),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildBannerTextContent(profile, activeTerm, isCompact: false),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.05),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/mascot.png',
                            height: isMedium ? 130 : 170,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
            ),
            
            // Mascot in right upper corner on mobile
            if (isCompact)
              Positioned(
                top: AppSpacing.lg,
                right: AppSpacing.lg,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/mascot.png',
                    height: 75,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerTextContent(dynamic profile, dynamic activeTerm, {required bool isCompact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo & Brand row (padded on mobile to avoid overlapping mascot)
        Padding(
          padding: EdgeInsets.only(right: isCompact ? 80.0 : 0.0),
          child: Row(
            children: [
              Image.asset(
                'assets/logos/vouch.png',
                width: isCompact ? 32 : 38,
                height: isCompact ? 32 : 38,
              ),
              const SizedBox(width: AppSpacing.sm),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 20 : 22,
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
        ),
        SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
        
        // Welcome Message (padded on mobile to avoid overlapping mascot)
        Padding(
          padding: EdgeInsets.only(right: isCompact ? 80.0 : 0.0),
          child: Text(
            'Welcome back, ${profile?.fullName ?? 'User'}!',
            style: GoogleFonts.poppins(
              fontSize: isCompact ? 20 : 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Empowering student leadership & governance',
          style: GoogleFonts.poppins(
            fontSize: isCompact ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ),
        SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
        
        // Metadata Badges Row
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            // Term Badge
            _buildBadge(
              icon: Icons.calendar_today_rounded,
              label: activeTerm != null
                  ? 'AY ${activeTerm.academicYear} | ${activeTerm.semester} Semester'
                  : 'AY 2025–2026 | 2nd Semester',
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              textColor: AppColors.primary,
            ),
            
            // Role Badge
            _buildBadge(
              icon: profile?.role == 'super_admin' ? Icons.shield_outlined : Icons.person_outline_rounded,
              label: profile?.role == 'super_admin' ? 'SYSTEM ADMIN' : (profile?.role?.toUpperCase() ?? 'STUDENT'),
              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
              textColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutGrid(BuildContext context, double parentWidth) {
    final List<_ShortcutItemData> shortcuts = [
      _ShortcutItemData(
        title: 'Tasks',
        description: 'View your current tasks, responsibilities, and to-do lists.',
        icon: Icons.assignment_turned_in_outlined,
        path: RoutePaths.tasks,
      ),
      _ShortcutItemData(
        title: 'Calendar',
        description: 'Check upcoming school activities, meetings, and important dates.',
        icon: Icons.calendar_today_outlined,
        path: RoutePaths.calendar,
      ),
      _ShortcutItemData(
        title: 'Schedule',
        description: 'Manage your daily schedules and view school timelines.',
        icon: Icons.schedule_outlined,
        path: RoutePaths.schedule,
      ),
      _ShortcutItemData(
        title: 'Notifications',
        description: 'Stay updated with real-time announcements and alerts.',
        icon: Icons.notifications_none_rounded,
        path: RoutePaths.notifications,
      ),
      _ShortcutItemData(
        title: 'Help & Support',
        description: 'Access documentation, guides, and contact support teams.',
        icon: Icons.help_outline_rounded,
        path: RoutePaths.help,
      ),
      _ShortcutItemData(
        title: 'About Us',
        description: 'Learn more about the Vouch platform development team.',
        icon: Icons.info_outline_rounded,
        path: RoutePaths.aboutUs,
      ),
    ];

    final bool useGrid = parentWidth >= 600;

    if (useGrid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: parentWidth >= 1024 ? 3 : 2,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          mainAxisExtent: 120,
        ),
        itemCount: shortcuts.length,
        itemBuilder: (context, index) {
          return _buildShortcutCard(context, shortcuts[index]);
        },
      );
    } else {
      // Mobile vertical layout for dynamic auto-height to prevent overflows
      return Column(
        children: shortcuts.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildShortcutCard(context, item),
          );
        }).toList(),
      );
    }
  }

  Widget _buildShortcutCard(BuildContext context, _ShortcutItemData item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go(item.path),
          hoverColor: AppColors.primary.withValues(alpha: 0.02),
          splashColor: AppColors.primary.withValues(alpha: 0.05),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
              children: [
                // Icon container matching sidebar style
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chevron end
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary.withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutItemData {
  final String title;
  final String description;
  final IconData icon;
  final String path;

  const _ShortcutItemData({
    required this.title,
    required this.description,
    required this.icon,
    required this.path,
  });
}
