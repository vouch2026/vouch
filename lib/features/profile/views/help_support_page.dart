import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../shared/layouts/responsive_layout.dart';

/// A premium, responsive "Help & Support" page for Vouch.
/// Featuring direct community links and FAQs.
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Help & Support',
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
          const FacebookGroupCard(),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionLabel('Frequently Asked Questions'),
          const SizedBox(height: AppSpacing.md),
          _buildFaqList(),
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
          const FacebookGroupCard(),
          const SizedBox(height: AppSpacing.xxl),
          _buildSectionLabel('Frequently Asked Questions'),
          const SizedBox(height: AppSpacing.md),
          _buildFaqList(),
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
                const FacebookGroupCard(),
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
                _buildSectionLabel('Frequently Asked Questions'),
                const SizedBox(height: AppSpacing.md),
                _buildFaqList(),
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
            padding: const EdgeInsets.all(AppSpacing.lg),
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
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.06), width: 2),
            ),
            child: const Icon(
              LucideIcons.helpCircle,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Vouch Support',
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
              'How can we help you?',
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

  Widget _buildFaqList() {
    final faqs = [
      (
        'How do I clear my student activity card?',
        'Ensure all attendance and payment requirements for the current semester are completed. Once the officers verify your records and signs it, your card will update to "Cleared" automatically.'
      ),
      (
        'Why is my proof of payment still pending?',
        'Verification of payments is processed manually by designated student officers or auditors. This process normally takes 24 to 48 hours. Please keep your physical receipt just in case.'
      ),
      (
        'What should I do if my scanner isn\'t working?',
        'Make sure you have granted camera permissions to Vouch. Try cleaning your camera lens and ensure you are scanning in a well-lit environment. If it persists, try restarting the application or browser.'
      ),
      (
        'How do I submit an excuse request?',
        'Navigate to the past event, press the event, press the "Request Excuse" button, fill in the absence details, upload a photo of your medical certificate or parent letter, and submit it for officer review.'
      ),
      (
        'Can I update my year level?',
        'You can update your year level in the "Manage Account" section.'
      ),
    ];

    return Column(
      children: faqs.map((faq) => FaqCard(question: faq.$1, answer: faq.$2)).toList(),
    );
  }
}

// ==========================================
// Expandable FAQ Card
// ==========================================

class FaqCard extends StatefulWidget {
  final String question;
  final String answer;

  const FaqCard({super.key, required this.question, required this.answer});

  @override
  State<FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<FaqCard> {
  bool _isExpanded = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: _isHovered || _isExpanded
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.08),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered || _isExpanded
                  ? AppColors.primary.withValues(alpha: 0.04)
                  : Colors.transparent,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isExpanded ? AppColors.primary : AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _isExpanded ? 0.25 : 0,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: _isExpanded ? AppColors.primary : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.answer,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.8),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Vouch Community Facebook Group Card
// ==========================================

class FacebookGroupCard extends StatefulWidget {
  const FacebookGroupCard({super.key});

  @override
  State<FacebookGroupCard> createState() => _FacebookGroupCardState();
}

class _FacebookGroupCardState extends State<FacebookGroupCard> {
  bool _isHovered = false;

  Future<void> _launchGroup() async {
    final Uri url = Uri.parse('https://web.facebook.com/groups/1017630674009381');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Facebook Group link.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
              blurRadius: 16.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.facebook,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vouch Community',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Official Facebook Group',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Join our active user community on Facebook. Share ideas, ask questions, report bugs, and collaborate directly with other Vouch users and developers.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _launchGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  label: const Text(
                    'Visit Facebook Group',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

