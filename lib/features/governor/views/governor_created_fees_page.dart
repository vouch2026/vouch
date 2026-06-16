import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';
import '../../finance/models/fee_model.dart';
import '../../finance/providers/finance_provider.dart';
import 'governor_create_fee_page.dart';
import 'governor_fee_report_page.dart';

class GovernorCreatedFeesPage extends ConsumerStatefulWidget {
  const GovernorCreatedFeesPage({super.key});

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

    return DashboardLayout(
      title: 'Manage Fees',
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: SingleChildScrollView(
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
              title: 'Manage Fees',
              subtitle: 'View and edit the payment requirements you have created.',
              actions: [
                HeaderActionButton(
                  icon: Icons.add_rounded,
                  label: 'Create Fee',
                  onPressed: () => _navigateToCreate(context),
                  isPrimary: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            feesAsync.when(
              data: (fees) {
                if (fees.isEmpty) {
                  return _buildEmptyState();
                }

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
                    // Search Bar
                    Container(
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
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Filters Row
                    Row(
                      children: [
                        // Category Filter
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
                        // Deadline Status Filter
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
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    if (filteredFees.isEmpty)
                      _buildNoResultsState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredFees.length,
                        separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final fee = filteredFees[index];
                          return _buildFeeCard(context, fee);
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fee.name,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
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
                    ],
                  ),
                ),
                Text(
                  '₱${fee.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                PopupMenuButton<String>(
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
            if (fee.description != null && fee.description!.isNotEmpty)
              Text(
                fee.description!,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700], height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GovernorFeeReportPage(fee: fee),
                    ),
                  ),
                  child: const Text('View Paid Students'),
                ),
              ],
            ),
          ],
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
