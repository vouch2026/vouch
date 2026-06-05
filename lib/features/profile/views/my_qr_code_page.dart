import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../organizations/providers/workspace_provider.dart';

class MyQrCodePage extends ConsumerStatefulWidget {
  const MyQrCodePage({super.key});

  @override
  ConsumerState<MyQrCodePage> createState() => _MyQrCodePageState();
}

class _MyQrCodePageState extends ConsumerState<MyQrCodePage> {
  final GlobalKey _cardBoundaryKey = GlobalKey();
  bool _isCapturing = false;

  Future<void> _downloadVerificationCard() async {
    try {
      setState(() => _isCapturing = true);
      // Give time for the UI to update if needed
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _cardBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isCapturing = false);
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        setState(() => _isCapturing = false);
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: "Vouch_QR_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['isSuccess'] == true 
              ? 'Verification Card saved to Gallery!' 
              : 'Failed to save to gallery'),
            backgroundColor: result['isSuccess'] == true ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving card: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;

    return DashboardLayout(
      title: 'My QR Code',
      child: userProfileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: Text('User not found'));

          final qrData = jsonEncode({
            'studentId': profile.schoolId,
            'fullName': profile.fullName,
            'program': profile.programName ?? 'N/A',
          });

          return RefreshIndicator(
            onRefresh: () => ref.refresh(userProfileProvider.future),
            child: Stack(
              children: [
                // Background Decorations
                Positioned(
                  top: 100,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 200,
                  left: -30,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: Column(
                      children: [
                        RepaintBoundary(
                          key: _cardBoundaryKey,
                          child: Container(
                            width: 400,
                            constraints: const BoxConstraints(maxWidth: 500),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card Header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(LucideIcons.qrCode, color: AppColors.primary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'QR VERIFICATION',
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: AppColors.textGrey,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          Text(
                                            'For attendance and identity check',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textGrey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!_isCapturing)
                                      IconButton(
                                        onPressed: _downloadVerificationCard,
                                        icon: const Icon(LucideIcons.download, color: AppColors.primary, size: 20),
                                        tooltip: 'Save Card',
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Profile Header Section
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.1),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.grey.shade100,
                                          backgroundImage: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                                              ? NetworkImage(profile.avatarUrl!)
                                              : const AssetImage('assets/images/my_profile.png') as ImageProvider,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              profile.fullName,
                                              style: AppTextStyles.titleLarge.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'ID: ${profile.schoolId}',
                                              style: AppTextStyles.labelMedium.copyWith(
                                                color: AppColors.textGrey,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // QR Code Section
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
                                    ),
                                    child: QrImageView(
                                      data: qrData,
                                      version: QrVersions.auto,
                                      size: 200,
                                      gapless: true,
                                      eyeStyle: const QrEyeStyle(
                                        eyeShape: QrEyeShape.square,
                                        color: AppColors.primary,
                                      ),
                                      dataModuleStyle: const QrDataModuleStyle(
                                        dataModuleShape: QrDataModuleShape.square,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Academic Info Rows
                                _buildImprovedInfoItem(LucideIcons.graduationCap, 'Faculty', profile.facultyName ?? 'N/A'),
                                const SizedBox(height: AppSpacing.sm),
                                _buildImprovedInfoItem(LucideIcons.bookOpen, 'Program', profile.programName ?? 'N/A'),
                                const SizedBox(height: AppSpacing.sm),
                                _buildImprovedInfoItem(LucideIcons.layers, 'Year Level', '${profile.yearLevelDisplay} Year'),
                                
                                const SizedBox(height: AppSpacing.xl),

                                // Footer Logos
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (selectedOrg != null) ...[
                                      _buildCircularLogo(
                                        logoUrl: selectedOrg.logoUrl,
                                        fallbackIcon: LucideIcons.building,
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    _buildCircularLogo(
                                      assetPath: 'assets/logos/vouch.png',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        // Additional instruction outside the card
                        Text(
                          'Keep this code secure. Officers will scan this to verify your participation and attendance in organization events.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textGrey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildImprovedInfoItem(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary.withValues(alpha: 0.7), size: 16),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularLogo({String? logoUrl, String? assetPath, IconData? fallbackIcon}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: logoUrl != null
            ? Image.network(logoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(fallbackIcon ?? LucideIcons.image, size: 24, color: AppColors.textGrey))
            : assetPath != null
                ? Image.asset(assetPath, fit: BoxFit.cover)
                : Icon(fallbackIcon ?? LucideIcons.image, size: 24, color: AppColors.textGrey),
      ),
    );
  }
}
