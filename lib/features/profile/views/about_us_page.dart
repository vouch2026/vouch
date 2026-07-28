import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../shared/layouts/responsive_layout.dart';

/// A premium, responsive "About Us" page for Vouch.
/// Adapted from vouch_profile.dart and styled to match the theme design system.
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'About Vouch',
      onBack: Navigator.canPop(context) ? () => Navigator.pop(context) : null,
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  // ==========================================
  // Layout Options
  // ==========================================

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogoSection(isDesktop: false),
          const SizedBox(height: AppSpacing.lg),
          _buildCardSection(
            title: 'Vision',
            content:
                'To redefine the management of organizational activities through a seamless, secure, and unified digital ecosystem.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildMissionCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildCardSection(
            title: 'History',
            content:
                'Vouch was born out of necessity at Davao Oriental State University. We saw firsthand the friction, delays, and inefficiencies of manual, paper-based activity card clearance systems. What started as a targeted initiative to solve a local campus bottleneck has evolved into a comprehensive digital platform. By prioritizing accuracy, transparency, and convenience, Vouch bridges the gap between students and organizations—transforming complex academic compliance into a streamlined, error-free reality.',
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionLabel('Developed by'),
          const SizedBox(height: AppSpacing.md),
          _buildDeveloperCard(),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionLabel('Trusted by'),
          const SizedBox(height: AppSpacing.md),
          _buildPartnershipGrid(isMobile: true),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogoSection(isDesktop: false),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCardSection(
                  title: 'Vision',
                  content:
                      'To redefine campus administration through a seamless, secure, and unified digital ecosystem.',
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: _buildMissionCard()),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCardSection(
            title: 'History',
            content:
                'Vouch was born from a drive to modernize the administrative experience at Davao Oriental State University. What began as an initiative to eliminate the friction of manual, paper-based clearance systems has evolved into a comprehensive digital platform. Designed to ensure accuracy, transparency, and convenience, Vouch bridges the gap between students and administrators, transforming complex academic compliance into a streamlined, digital reality.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Developed by'),
                    const SizedBox(height: AppSpacing.md),
                    _buildDeveloperCard(),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Trusted by'),
                    const SizedBox(height: AppSpacing.md),
                    _buildPartnershipGrid(isMobile: false),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar Column
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoSection(isDesktop: true),
                const SizedBox(height: AppSpacing.xl),
                _buildSectionLabel('Developed by'),
                const SizedBox(height: AppSpacing.md),
                _buildDeveloperCard(),
                const SizedBox(height: AppSpacing.xl),
                _buildSectionLabel('Trusted by'),
                const SizedBox(height: AppSpacing.md),
                _buildPartnershipGrid(isMobile: false),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),
          // Right Main Details Column
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardSection(
                  title: 'Vision',
                  content:
                      'To redefine campus administration through a seamless, secure, and unified digital ecosystem.',
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildMissionCard(),
                const SizedBox(height: AppSpacing.xl),
                _buildCardSection(
                  title: 'History',
                  content:
                      'Vouch was born from a drive to modernize the administrative experience at Davao Oriental State University. What began as an initiative to eliminate the friction of manual, paper-based clearance systems has evolved into a comprehensive digital platform. Designed to ensure accuracy, transparency, and convenience, Vouch bridges the gap between students and administrators, transforming complex academic compliance into a streamlined, digital reality.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Helper Component Builders
  // ==========================================

  Widget _buildLogoSection({required bool isDesktop}) {
    return Center(
      child: Column(
        children: [
          Container(
            width: isDesktop ? 120 : 100,
            height: isDesktop ? 120 : 100,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.06),
                width: 2,
              ),
            ),
            child: Image.asset('assets/logos/vouch.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Vouch',
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Software Solution',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.titleLarge.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildCardSection({required String title, required String content}) {
    return HoverCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.85),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard() {
    final missionItems = [
      (
        'Centralize',
        'Streamline student attendance, payments, and activity card clearances into a single platform.',
      ),
      (
        'Innovate',
        'Eliminate paper-based bottlenecks with real-time, digital tracking.',
      ),
      (
        'Empower',
        'Equip both program-level and faculty-level organizations with precise monitoring and verification tools.',
      ),
      (
        'Evolve',
        'Continuously adapt and scale the system to meet the complex needs of modern academic institutions.',
      ),
    ];

    return HoverCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Mission',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...missionItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.85),
                            height: 1.6,
                          ),
                          children: [
                            TextSpan(
                              text: '${item.$1}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: item.$2),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return HoverCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/logos/vouch-softtech-services-logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      LucideIcons.building,
                      color: AppColors.primary,
                      size: 28,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vouch SoftTech Services',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Software Development Startup',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Empowering institutions through technology',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnershipGrid({required bool isMobile}) {
    final List<Widget> children = [
      _buildPartnershipCard(
        name: "Faculty of Criminal Justice Education Student Organization",
        logoPath: 'assets/logos/fcje-so.jpg',
      ),
      if (isMobile) const SizedBox(height: AppSpacing.md),
      _buildPartnershipCard(
        name: 'Org Name Here',
        logoPath: '',
      ),
    ];

    if (isMobile) {
      return Column(children: children);
    } else {
      return Row(
        children: [
          Expanded(child: children.first),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: children.last),
        ],
      );
    }
  }

  Widget _buildPartnershipCard({
    required String name,
    required String logoPath,
  }) {
    return HoverCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: logoPath.isEmpty
                    ? const Icon(
                        LucideIcons.building,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : Image.asset(
                        logoPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                            'Failed to load asset: $logoPath, error: $error',
                          );
                          return const Icon(
                            LucideIcons.building,
                            color: AppColors.primary,
                            size: 20,
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Hover Interactive Card Wrapper
// ==========================================

class HoverCard extends StatefulWidget {
  final Widget child;

  const HoverCard({super.key, required this.child});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              blurRadius: 16.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
