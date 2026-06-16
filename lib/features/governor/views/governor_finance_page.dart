import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../../finance/models/fee_model.dart';
import '../../finance/models/student_payment_model.dart';
import '../../finance/providers/finance_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../widgets/governor_receiver_card.dart';
import '../widgets/governor_submission_card.dart';
import 'governor_add_receiver_page.dart';
import 'governor_create_fee_page.dart';
import 'governor_created_fees_page.dart';
import '../../finance/views/student_proof_of_payment_page.dart';

class GovernorFinancePage extends ConsumerStatefulWidget {
  const GovernorFinancePage({super.key});

  @override
  ConsumerState<GovernorFinancePage> createState() => _GovernorFinancePageState();
}

class _GovernorFinancePageState extends ConsumerState<GovernorFinancePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFeeFilter = 'All Fees';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceProvider);
    final activeRole = workspace.activeRole;
    final isStudentOrMember = activeRole?.roleName == 'Student' || activeRole?.roleName == 'Member';

    if (isStudentOrMember) {
      return const _StudentFinanceView();
    }

    final theme = Theme.of(context);
    final receiversAsync = ref.watch(paymentReceiversProvider);
    final submissionsAsync = ref.watch(workspaceStudentPaymentsProvider);
    final feesAsync = ref.watch(workspaceFeesProvider);

    return DashboardLayout(
      title: 'Organization Finance',
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                  child: Row(
                    children: [
                      Icon(Icons.payments_outlined, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Text(
                        'Fees',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
                  child: UserManagementHeader(
                    title: 'Finance & Collections',
                    subtitle: 'Manage fees, verify student payments, and track organization funds',
                    actions: [
                      HeaderActionButton(
                        icon: Icons.add_card_rounded,
                        label: 'Create Fee',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GovernorCreateFeePage())),
                        isPrimary: true,
                      ),
                      HeaderActionButton(
                        icon: Icons.list_alt_rounded,
                        label: 'Manage Fees',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GovernorCreatedFeesPage())),
                      ),
                    ],
                  ),
                ),

                // Receiver References Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.account_balance_wallet_rounded, size: 20, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'PAYMENT REFERENCES',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GovernorAddReceiverPage())),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Card'),
                        style: TextButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                receiversAsync.when(
                  data: (receivers) => LayoutBuilder(
                    builder: (context, constraints) {
                      // Use grid for all sizes, adjusting columns
                      int crossAxisCount = 1;
                      if (constraints.maxWidth > 1400) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth > 1000) {
                        crossAxisCount = 3;
                      } else if (constraints.maxWidth > 700) {
                        crossAxisCount = 2;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: AppSpacing.lg,
                            mainAxisSpacing: AppSpacing.lg,
                            mainAxisExtent: 210,
                          ),
                          itemCount: receivers.length,
                          itemBuilder: (context, index) => GovernorReceiverCard(
                            receiver: receivers[index],
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GovernorAddReceiverPage(
                                  initialData: receivers[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(child: FlickrLoader()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Submissions Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.people_alt_rounded, size: 20, color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'STUDENT SUBMISSIONS',
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          isWide 
                            ? Row(
                                children: [
                                  Expanded(child: _buildSearchField()),
                                  const SizedBox(width: AppSpacing.lg),
                                  _buildFeeTypeFilter(feesAsync),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildSearchField(),
                                  const SizedBox(height: AppSpacing.md),
                                  SizedBox(width: double.infinity, child: _buildFeeTypeFilter(feesAsync)),
                                ],
                              ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: Colors.grey[600],
                      dividerColor: Colors.transparent,
                      indicatorColor: theme.colorScheme.primary,
                      indicatorWeight: 3,
                      labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'Pending'),
                        Tab(text: 'Approved'),
                        Tab(text: 'Rejected'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
        body: submissionsAsync.when(
          data: (submissions) => TabBarView(
            controller: _tabController,
            children: [
              _buildSubmissionList(submissions, 'Pending'),
              _buildSubmissionList(submissions, 'Paid'), // Maps to 'Approved' in UI
              _buildSubmissionList(submissions, 'Rejected'),
            ],
          ),
          loading: () => const Center(child: FlickrLoader()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
}

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search student or fee title...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      ),
    );
  }

  Widget _buildFeeTypeFilter(AsyncValue<List<FeeModel>> feesAsync) {
    final fees = feesAsync.valueOrNull ?? [];
    final feeNames = ['All Fees', ...fees.map((f) => f.name).toSet()];

    return PopupMenuButton<String>(
      onSelected: (val) {
        setState(() {
          _selectedFeeFilter = val;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) => feeNames.map((name) => PopupMenuItem(
        value: name,
        child: Text(name),
      )).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                _selectedFeeFilter,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionList(List<StudentPaymentModel> submissions, String status) {
    final query = _searchController.text.toLowerCase();
    final filtered = submissions.where((s) {
      final matchesStatus = s.status == status;
      final matchesQuery = (s.studentName?.toLowerCase().contains(query) ?? false) ||
                          (s.feeName?.toLowerCase().contains(query) ?? false);
      final matchesFee = _selectedFeeFilter == 'All Fees' || s.feeName == _selectedFeeFilter;
      return matchesStatus && matchesQuery && matchesFee;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long_outlined, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No $status Submissions',
                style: AppTextStyles.titleMedium.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Student payments will appear here for verification.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1400) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 1000) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 700) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            mainAxisExtent: 300,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) => GovernorSubmissionCard(
            submission: filtered[index],
            onApprove: () => _updateStatus(filtered[index].id!, 'Paid'),
            onReject: () => _showRejectDialog(filtered[index].id!),
            onViewReceipt: () => _showReceiptPreview(context, filtered[index]),
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(String id, String status, [String? reason]) async {
    try {
      final user = ref.read(userProfileProvider).value!;
      await ref.read(financeRepositoryProvider).updatePaymentStatus(id, status, reason, user.id!);
      ref.invalidate(workspaceStudentPaymentsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment $status successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showRejectDialog(String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Payment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Reason for rejection...',
            labelText: 'Reason',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(id, 'Rejected', controller.text);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showReceiptPreview(BuildContext context, StudentPaymentModel submission) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.xl),
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
                child: submission.proofPhotoUrl != null 
                  ? Image.network(
                      submission.proofPhotoUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: FlickrLoader());
                      },
                      errorBuilder: (context, error, stackTrace) => _buildImageError(),
                    )
                  : _buildImageError(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${submission.studentName ?? 'Unknown Student'} • ${submission.studentIdNumber ?? 'No ID'}',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${submission.feeName} • ₱${submission.amountPaid.toStringAsFixed(2)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      padding: const EdgeInsets.all(32),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_outlined, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Unable to load receipt image', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _StudentFinanceView extends ConsumerStatefulWidget {
  const _StudentFinanceView();

  @override
  ConsumerState<_StudentFinanceView> createState() => _StudentFinanceViewState();
}

class _StudentFinanceViewState extends ConsumerState<_StudentFinanceView> {
  String _categoryFilter = 'All'; // All, Mandatory, Non-Mandatory
  String _statusFilter = 'All';   // All, To Pay, Pending, Paid

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feesAsync = ref.watch(workspaceFeesProvider);
    final submissionsAsync = ref.watch(workspaceStudentPaymentsProvider);
    final userProfile = ref.watch(userProfileProvider).value;

    return DashboardLayout(
      title: 'My Fees & Payments',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workspaceFeesProvider);
          ref.invalidate(workspaceStudentPaymentsProvider);
          ref.invalidate(paymentReceiversProvider);
        },
        child: feesAsync.when(
          data: (fees) => submissionsAsync.when(
            data: (submissions) {
              final mySubmissions = submissions.where((s) => s.studentId == userProfile?.id).toList();
              
              StudentPaymentModel? getLatestSubmission(String feeId) {
                final feeSubmissions = mySubmissions.where((s) => s.feeId == feeId).toList();
                return feeSubmissions.where((s) => s.status == 'Paid').firstOrNull ??
                       feeSubmissions.where((s) => s.status == 'Pending').firstOrNull ??
                       feeSubmissions.firstOrNull;
              }
              
              // Calculate Total Payable (Outstanding Balance) responding to category filter
              final totalPayable = fees.where((fee) {
                if (_categoryFilter == 'Mandatory') return fee.isMandatory;
                if (_categoryFilter == 'Non-Mandatory') return !fee.isMandatory;
                return true;
              }).where((fee) {
                final submission = getLatestSubmission(fee.id!);
                final status = submission?.status ?? 'To Pay';
                return status == 'To Pay' || status == 'Rejected';
              }).fold<double>(0, (sum, fee) => sum + fee.amount);
              
              // Apply Filtering
              final filteredFees = fees.where((fee) {
                final submission = getLatestSubmission(fee.id!);
                final status = submission?.status ?? 'To Pay';
                
                // Category Filter
                bool categoryMatch = true;
                if (_categoryFilter == 'Mandatory') categoryMatch = fee.isMandatory;
                if (_categoryFilter == 'Non-Mandatory') categoryMatch = !fee.isMandatory;
                
                // Status Filter
                bool statusMatch = true;
                if (_statusFilter == 'To Pay') statusMatch = status == 'To Pay' || status == 'Rejected';
                if (_statusFilter == 'Pending') statusMatch = status == 'Pending';
                if (_statusFilter == 'Paid') statusMatch = status == 'Paid';
                
                return categoryMatch && statusMatch;
              }).toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final horizontalPadding = isMobile ? AppSpacing.md : AppSpacing.lg;

                  int crossAxisCount = 1;
                  if (constraints.maxWidth > 1400) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth > 1000) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 700) {
                    crossAxisCount = 2;
                  }
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: AppSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Breadcrumbs Header
                              Row(
                                children: [
                                  Icon(Icons.payments_outlined, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Fees',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              UserManagementHeader(
                                title: 'Organization Fees',
                                subtitle: 'View and settle your organization-related fees',
                                actions: const [],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 600),
                                  child: _buildSummaryCard(totalPayable, userProfile?.schoolId ?? 'Unknown'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              
                              // Filters Row
                              _buildFiltersRow(theme),
                              
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'AVAILABLE FEES (${filteredFees.length})',
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      if (filteredFees.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: _buildEmptyState(
                              context,
                              Icons.receipt_long_outlined,
                              'No fees match your filters.',
                            ),
                          ),
                        )
                      else if (isMobile)
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final fee = filteredFees[index];
                                final submission = getLatestSubmission(fee.id!);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: _StudentFeeCard(fee: fee, submission: submission),
                                );
                              },
                              childCount: filteredFees.length,
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: AppSpacing.lg,
                              mainAxisSpacing: AppSpacing.lg,
                              mainAxisExtent: 210,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final fee = filteredFees[index];
                                final submission = getLatestSubmission(fee.id!);
                                return _StudentFeeCard(fee: fee, submission: submission);
                              },
                              childCount: filteredFees.length,
                            ),
                          ),
                        ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(horizontalPadding, AppSpacing.xxl, horizontalPadding, AppSpacing.md),
                          child: Text(
                            'MY PAYMENT HISTORY',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      if (mySubmissions.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: _buildEmptyState(
                              context,
                              Icons.history_rounded,
                              'You haven\'t submitted any payments yet.',
                            ),
                          ),
                        )
                      else if (isMobile)
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: GovernorSubmissionCard(
                                    submission: mySubmissions[index],
                                    onViewReceipt: () => _showReceiptPreview(context, mySubmissions[index]),
                                  ),
                                );
                              },
                              childCount: mySubmissions.length,
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: AppSpacing.lg,
                              mainAxisSpacing: AppSpacing.lg,
                              mainAxisExtent: 300,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return GovernorSubmissionCard(
                                  submission: mySubmissions[index],
                                  onViewReceipt: () => _showReceiptPreview(context, mySubmissions[index]),
                                );
                              },
                              childCount: mySubmissions.length,
                            ),
                          ),
                        ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: FlickrLoader()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
          loading: () => const Center(child: FlickrLoader()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildFiltersRow(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterDropdown(
            label: 'Category',
            value: _categoryFilter,
            items: ['All', 'Mandatory', 'Non-Mandatory'],
            onChanged: (val) => setState(() => _categoryFilter = val!),
          ),
          const SizedBox(width: AppSpacing.md),
          _buildFilterDropdown(
            label: 'Status',
            value: _statusFilter,
            items: ['All', 'To Pay', 'Pending', 'Paid'],
            onChanged: (val) => setState(() => _statusFilter = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
          DropdownButton<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
              );
            }).toList(),
            onChanged: onChanged,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            style: AppTextStyles.labelMedium,
            padding: EdgeInsets.zero,
            isDense: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalPayable, String studentId) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL PAYABLE',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '₱ ${totalPayable.toStringAsFixed(2)}',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STUDENT ID',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      studentId.toUpperCase(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  void _showReceiptPreview(BuildContext context, StudentPaymentModel submission) {
     showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.xl),
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
                child: submission.proofPhotoUrl != null 
                  ? Image.network(
                      submission.proofPhotoUrl!,
                      fit: BoxFit.contain,
                    )
                  : const Icon(Icons.broken_image, size: 100, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentFeeCard extends StatelessWidget {
  final FeeModel fee;
  final StudentPaymentModel? submission;

  const _StudentFeeCard({required this.fee, this.submission});

  @override
  Widget build(BuildContext context) {
    final status = submission?.status ?? 'To Pay';
    final isPaid = status == 'Paid';
    final isPending = status == 'Pending';
    final isRejected = status == 'Rejected';

    Color statusColor = AppColors.primary;
    if (isPaid) statusColor = Colors.green;
    if (isPending) statusColor = Colors.amber;
    if (isRejected) statusColor = Colors.red;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.md,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: statusColor),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fee.name,
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Due Date: ${DateFormat.yMMMd().format(fee.dueDate)}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₱${fee.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!isPaid && !isPending) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentProofOfPaymentPage(fee: fee),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_card_rounded, size: 18),
                  label: Text(isRejected ? 'Resubmit Proof' : 'Submit Proof of Payment'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isRejected ? Colors.red : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Awaiting verification from organization officer.',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.amber[800], fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
