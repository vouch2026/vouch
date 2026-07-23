import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loaders/flickr_loader.dart';
import '../../../../shared/layouts/dashboard_layout.dart';
import '../../profile/providers/account_deletion_provider.dart';
import '../../profile/controllers/account_deletion_controller.dart';
import '../../profile/models/account_deletion_request.dart';
import '../widgets/user_management_header.dart';

class AccountDeletionRequestsPage extends ConsumerStatefulWidget {
  const AccountDeletionRequestsPage({super.key});

  @override
  ConsumerState<AccountDeletionRequestsPage> createState() => _AccountDeletionRequestsPageState();
}

class _AccountDeletionRequestsPageState extends ConsumerState<AccountDeletionRequestsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSelectionMode = false;
  final Set<String> _selectedUserIds = {};
  final Set<String> _selectedRequestIds = {};
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 0;
    });
  }

  void _navigateToProfile(BuildContext context, String userId) {
    context.pushNamed(
      RouteNames.userDetails,
      pathParameters: {'id': userId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(accountDeletionRequestsProvider);
    final allRequests = requestsAsync.value ?? <AccountDeletionRequest>[];

    final filteredRequests = allRequests.where((req) {
      final query = _searchController.text.toLowerCase();
      return req.fullName.toLowerCase().contains(query) ||
          req.studentIdNumber.toLowerCase().contains(query) ||
          req.email.toLowerCase().contains(query);
    }).toList();

    final totalItems = filteredRequests.length;
    final maxPages = (totalItems / _rowsPerPage).ceil();
    final safePage = _currentPage >= maxPages ? (maxPages > 0 ? maxPages - 1 : 0) : _currentPage;
    final startIndex = safePage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > totalItems ? totalItems : (startIndex + _rowsPerPage);
    final paginatedRequests = totalItems == 0 ? <AccountDeletionRequest>[] : filteredRequests.sublist(startIndex, endIndex);

    final isMobile = MediaQuery.of(context).size.width < 768;

    return DashboardLayout(
      title: 'Deletion Requests',
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: 100, // Extra padding at bottom for the floating bar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserManagementHeader(
                    title: 'Account Deletion Requests',
                    subtitle: 'Review and process student requests to permanently purge accounts and clear institutional records.',
                    actions: [
                      HeaderActionButton(
                        icon: _isSelectionMode ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        label: _isSelectionMode ? 'Cancel Bulk' : 'Bulk Select',
                        onPressed: () {
                          setState(() {
                            _isSelectionMode = !_isSelectionMode;
                            if (!_isSelectionMode) {
                              _selectedUserIds.clear();
                              _selectedRequestIds.clear();
                            }
                          });
                        },
                      ),
                      HeaderActionButton(
                        icon: Icons.refresh_rounded,
                        label: 'Refresh',
                        onPressed: () {
                          ref.invalidate(accountDeletionRequestsProvider);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // KPI Summary Card
                  _buildKpiCard(context, requestsAsync),
                  const SizedBox(height: AppSpacing.xl),

                  // Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search by name, ID, or email...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Requests List/Table
                  requestsAsync.when(
                    data: (requests) {
                      if (filteredRequests.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 900) {
                                return _buildCardList(context, ref, paginatedRequests);
                              }
                              return _buildDataTable(context, ref, paginatedRequests);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildPaginationFooter(totalItems, safePage, _rowsPerPage),
                        ],
                      );
                    },
                    loading: () => const Center(child: FlickrLoader()),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text('Error loading requests: $err', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating bulk action bar
          if (_selectedUserIds.isNotEmpty)
            Positioned(
              bottom: AppSpacing.lg,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: Card(
                elevation: 6,
                color: Theme.of(context).colorScheme.inverseSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedUserIds.length} requests selected',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedUserIds.clear();
                                _selectedRequestIds.clear();
                              });
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.8),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                            icon: const Icon(LucideIcons.xCircle, size: 18, color: Colors.white70),
                            label: const Text('Reject Selected'),
                            onPressed: () => _showBulkRejectConfirmDialog(context, ref),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(LucideIcons.userX, size: 18),
                            label: const Text('Approve & Purge Selected'),
                            onPressed: () => _showBulkDeleteConfirmDialog(context, ref),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, AsyncValue<List<AccountDeletionRequest>> requestsAsync) {
    final theme = Theme.of(context);
    final count = requestsAsync.value?.length ?? 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.userX, color: AppColors.error, size: 28),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pending Deletion Requests',
                    style: AppTextStyles.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    requestsAsync.isLoading ? '...' : '$count Requests',
                    style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Awaiting clearance check and administrator review before final purge.',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl * 2),
        child: Column(
          children: [
            Icon(LucideIcons.shieldCheck, size: 64, color: AppColors.success.withOpacity(0.8)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Deletion Requests',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'All student accounts are active, and no deletion requests are currently pending review.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, WidgetRef ref, List<AccountDeletionRequest> requests) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.04)),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return AppColors.primary.withValues(alpha: 0.02);
                  }
                  return null;
                }),
                columnSpacing: 24,
                horizontalMargin: 16,
                headingRowHeight: 48,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 48,
                border: TableBorder(
                  horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
                  verticalInside: BorderSide(color: Colors.grey.shade100, width: 0.5),
                ),
                showCheckboxColumn: _isSelectionMode,
                onSelectAll: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedUserIds.addAll(requests.map((r) => r.userId));
                      _selectedRequestIds.addAll(requests.map((r) => r.id));
                    } else {
                      for (final r in requests) {
                        _selectedUserIds.remove(r.userId);
                        _selectedRequestIds.remove(r.id);
                      }
                    }
                  });
                },
                columns: [
                  DataColumn(
                    label: Text(
                      'Student Info',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Student ID',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Clearance Ack',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Data Loss Ack',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Submitted At',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Actions',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                rows: requests.map((request) {
                  final isSelected = _selectedUserIds.contains(request.userId);
                  return DataRow(
                    selected: isSelected,
                    onSelectChanged: (selected) {
                      if (_isSelectionMode) {
                        setState(() {
                          if (selected == true) {
                            _selectedUserIds.add(request.userId);
                            _selectedRequestIds.add(request.id);
                          } else {
                            _selectedUserIds.remove(request.userId);
                            _selectedRequestIds.remove(request.id);
                          }
                        });
                      } else {
                        _navigateToProfile(context, request.userId);
                      }
                    },
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: _isSelectionMode ? null : () => _navigateToProfile(context, request.userId),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(request.fullName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                Text(request.email, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Tooltip(
                          message: 'Double click to copy, Single click to view profile',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: _isSelectionMode ? null : () => _navigateToProfile(context, request.userId),
                            onDoubleTap: () {
                              Clipboard.setData(ClipboardData(text: request.studentIdNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${request.studentIdNumber} copied to clipboard'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(request.studentIdNumber, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.copy, size: 12, color: AppColors.textGrey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        InkWell(
                          onTap: _isSelectionMode ? null : () => _navigateToProfile(context, request.userId),
                          child: _buildAckBadge(request.acknowledgedClearance),
                        ),
                      ),
                      DataCell(
                        InkWell(
                          onTap: _isSelectionMode ? null : () => _navigateToProfile(context, request.userId),
                          child: _buildAckBadge(request.acknowledgedDataLoss),
                        ),
                      ),
                      DataCell(
                        InkWell(
                          onTap: _isSelectionMode ? null : () => _navigateToProfile(context, request.userId),
                          child: Text(
                            request.createdAt != null
                                ? DateFormat('yyyy-MM-dd HH:mm').format(request.createdAt!.toLocal())
                                : 'N/A',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ),
                      DataCell(
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, size: 20),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteConfirmDialog(context, ref, request);
                            } else if (value == 'reject') {
                              _showRejectConfirmDialog(context, ref, request);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.userX, color: AppColors.error, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Approve & Delete Account', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'reject',
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.xCircle, color: AppColors.textGrey, size: 16),
                                  const SizedBox(width: 8),
                                  const Text('Reject/Dismiss Request'),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildCardList(BuildContext context, WidgetRef ref, List<AccountDeletionRequest> requests) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final request = requests[index];
        final isSelected = _selectedUserIds.contains(request.userId);
        final dateStr = request.createdAt != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(request.createdAt!.toLocal())
            : 'N/A';

        return Card(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15) : null,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: InkWell(
            onTap: () {
              if (_isSelectionMode) {
                setState(() {
                  if (isSelected) {
                    _selectedUserIds.remove(request.userId);
                    _selectedRequestIds.remove(request.id);
                  } else {
                    _selectedUserIds.add(request.userId);
                    _selectedRequestIds.add(request.id);
                  }
                });
              } else {
                _navigateToProfile(context, request.userId);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedUserIds.add(request.userId);
                            _selectedRequestIds.add(request.id);
                          } else {
                            _selectedUserIds.remove(request.userId);
                            _selectedRequestIds.remove(request.id);
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(request.fullName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            if (!_isSelectionMode)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, size: 20),
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _showDeleteConfirmDialog(context, ref, request);
                                  } else if (value == 'reject') {
                                    _showRejectConfirmDialog(context, ref, request);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(LucideIcons.userX, color: AppColors.error, size: 16),
                                        const SizedBox(width: 8),
                                        Text('Approve & Delete Account', style: TextStyle(color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'reject',
                                    child: Row(
                                      children: [
                                        const Icon(LucideIcons.xCircle, color: AppColors.textGrey, size: 16),
                                        const SizedBox(width: 8),
                                        const Text('Reject/Dismiss Request'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        Text('Email: ${request.email}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                        Row(
                          children: [
                            Text('Student ID: ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                            InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: _isSelectionMode ? null : () => _navigateToProfile(context, request.userId),
                              onDoubleTap: () {
                                Clipboard.setData(ClipboardData(text: request.studentIdNumber));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${request.studentIdNumber} copied to clipboard'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      request.studentIdNumber,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(LucideIcons.copy, size: 10, color: AppColors.textGrey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('Submitted At: $dateStr', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                        const Divider(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Text('Clearance Ack: ', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                  _buildAckBadge(request.acknowledgedClearance),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Text('Data Loss Ack: ', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                  _buildAckBadge(request.acknowledgedDataLoss),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAckBadge(bool acknowledged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (acknowledged ? AppColors.success : AppColors.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        acknowledged ? 'Yes' : 'No',
        style: AppTextStyles.labelSmall.copyWith(
          color: acknowledged ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(int totalItems, int currentPage, int rowsPerPage) {
    final totalPages = (totalItems / rowsPerPage).ceil();
    final startItem = totalItems == 0 ? 0 : (currentPage * rowsPerPage) + 1;
    final endItem = (currentPage * rowsPerPage) + rowsPerPage > totalItems
        ? totalItems
        : (currentPage * rowsPerPage) + rowsPerPage;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        final dropdownWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isNarrow ? 'Rows:' : 'Rows per page:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: rowsPerPage,
                  icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54),
                  elevation: 4,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  items: [5, 10, 20, 50].map((val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text(
                        '$val',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _rowsPerPage = val;
                        _currentPage = 0;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        );

        final infoTextWidget = Text(
          'Showing $startItem-$endItem of $totalItems',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        );

        final navigationWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page_rounded, size: 18),
              onPressed: currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage = 0;
                      });
                    }
                  : null,
              tooltip: 'First Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 18),
              onPressed: currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage = currentPage - 1;
                      });
                    }
                  : null,
              tooltip: 'Previous Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${currentPage + 1} / ${totalPages > 0 ? totalPages : 1}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 18),
              onPressed: currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage = currentPage + 1;
                      });
                    }
                  : null,
              tooltip: 'Next Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.last_page_rounded, size: 18),
              onPressed: currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage = totalPages - 1;
                      });
                    }
                  : null,
              tooltip: 'Last Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    dropdownWidget,
                    infoTextWidget,
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                navigationWidget,
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              dropdownWidget,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  infoTextWidget,
                  const SizedBox(width: 24),
                  navigationWidget,
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, AccountDeletionRequest request) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(LucideIcons.alertTriangle, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            const Text('Approve & Purge User'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete the account of ${request.fullName} (${request.studentIdNumber})? '
          'This action is irreversible and will delete all student records and data across all tables.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(accountDeletionControllerProvider.notifier)
                  .deleteRequestAndUser(userId: request.userId);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account permanently deleted.'), backgroundColor: AppColors.success),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete account.'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Purge Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectConfirmDialog(BuildContext context, WidgetRef ref, AccountDeletionRequest request) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Deletion Request'),
        content: Text(
          'Are you sure you want to reject the deletion request for ${request.fullName} (${request.studentIdNumber})? '
          'This will delete the request record, and the student\'s account will remain active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(accountDeletionControllerProvider.notifier)
                  .rejectRequest(request.id);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deletion request rejected.'), backgroundColor: AppColors.success),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to reject request.'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Reject Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBulkDeleteConfirmDialog(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(LucideIcons.alertTriangle, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            const Text('Approve & Purge Selected Accounts'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete the accounts of the ${_selectedUserIds.length} selected students? '
          'This action is irreversible and will delete all student records and data across all tables.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final idsToProcess = _selectedUserIds.toList();
              final success = await ref
                  .read(accountDeletionControllerProvider.notifier)
                  .bulkApproveAndDelete(idsToProcess);

              if (success && context.mounted) {
                setState(() {
                  _selectedUserIds.clear();
                  _selectedRequestIds.clear();
                  _isSelectionMode = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selected accounts permanently deleted.'), backgroundColor: AppColors.success),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Some accounts failed to delete.'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Purge Accounts'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBulkRejectConfirmDialog(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Selected Deletion Requests'),
        content: Text(
          'Are you sure you want to reject the deletion requests for the ${_selectedRequestIds.length} selected students? '
          'This will dismiss the requests, and the student accounts will remain active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final idsToProcess = _selectedRequestIds.toList();
              final success = await ref
                  .read(accountDeletionControllerProvider.notifier)
                  .bulkReject(idsToProcess);

              if (success && context.mounted) {
                setState(() {
                  _selectedUserIds.clear();
                  _selectedRequestIds.clear();
                  _isSelectionMode = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selected requests rejected.'), backgroundColor: AppColors.success),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to reject requests.'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Reject Requests'),
          ),
        ],
      ),
    );
  }
}
