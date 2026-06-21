import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loaders/flickr_loader.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';
import '../models/excuse_request_model.dart';
import '../providers/excuse_provider.dart';
import '../../auth/providers/auth_provider.dart';

class MyExcuseRequestsPage extends ConsumerStatefulWidget {
  const MyExcuseRequestsPage({super.key});

  @override
  ConsumerState<MyExcuseRequestsPage> createState() => _MyExcuseRequestsPageState();
}

class _MyExcuseRequestsPageState extends ConsumerState<MyExcuseRequestsPage> {
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
    final user = ref.watch(userProfileProvider).value;
    if (user == null) {
      return const DashboardLayout(
        title: 'Excuse Requests',
        child: Center(child: FlickrLoader()),
      );
    }

    final excusesAsync = ref.watch(studentExcusesProvider(user.id!));

    return DashboardLayout(
      title: 'Excuse Requests',
      child: excusesAsync.when(
        data: (requests) {
          final filteredRequests = requests.where((req) {
            final matchesStatus = _selectedFilter == 'All' || req.status.toLowerCase() == _selectedFilter.toLowerCase();
            final eventName = req.eventName?.toLowerCase() ?? '';
            final reason = req.reason.toLowerCase();
            final matchesSearch = eventName.contains(_searchQuery) || reason.contains(_searchQuery);
            return matchesStatus && matchesSearch;
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              final theme = Theme.of(context);

              return RefreshIndicator(
                onRefresh: () => ref.refresh(studentExcusesProvider(user.id!).future),
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
                          'My Excuse Requests',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const UserManagementHeader(
                      title: 'My Excuse Requests',
                      subtitle: 'Track your submitted absence excuse requests and check reviews from officers.',
                      actions: [],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Filters and Search section
                    if (isMobile) ...[
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search event or reason...',
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
                                hintText: 'Search event or reason...',
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
                                  ? 'You have not submitted any excuse requests yet' 
                                  : 'No excuse requests match your filters',
                                style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold),
                              ),
                              if (requests.isNotEmpty)
                                TextButton(
                                  onPressed: () => setState(() {
                                    _selectedFilter = 'All';
                                    _searchQuery = '';
                                  }),
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
        error: (err, _) => Center(child: Text('Error loading excuses: $err', style: const TextStyle(color: Colors.red))),
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
                  DataColumn(label: Text('EVENT', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  DataColumn(label: Text('REASON TYPE', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  DataColumn(label: Text('EXPLANATION', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  DataColumn(label: Text('SUBMITTED AT', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  DataColumn(label: Text('STATUS', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                  DataColumn(label: Text('ACTIONS', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))),
                ],
                rows: requests.map((req) {
                  String reasonType = 'General';
                  String explanation = req.reason;
                  if (req.reason.startsWith('[')) {
                    final closeBracket = req.reason.indexOf(']');
                    if (closeBracket > 1) {
                      reasonType = req.reason.substring(1, closeBracket);
                      explanation = req.reason.substring(closeBracket + 1).trim();
                    }
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            req.eventName ?? 'Event',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
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
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: Text(
                            explanation,
                            style: AppTextStyles.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(Text(
                        req.createdAt != null ? DateFormat('MMM d, yyyy h:mm a').format(req.createdAt!.toLocal()) : '—',
                        style: AppTextStyles.bodyMedium,
                      )),
                      DataCell(_StatusBadge(status: req.status)),
                      DataCell(
                        TextButton(
                          onPressed: () => _showDetailsDialog(req),
                          child: const Text('View Details'),
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
      itemBuilder: (context, index) {
        final req = requests[index];
        
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
                      child: Text(
                        req.eventName ?? 'Event Name',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusBadge(status: req.status),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow('Reason Type:', reasonType),
                _buildInfoRow('Explanation:', explanation, maxLines: 2),
                _buildInfoRow('Submitted:', req.createdAt != null ? DateFormat('MMM d, yyyy h:mm a').format(req.createdAt!.toLocal()) : '—'),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showDetailsDialog(req),
                    child: const Text('View Details'),
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
            width: 100,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodySmall, maxLines: maxLines, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(ExcuseRequestModel request) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ExcuseDetailsDialog(request: request),
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

class _ExcuseDetailsDialog extends StatelessWidget {
  final ExcuseRequestModel request;

  const _ExcuseDetailsDialog({required this.request});

  @override
  Widget build(BuildContext context) {
    String reasonType = 'General';
    String explanation = request.reason;
    if (request.reason.startsWith('[')) {
      final closeBracket = request.reason.indexOf(']');
      if (closeBracket > 1) {
        reasonType = request.reason.substring(1, closeBracket);
        explanation = request.reason.substring(closeBracket + 1).trim();
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 650 ? 600.0 : screenWidth * 0.95;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  Text('Excuse Request Details', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),

              _buildRowDetail('Target Event:', request.eventName ?? 'Unknown Event'),
              _buildRowDetail('Reason Type:', reasonType),
              _buildRowDetail('Explanation:', explanation),
              _buildRowDetail('Submitted:', request.createdAt != null ? DateFormat('MMM d, yyyy h:mm a').format(request.createdAt!.toLocal()) : '—'),
              
              const SizedBox(height: AppSpacing.sm),
              _buildRowDetail(
                'Current Status:', 
                request.status, 
                valueColor: request.status == 'Approved' 
                    ? AppColors.success 
                    : (request.status == 'Rejected' ? AppColors.error : AppColors.warning),
              ),
              
              if (request.status != 'Pending') ...[
                if (request.reviewedByName != null)
                  _buildRowDetail('Reviewed By:', request.reviewedByName!),
                if (request.rejectionReason != null && request.rejectionReason!.isNotEmpty)
                  _buildRowDetail('Remarks:', request.rejectionReason!),
              ],
              const SizedBox(height: AppSpacing.lg),

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
                  request.supportingDocumentUrl,
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
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowDetail(String label, String value, {Color? valueColor}) {
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
