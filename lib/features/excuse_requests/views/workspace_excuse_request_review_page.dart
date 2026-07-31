import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loaders/flickr_loader.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../shared/layouts/responsive_layout.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../models/excuse_request_model.dart';
import '../providers/excuse_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../organizations/providers/workspace_provider.dart';

import '../../../../core/widgets/images/app_network_image.dart';

class WorkspaceExcuseRequestReviewPage extends ConsumerStatefulWidget {
  final String id;

  const WorkspaceExcuseRequestReviewPage({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<WorkspaceExcuseRequestReviewPage> createState() =>
      _WorkspaceExcuseRequestReviewPageState();
}

class _WorkspaceExcuseRequestReviewPageState
    extends ConsumerState<WorkspaceExcuseRequestReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _remarksController = TextEditingController();
  bool _showRejectionForm = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _processReview(ExcuseRequestModel request, String status) async {
    if (status == 'Rejected') {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() => _isProcessing = true);
    try {
      final officer = ref.read(userProfileProvider).value;
      final term = ref.read(activeTermProvider).value;
      final workspace = ref.read(workspaceProvider);
      final org = workspace.selectedOrganization;

      if (officer == null || term == null || org == null) {
        throw Exception('User profile, term, or organization not loaded');
      }

      String? scopeType = org.type;
      String? scopeId = org.campusId;
      if (org.type == 'faculty-based') {
        scopeId = org.facultyId;
      } else if (org.type == 'program-based') {
        scopeId = org.programId;
      }

      if (scopeId == null) {
        throw Exception('Scope ID not resolved');
      }

      final repo = ref.read(excuseRepositoryProvider);
      await repo.reviewExcuseRequest(
        excuseId: request.id,
        status: status,
        rejectionReason: status == 'Rejected' ? _remarksController.text.trim() : null,
        officerId: officer.id!,
        scopeId: scopeId,
        scopeType: scopeType,
        termId: term.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excuse request has been $status')),
        );
        ref.invalidate(workspaceExcuseRequestsProvider);
        ref.invalidate(workspaceExcuseRequestByIdProvider(widget.id));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reviewing request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(workspaceExcuseRequestByIdProvider(widget.id));
    final isMobile = ResponsiveLayout.isMobile(context);

    return LoadingOverlay(
      isLoading: _isProcessing,
      child: DashboardLayout(
        title: 'Review Excuse Request',
        onBack: () => context.pop(),
        child: requestAsync.when(
          data: (request) {
            if (request == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Excuse request not found',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            String reasonType = 'General';
            String explanation = request.reason;
            if (request.reason.startsWith('[')) {
              final closeBracket = request.reason.indexOf(']');
              if (closeBracket > 1) {
                reasonType = request.reason.substring(1, closeBracket);
                explanation = request.reason.substring(closeBracket + 1).trim();
              }
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumbs Row
                  Row(
                    children: [
                      Icon(Icons.note_alt_outlined, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context.pop(),
                        child: Text(
                          'Excuse Requests',
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
                          'Review Request',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Content Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Panel: Details and Actions
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStudentHeader(request),
                              const SizedBox(height: AppSpacing.xl),
                              const Divider(),
                              const SizedBox(height: AppSpacing.lg),
                              _buildRowDetail('Target Event:',
                                  request.eventName ?? 'Unknown Event'),
                              _buildRowDetail('Reason Type:', reasonType),
                              _buildRowDetail('Explanation:', explanation),
                              _buildRowDetail(
                                  'Submitted:',
                                  request.createdAt != null
                                      ? DateFormat('MMM d, yyyy h:mm a')
                                          .format(request.createdAt!.toLocal())
                                      : '—'),
                              const SizedBox(height: AppSpacing.sm),
                              _buildRowDetail(
                                'Current Status:',
                                request.status,
                                valueColor: request.status == 'Approved'
                                    ? AppColors.success
                                    : (request.status == 'Rejected'
                                        ? AppColors.error
                                        : AppColors.warning),
                              ),
                              if (request.status != 'Pending') ...[
                                if (request.reviewedByName != null)
                                  _buildRowDetail(
                                      'Reviewed By:', request.reviewedByName!),
                                if (request.rejectionReason != null &&
                                    request.rejectionReason!.isNotEmpty)
                                  _buildRowDetail(
                                      'Remarks:', request.rejectionReason!),
                              ],
                              const SizedBox(height: AppSpacing.xl),
                              const Divider(),
                              const SizedBox(height: AppSpacing.xl),
                              _buildReviewActions(request),
                            ],
                          ),
                        ),
                      ),
                      // Right Panel: Image Proof Sidebar (on wide screens)
                      if (!isMobile) ...[
                        const SizedBox(width: AppSpacing.xxl),
                        Expanded(
                          flex: 1,
                          child: _buildProofSidebar(request),
                        ),
                      ],
                    ],
                  ),
                  // Image Proof Sidebar below details (on mobile screens)
                  if (isMobile) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _buildProofSidebar(request),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 64.0),
              child: FlickrLoader(),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 64.0),
              child: Text(
                'Error loading excuse request: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentHeader(ExcuseRequestModel req) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
          child: Text(
            req.studentName?[0] ?? 'S',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 22),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                req.studentName ?? 'Unknown Student',
                style: AppTextStyles.headlineSmall
                    .copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Student ID: ${req.studentIdNumber ?? 'N/A'}',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRowDetail(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: valueColor ?? AppColors.textDark,
              fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofSidebar(ExcuseRequestModel request) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attachment_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Supporting Document',
                style: AppTextStyles.titleMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              color: Colors.grey.shade50,
            ),
            clipBehavior: Clip.antiAlias,
            child: InteractiveViewer(
              maxScale: 4.0,
              child: AppNetworkImage(
                imageUrl: request.supportingDocumentUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tip: Use pinch-to-zoom to inspect document details.',
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textGrey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewActions(ExcuseRequestModel request) {
    final isPending = request.status == 'Pending';
    if (!isPending) {
      return Center(
        child: Text(
          'This request has already been processed.',
          style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textGrey, fontStyle: FontStyle.italic),
        ),
      );
    }

    if (_showRejectionForm) {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reason for Rejection *',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Describe why the excuse is invalid (e.g., document invalid)...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: AppTextStyles.bodyMedium,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Rejection reason is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _showRejectionForm = false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => _processReview(request, 'Rejected'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Confirm Rejection'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => setState(() => _showRejectionForm = true),
          icon: const Icon(Icons.close_rounded),
          label: const Text('Reject Request'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton.icon(
          onPressed: () => _processReview(request, 'Approved'),
          icon: const Icon(Icons.check_rounded),
          label: const Text('Approve Request'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}
