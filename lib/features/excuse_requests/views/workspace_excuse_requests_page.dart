import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loaders/flickr_loader.dart';
import '../../../../routes/route_paths.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';
import '../models/excuse_request_model.dart';
import '../providers/excuse_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../organizations/providers/workspace_provider.dart';

class WorkspaceExcuseRequestsPage extends ConsumerStatefulWidget {
  const WorkspaceExcuseRequestsPage({super.key});

  @override
  ConsumerState<WorkspaceExcuseRequestsPage> createState() => _WorkspaceExcuseRequestsPageState();
}

class _WorkspaceExcuseRequestsPageState extends ConsumerState<WorkspaceExcuseRequestsPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  Widget _buildFilterChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Pending', 'Approved', 'Rejected'].map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedFilter = filter);
              },
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final excuseRequestsAsync = ref.watch(workspaceExcuseRequestsProvider);
    final workspace = ref.watch(workspaceProvider);
    final org = workspace.selectedOrganization;

    return DashboardLayout(
      title: 'Excuse Requests',
      child: excuseRequestsAsync.when(
        data: (requests) {
          // Filter & Search application
          final filteredRequests = requests.where((req) {
            final matchesStatus = _selectedFilter == 'All' || req.status.toLowerCase() == _selectedFilter.toLowerCase();
            final studentName = req.studentName?.toLowerCase() ?? '';
            final eventName = req.eventName?.toLowerCase() ?? '';
            final matchesSearch = studentName.contains(_searchQuery) || eventName.contains(_searchQuery);
            return matchesStatus && matchesSearch;
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              final theme = Theme.of(context);

              return RefreshIndicator(
                onRefresh: () => ref.refresh(workspaceExcuseRequestsProvider.future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl,
                    vertical: isMobile ? AppSpacing.lg : AppSpacing.xl,
                  ),
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note_alt_outlined, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Text(
                          'Excuse Requests',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const UserManagementHeader(
                      title: 'Excuse Requests',
                      subtitle: 'Review and manage student absence excuse submissions for this organization\'s events.',
                      actions: [],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (org != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          'Scope: ${org.type.replaceAll('-', ' ').toUpperCase()} | Total Found: ${filteredRequests.length}',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[500]),
                        ),
                      ),

                    // Filters & Search Section
                    if (isMobile) ...[
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search student or event...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        ),
                        style: AppTextStyles.bodyMedium,
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildFilterChips(theme),
                    ] else
                      Row(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.6,
                            ),
                            child: _buildFilterChips(theme),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search student or event...',
                                prefixIcon: const Icon(Icons.search_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              ),
                              style: AppTextStyles.bodyMedium,
                              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: AppSpacing.xl),

                    if (filteredRequests.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                requests.isEmpty 
                                  ? 'No excuse requests found in this scope' 
                                  : 'No excuse requests match your filters',
                                style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold),
                              ),
                              if (requests.isNotEmpty)
                                TextButton(
                                  onPressed: () => setState(() => _selectedFilter = 'All'),
                                  child: const Text('Clear Filters'),
                                ),
                            ],
                          ),
                        ),
                      )
                    else if (constraints.maxWidth > 900)
                      _buildRequestsTable(filteredRequests)
                    else
                      _buildRequestsList(filteredRequests),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (err, _) => Center(child: Text('Error loading requests: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildRequestsTable(List<ExcuseRequestModel> requests) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: AppSpacing.lg,
                headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.04)),
                columns: [
                  DataColumn(label: Text('STUDENT', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  DataColumn(label: Text('EVENT', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  DataColumn(label: Text('REASON TYPE', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  DataColumn(label: Text('SUBMITTED AT', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  DataColumn(label: Text('STATUS', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  DataColumn(label: Text('ACTIONS', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                ],
                rows: requests.map((req) {
                  final isPending = req.status == 'Pending';
                  
                  // Parse reason prefix [Type] Detail
                  String reasonType = 'General';
                  if (req.reason.startsWith('[')) {
                    final closeBracket = req.reason.indexOf(']');
                    if (closeBracket > 1) {
                      reasonType = req.reason.substring(1, closeBracket);
                    }
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                req.studentName ?? 'Unknown Student',
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                req.studentIdNumber ?? 'N/A',
                                style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            req.eventName ?? 'Event',
                            style: AppTextStyles.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(reasonType, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                        ),
                      ),
                      DataCell(Text(
                        req.createdAt != null ? DateFormat('MMM d, yyyy h:mm a').format(req.createdAt!.toLocal()) : '—',
                        style: AppTextStyles.bodyMedium,
                      )),
                      DataCell(_StatusBadge(status: req.status)),
                      DataCell(
                        TextButton(
                          onPressed: () {
                            if (isPending) {
                              context.push(RoutePaths.workspaceExcuseRequestReview.replaceAll(':id', req.id))
                                  .then((_) => ref.invalidate(workspaceExcuseRequestsProvider));
                            } else {
                              _showReviewDialog(req);
                            }
                          },
                          child: Text(isPending ? 'Review' : 'View Details'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(List<ExcuseRequestModel> requests) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemBuilder: (context, index) {
        final req = requests[index];
        final isPending = req.status == 'Pending';
        
        String reasonType = 'General';
        String explanation = req.reason;
        if (req.reason.startsWith('[')) {
          final closeBracket = req.reason.indexOf(']');
          if (closeBracket > 1) {
            reasonType = req.reason.substring(1, closeBracket);
            explanation = req.reason.substring(closeBracket + 1).trim();
          }
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req.studentName ?? 'Unknown Student', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          Text(req.studentIdNumber ?? 'N/A', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    _StatusBadge(status: req.status),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow('Event:', req.eventName ?? 'Event'),
                _buildInfoRow('Reason Type:', reasonType),
                _buildInfoRow('Explanation:', explanation, maxLines: 2),
                _buildInfoRow('Submitted:', req.createdAt != null ? DateFormat('MMM d, yyyy h:mm a').format(req.createdAt!.toLocal()) : '—'),
                const SizedBox(height: AppSpacing.sm),
                 SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (isPending) {
                        context.push(RoutePaths.workspaceExcuseRequestReview.replaceAll(':id', req.id))
                            .then((_) => ref.invalidate(workspaceExcuseRequestsProvider));
                      } else {
                        _showReviewDialog(req);
                      }
                    },
                    child: Text(isPending ? 'Review Request' : 'View Details'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodySmall, maxLines: maxLines, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(ExcuseRequestModel request) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ExcuseReviewDialog(
        request: request,
        onProcessed: () {
          ref.invalidate(workspaceExcuseRequestsProvider);
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Approved':
        color = AppColors.success;
        break;
      case 'Pending':
      case 'Pending Review':
        color = AppColors.warning;
        break;
      case 'Rejected':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class _ExcuseReviewDialog extends ConsumerStatefulWidget {
  final ExcuseRequestModel request;
  final VoidCallback onProcessed;

  const _ExcuseReviewDialog({
    required this.request,
    required this.onProcessed,
  });

  @override
  ConsumerState<_ExcuseReviewDialog> createState() => _ExcuseReviewDialogState();
}

class _ExcuseReviewDialogState extends ConsumerState<_ExcuseReviewDialog> {
  final _remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _showRejectionForm = false;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _processReview(String decision) async {
    if (decision == 'Rejected' && !_formKey.currentState!.validate()) return;

    final officer = ref.read(userProfileProvider).value;
    final workspace = ref.read(workspaceProvider);
    final org = workspace.selectedOrganization;
    final term = ref.read(activeTermProvider).value;

    if (officer == null || org == null || term == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Officer or organization session not loaded.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      String? scopeId = org.campusId;
      String scopeType = 'campus';
      if (org.type == 'faculty-based') {
        scopeId = org.facultyId;
        scopeType = 'faculty';
      } else if (org.type == 'program-based') {
        scopeId = org.programId;
        scopeType = 'program';
      }

      await ref.read(excuseRepositoryProvider).reviewExcuseRequest(
        excuseId: widget.request.id,
        status: decision,
        rejectionReason: decision == 'Rejected' ? _remarksController.text.trim() : null,
        officerId: officer.id!,
        scopeId: scopeId!,
        scopeType: scopeType,
        termId: term.id,
      );

      widget.onProcessed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excuse request has been successfully $decision.'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process review: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final isPending = req.status == 'Pending';

    String reasonType = 'General';
    String explanation = req.reason;
    if (req.reason.startsWith('[')) {
      final closeBracket = req.reason.indexOf(']');
      if (closeBracket > 1) {
        reasonType = req.reason.substring(1, closeBracket);
        explanation = req.reason.substring(closeBracket + 1).trim();
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 650;
    final dialogWidth = screenWidth > 650 ? 600.0 : screenWidth * 0.95;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : 40.0,
        vertical: 24.0,
      ),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Review Excuse Request',
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),

              // Student Info Card
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    child: Text(
                      req.studentName?[0] ?? 'S',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.studentName ?? 'Unknown Student',
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('Student ID: ${req.studentIdNumber ?? 'N/A'}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Event Info Card
              _buildRowDetail('Target Event:', req.eventName ?? 'Unknown Event', isMobile: isMobile),
              _buildRowDetail('Reason Type:', reasonType, isMobile: isMobile),
              _buildRowDetail('Explanation:', explanation, isMobile: isMobile),
              _buildRowDetail('Submitted:', req.createdAt != null ? DateFormat('MMM d, yyyy h:mm a').format(req.createdAt!.toLocal()) : '—', isMobile: isMobile),
              
              if (req.status != 'Pending') ...[
                const SizedBox(height: AppSpacing.sm),
                _buildRowDetail('Current Status:', req.status, valueColor: req.status == 'Approved' ? AppColors.success : AppColors.error, isMobile: isMobile),
                if (req.rejectionReason != null && req.rejectionReason!.isNotEmpty)
                  _buildRowDetail('Remarks:', req.rejectionReason!, isMobile: isMobile),
              ],
              const SizedBox(height: AppSpacing.lg),

              // Supporting Document Preview
              Text('Supporting Document / Proof:', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade100,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  req.supportingDocumentUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: FlickrLoader());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image_outlined, size: 40, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('Failed to load image proof', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Processing state
              if (_isProcessing)
                Center(
                  child: Column(
                    children: [
                      const FlickrLoader(),
                      const SizedBox(height: 8),
                      Text('Saving decision...', style: AppTextStyles.bodySmall),
                    ],
                  ),
                )
              else if (isPending) ...[
                if (_showRejectionForm) ...[
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reason for Rejection *', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _remarksController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Describe why the excuse is invalid (e.g., document invalid)...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          style: AppTextStyles.bodySmall,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Rejection reason is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _showRejectionForm = false),
                              child: const Text('Back'),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: () => _processReview('Rejected'),
                              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                              child: const Text('Confirm Rejection'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() => _showRejectionForm = true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      FilledButton(
                        onPressed: () => _processReview('Approved'),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowDetail(String label, String value, {Color? valueColor, required bool isMobile}) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
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
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? AppColors.textDark,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? AppColors.textDark,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
