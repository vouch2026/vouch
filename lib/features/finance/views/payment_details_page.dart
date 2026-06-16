import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../shared/layouts/responsive_layout.dart';
import '../models/student_payment_model.dart';
import '../providers/finance_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../organizations/providers/workspace_provider.dart';

class PaymentDetailsPage extends ConsumerStatefulWidget {
  final StudentPaymentModel payment;

  const PaymentDetailsPage({
    super.key,
    required this.payment,
  });

  @override
  ConsumerState<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends ConsumerState<PaymentDetailsPage> {
  bool _isProcessing = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updateStatus(String id, String status, [String? reason]) async {
    setState(() => _isProcessing = true);
    try {
      final user = ref.read(userProfileProvider).value!;
      await ref.read(financeRepositoryProvider).updatePaymentStatus(id, status, reason, user.id!);
      ref.invalidate(workspaceStudentPaymentsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment marked as $status successfully'),
            backgroundColor: status == 'Paid' ? Colors.green : Colors.red,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showInvalidateDialog(String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Invalidate Payment',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason why this proof of payment is invalid. This will be visible to the student.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g. Reference number doesn\'t match, receipt is blur...',
                labelText: 'Reason for Invalidation',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(context);
              _updateStatus(id, 'Rejected', controller.text.trim());
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Invalidate', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showReceiptPreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                ),
              ],
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: FlickrLoader());
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.white,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined, color: Colors.red, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync = ref.watch(workspaceStudentPaymentsProvider);
    
    // Find the latest state of this payment in the provider, falling back to widget.payment
    final payment = submissionsAsync.when(
      data: (list) => list.firstWhere(
        (element) => element.id == widget.payment.id,
        orElse: () => widget.payment,
      ),
      error: (err, stack) => widget.payment,
      loading: () => widget.payment,
    );

    final workspace = ref.watch(workspaceProvider);
    final activeRole = workspace.activeRole;
    final isOfficer = activeRole != null &&
                      activeRole.roleName != 'Student' &&
                      activeRole.roleName != 'Member';

    final isMobile = ResponsiveLayout.isMobile(context);
    final statusColor = _getStatusColor(payment.status);

    return DashboardLayout(
      title: 'Payment Details',
      onBack: () => Navigator.pop(context),
      child: _isProcessing 
        ? const Center(child: FlickrLoader())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs Header
                Row(
                  children: [
                    Icon(Icons.payments_outlined, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Finance',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Payment Details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Hero Banner
                _buildHeroBanner(payment, statusColor),
                const SizedBox(height: AppSpacing.xl),
                
                // Responsive Content Columns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReceiptCard(payment),
                          if (isMobile) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _buildDetailsCard(payment),
                            if (payment.status == 'Rejected' && payment.rejectionNote != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              _buildRejectionNoteCard(payment),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            _buildActionButtons(payment, isOfficer),
                          ],
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: AppSpacing.xxl),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailsCard(payment),
                            if (payment.status == 'Rejected' && payment.rejectionNote != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              _buildRejectionNoteCard(payment),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            _buildActionButtons(payment, isOfficer),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildHeroBanner(StudentPaymentModel payment, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.02),
            AppColors.white,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          payment.status.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'FEE SUBMISSION',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    payment.studentName ?? 'Student',
                    style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Fee: ${payment.feeName ?? "Unknown Fee"}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              if (!isWide) const SizedBox(height: AppSpacing.lg),
              Column(
                crossAxisAlignment: isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount Paid',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '₱${payment.amountPaid.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailsCard(StudentPaymentModel payment) {
    final formattedDate = payment.paidAt != null
        ? DateFormat.yMMMMd().add_jm().format(payment.paidAt!.toLocal())
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Information',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoRow('Student Name', payment.studentName ?? 'N/A'),
          const Divider(height: AppSpacing.lg),
          _buildInfoRow('Student ID Number', payment.studentIdNumber ?? 'N/A'),
          const Divider(height: AppSpacing.lg),
          _buildInfoRow('Fee Name', payment.feeName ?? 'N/A'),
          const Divider(height: AppSpacing.lg),
          _buildInfoRow('Payment Date', formattedDate),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reference Number',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  Text(
                    payment.referenceNumber,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                    onPressed: () => _copyToClipboard(payment.referenceNumber, 'Reference number'),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionNoteCard(StudentPaymentModel payment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason for Invalidation',
                  style: AppTextStyles.titleSmall.copyWith(color: Colors.red[900], fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  payment.rejectionNote ?? 'No details provided.',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.red[850]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(StudentPaymentModel payment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proof of Payment',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 0.75,
              child: payment.proofPhotoUrl != null
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            payment.proofPhotoUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(child: FlickrLoader());
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 48),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: FloatingActionButton.small(
                            onPressed: () => _showReceiptPreview(context, payment.proofPhotoUrl!),
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.zoom_in_rounded),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 48),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(StudentPaymentModel payment, bool isOfficer) {
    if (!isOfficer || payment.status != 'Pending') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: () => _updateStatus(payment.id!, 'Paid'),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Confirm Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _showInvalidateDialog(payment.id!),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Invalidate Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
