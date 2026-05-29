import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/user_management_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../../finance/models/fee_model.dart';
import '../../finance/models/student_payment_model.dart';
import '../../finance/models/payment_receiver_model.dart';
import '../../finance/providers/finance_provider.dart';
import '../widgets/governor_receiver_card.dart';
import '../widgets/governor_submission_card.dart';
import 'governor_add_receiver_page.dart';
import 'governor_create_fee_page.dart';
import 'governor_created_fees_page.dart';

class GovernorFinancePage extends ConsumerStatefulWidget {
  const GovernorFinancePage({super.key});

  @override
  ConsumerState<GovernorFinancePage> createState() => _GovernorFinancePageState();
}

class _GovernorFinancePageState extends ConsumerState<GovernorFinancePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

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
    final theme = Theme.of(context);
    final receiversAsync = ref.watch(paymentReceiversProvider);
    final submissionsAsync = ref.watch(workspaceStudentPaymentsProvider);

    return DashboardLayout(
      title: 'Organization Finance',
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
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

                // Receiver References Section
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
                  data: (receivers) => SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: receivers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
                      itemBuilder: (context, index) => GovernorReceiverCard(
                        receiver: receivers[index],
                        onEdit: () {},
                      ),
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
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
                                  _buildFeeTypeFilter(),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildSearchField(),
                                  const SizedBox(height: AppSpacing.md),
                                  SizedBox(width: double.infinity, child: _buildFeeTypeFilter()),
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
          loading: () => const Center(child: CircularProgressIndicator()),
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

  Widget _buildFeeTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'All Fees',
            style: AppTextStyles.labelLarge.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildSubmissionList(List<StudentPaymentModel> submissions, String status) {
    final query = _searchController.text.toLowerCase();
    final filtered = submissions.where((s) {
      final matchesStatus = s.status == status;
      final matchesQuery = (s.studentName?.toLowerCase().contains(query) ?? false) ||
                          (s.feeName?.toLowerCase().contains(query) ?? false);
      return matchesStatus && matchesQuery;
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
        if (constraints.maxWidth > 1200) {
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
            mainAxisExtent: (status == 'Pending' || status == 'Rejected') ? 360 : 280,
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
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
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
                    submission.studentName ?? 'Unknown Student',
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
