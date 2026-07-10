import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/route_names.dart';
import '../../finance/models/fee_model.dart';
import '../../finance/providers/finance_provider.dart';
import 'governor_create_fee_page.dart';
import 'governor_fee_report_page.dart';

class GovernorCreatedFeesPage extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final bool isTopLevel;

  const GovernorCreatedFeesPage({
    super.key,
    this.title = 'Manage Fees',
    this.subtitle = 'View and edit the payment requirements you have created.',
    this.showBackButton = true,
    this.isTopLevel = false,
  });

  @override
  ConsumerState<GovernorCreatedFeesPage> createState() => _GovernorCreatedFeesPageState();
}

class _GovernorCreatedFeesPageState extends ConsumerState<GovernorCreatedFeesPage> {
  late final TextEditingController _searchController;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedDeadline = 'All';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper to check if a fee is active
  bool _isFeeActive(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final feeDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return feeDate.isAfter(today) || feeDate.isAtSameMomentAs(today);
  }

  @override
  Widget build(BuildContext context) {
    final feesAsync = ref.watch(workspaceFeesProvider);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
    final padding = isMobile 
        ? AppSpacing.md 
        : (isTablet ? AppSpacing.lg : AppSpacing.xl);

    return DashboardLayout(
      title: widget.title,
      onBack: widget.showBackButton
          ? () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          : null,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs Header
            if (widget.isTopLevel)
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text(
                    'Collections',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(Icons.payments_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Fees',
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
                      'Manage Fees',
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
            UserManagementHeader(
              title: widget.title,
              subtitle: widget.subtitle,
              actions: [
                HeaderActionButton(
                  icon: Icons.add_rounded,
                  label: 'Create Fee',
                  onPressed: () => _navigateToCreate(context),
                  isPrimary: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            feesAsync.when(
              data: (fees) {
                if (fees.isEmpty) {
                  return _buildEmptyState();
                }

                // Stats calculation
                final totalFees = fees.length;
                final mandatoryCount = fees.where((f) => f.isMandatory).length;
                final activeCount = fees.where((f) => _isFeeActive(f.dueDate)).length;
                final inactiveCount = fees.where((f) => !_isFeeActive(f.dueDate)).length;

                // Apply filtering
                final filteredFees = fees.where((fee) {
                  // Search query filter
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    final nameMatch = fee.name.toLowerCase().contains(query);
                    final descMatch = fee.description?.toLowerCase().contains(query) ?? false;
                    if (!nameMatch && !descMatch) return false;
                  }
                  
                  // Category filter
                  if (_selectedCategory == 'Mandatory' && !fee.isMandatory) {
                    return false;
                  }
                  if (_selectedCategory == 'Non-Mandatory' && fee.isMandatory) {
                    return false;
                  }
                  
                  // Deadline filter
                  if (_selectedDeadline == 'Active' && !_isFeeActive(fee.dueDate)) {
                    return false;
                  }
                  if (_selectedDeadline == 'Past Deadline' && _isFeeActive(fee.dueDate)) {
                    return false;
                  }
                  
                  return true;
                }).toList();

                // Sort by nearest due date (absolute difference from today)
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                filteredFees.sort((a, b) {
                  final diffA = a.dueDate.difference(today).abs();
                  final diffB = b.dueDate.difference(today).abs();
                  return diffA.compareTo(diffB);
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards Dashboard
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossCount = 1;
                        double ratio = 3.5;
                        if (constraints.maxWidth > 1100) {
                          crossCount = 4;
                          ratio = 2.5;
                        } else if (constraints.maxWidth > 600) {
                          crossCount = 2;
                          ratio = 2.5;
                        }
                        
                        return GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossCount,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: ratio,
                          ),
                          children: [
                            _buildStatCard(
                              title: 'Total Fees',
                              value: totalFees.toString(),
                              icon: Icons.payments_rounded,
                              color: AppColors.primary,
                            ),
                            _buildStatCard(
                              title: 'Active Requirements',
                              value: activeCount.toString(),
                              icon: Icons.pending_actions_rounded,
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              title: 'Inactive Fees',
                              value: inactiveCount.toString(),
                              icon: Icons.history_rounded,
                              color: Colors.red,
                            ),
                            _buildStatCard(
                              title: 'Mandatory Fees',
                              value: mandatoryCount.toString(),
                              icon: Icons.assignment_late_rounded,
                              color: Colors.orange,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Search & Filters Row
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 768;
                        
                        final searchField = Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search by fee name or description...',
                              hintStyle: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[400],
                              ),
                              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            style: AppTextStyles.bodyMedium,
                          ),
                        );

                        final filterChips = [
                          PopupMenuButton<String>(
                            onSelected: (val) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'All', child: Text('All Types')),
                              const PopupMenuItem(value: 'Mandatory', child: Text('Mandatory')),
                              const PopupMenuItem(value: 'Non-Mandatory', child: Text('Non-Mandatory')),
                            ],
                            child: _buildFilterChip(
                              label: _selectedCategory == 'All' ? 'Type: All' : _selectedCategory,
                              isSelected: _selectedCategory != 'All',
                              trailingIcon: Icons.arrow_drop_down_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (val) {
                              setState(() {
                                _selectedDeadline = val;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'All', child: Text('All Statuses')),
                              const PopupMenuItem(value: 'Active', child: Text('Active')),
                              const PopupMenuItem(value: 'Past Deadline', child: Text('Past Deadline')),
                            ],
                            child: _buildFilterChip(
                              label: _selectedDeadline == 'All' ? 'Status: All' : _selectedDeadline,
                              isSelected: _selectedDeadline != 'All',
                              trailingIcon: Icons.arrow_drop_down_rounded,
                            ),
                          ),
                        ];

                        if (isSmallScreen) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              searchField,
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: filterChips,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: searchField,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            ...filterChips,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    if (filteredFees.isEmpty)
                      _buildNoResultsState()
                    else
                      LayoutBuilder(
                        builder: (context, gridConstraints) {
                          int crossAxisCount = 1;
                          if (gridConstraints.maxWidth > 1200) {
                            crossAxisCount = 3;
                          } else if (gridConstraints.maxWidth > 768) {
                            crossAxisCount = 2;
                          }

                          if (crossAxisCount == 1) {
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredFees.length,
                              separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final fee = filteredFees[index];
                                return _buildFeeCard(context, fee);
                              },
                            );
                          } else {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                                mainAxisExtent: 260,
                              ),
                              itemCount: filteredFees.length,
                              itemBuilder: (context, index) {
                                final fee = filteredFees[index];
                                return _buildFeeCard(context, fee);
                              },
                            );
                          }
                        },
                      ),
                  ],
                );
              },
              loading: () => const Center(child: FlickrLoader()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    IconData? trailingIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary 
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? AppColors.primary 
              : Colors.transparent,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            Icon(
              trailingIcon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeeCard(BuildContext context, FeeModel fee) {
    final theme = Theme.of(context);
    final isActive = _isFeeActive(fee.dueDate);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.pushNamed(
          RouteNames.workspaceCollectionsReport,
          extra: fee,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCardNarrow = constraints.maxWidth < 460;
              final hasDesc = fee.description != null && fee.description!.isNotEmpty;
              final isBounded = constraints.maxHeight.isFinite;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fee.name,
                              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: fee.isMandatory 
                                    ? AppColors.primary.withValues(alpha: 0.1) 
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: fee.isMandatory 
                                      ? AppColors.primary.withValues(alpha: 0.2) 
                                      : Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                fee.isMandatory ? 'MANDATORY' : 'NON-MANDATORY',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: fee.isMandatory ? AppColors.primary : Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '₱${fee.amount.toStringAsFixed(2)}',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        onSelected: (val) {
                          if (val == 'edit') {
                            _navigateToEdit(context, fee);
                          } else if (val == 'delete') {
                            _deleteFee(context, fee);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit Fee')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete Fee', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (hasDesc) ...[
                    Text(
                      fee.description!,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700], height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (isBounded) const Spacer(),
                  if (!isBounded) const SizedBox(height: AppSpacing.lg),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.md),
                  if (isCardNarrow) ...[
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${DateFormat.yMMMd().format(fee.dueDate)}',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive 
                                ? Colors.green.withValues(alpha: 0.1) 
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isActive 
                                  ? Colors.green.withValues(alpha: 0.2) 
                                  : Colors.red.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            isActive ? 'ACTIVE' : 'PAST DEADLINE',
                            style: TextStyle(
                              color: isActive ? Colors.green[700] : Colors.red[700],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () => context.pushNamed(
                          RouteNames.workspaceCollectionsReport,
                          extra: fee,
                        ),
                        child: const Text('View Payment Report'),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${DateFormat.yMMMd().format(fee.dueDate)}',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive 
                                ? Colors.green.withValues(alpha: 0.1) 
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isActive 
                                  ? Colors.green.withValues(alpha: 0.2) 
                                  : Colors.red.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            isActive ? 'ACTIVE' : 'PAST DEADLINE',
                            style: TextStyle(
                              color: isActive ? Colors.green[700] : Colors.red[700],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        FilledButton.tonal(
                          onPressed: () => context.pushNamed(
                            RouteNames.workspaceCollectionsReport,
                            extra: fee,
                          ),
                          child: const Text('View Payment Report'),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: AppSpacing.md),
          const Text('No fees created yet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No fees match your filters',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search query or filters',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GovernorCreateFeePage()));
  }

  void _navigateToEdit(BuildContext context, FeeModel fee) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => GovernorCreateFeePage(initialData: fee)));
  }

  Future<void> _deleteFee(BuildContext context, FeeModel fee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fee'),
        content: Text('Are you sure you want to delete "${fee.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(financeRepositoryProvider).deleteFee(fee.id!);
        ref.invalidate(workspaceFeesProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fee deleted successfully')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}
