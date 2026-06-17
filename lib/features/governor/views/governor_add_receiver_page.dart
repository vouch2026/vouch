import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../finance/models/payment_receiver_model.dart';
import '../../finance/providers/finance_provider.dart';
import '../../organizations/providers/workspace_provider.dart';

class GovernorAddReceiverPage extends ConsumerStatefulWidget {
  final PaymentReceiverModel? initialData;

  const GovernorAddReceiverPage({super.key, this.initialData});

  @override
  ConsumerState<GovernorAddReceiverPage> createState() => _GovernorAddReceiverPageState();
}

class _GovernorAddReceiverPageState extends ConsumerState<GovernorAddReceiverPage> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedProvider;
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  
  bool _isLoading = false;

  final List<String> _providers = ['GCash', 'Maya', 'ShopeePay', 'Bank Transfer', 'Cash'];

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.initialData?.bankType ?? 'GCash';
    _nameController = TextEditingController(text: widget.initialData?.accountName);
    _numberController = TextEditingController(text: widget.initialData?.accountNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Widget _buildPrefixIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 8),
      child: Center(
        widthFactor: 1,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
      ),
    );
  }

  Future<void> _deleteReceiver() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Reference',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this payment reference? Students will no longer see this as a payment option. This action cannot be undone.',
          style: TextStyle(color: Colors.black87, height: 1.4, fontSize: 14),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(financeRepositoryProvider).deletePaymentReceiver(widget.initialData!.id!);
        if (mounted) {
          ref.invalidate(paymentReceiversProvider);
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment reference deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProfileProvider).value!;
      final workspace = ref.read(workspaceProvider);
      final org = workspace.selectedOrganization!;

      final scopeType = org.type == 'campus-based' 
          ? 'Institutional' 
          : (org.type == 'faculty-based' ? 'Faculty' : 'Program');
      
      final scopeId = org.type == 'campus-based' 
          ? org.campusId 
          : (org.type == 'faculty-based' ? org.facultyId : org.programId);
      
      if (widget.initialData != null) {
        final receiver = widget.initialData!.copyWith(
          bankType: _selectedProvider,
          accountName: _nameController.text,
          accountNumber: _numberController.text,
        );
        await ref.read(financeRepositoryProvider).updatePaymentReceiver(receiver);
      } else {
        final receiver = PaymentReceiverModel(
          bankType: _selectedProvider,
          accountName: _nameController.text,
          accountNumber: _numberController.text,
          createdByUserId: user.id,
          scopeType: scopeType,
          scopeId: scopeId,
        );
        await ref.read(financeRepositoryProvider).createPaymentReceiver(receiver);
      }
      
      if (mounted) {
        ref.invalidate(paymentReceiversProvider);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment reference ${widget.initialData != null ? 'updated' : 'added'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.initialData != null;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final padding = isMobile ? AppSpacing.lg : AppSpacing.xl;

    return DashboardLayout(
      title: isEdit ? 'Edit Payment Card' : 'Add Payment Card',
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
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
                      isEdit ? 'Edit Payment Card' : 'Add Payment Card',
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
              Text(
                isEdit ? 'Update Payment Reference' : 'New Payment Reference',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                isEdit 
                    ? 'Modify the details for receiving student payments.'
                    : 'Add a new bank card or e-wallet for receiving student payments.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              if (!isMobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildProviderSection(context),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      flex: 5,
                      child: _buildDetailsSection(context),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildProviderSection(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildDetailsSection(context),
                  ],
                ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // Action Buttons Row (aligned responsive)
              LayoutBuilder(
                builder: (context, buttonConstraints) {
                  final isButtonsMobile = buttonConstraints.maxWidth < 600;
                  
                  final cancelButton = OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancel'),
                  );
                  
                  final submitButton = FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: FlickrLoader(),
                        )
                      : Text(isEdit ? 'Save Changes' : 'Save Reference'),
                  );

                  final deleteButton = isEdit
                      ? OutlinedButton.icon(
                          onPressed: _isLoading ? null : _deleteReceiver,
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: const Text(
                            'Delete Reference',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        )
                      : null;

                  if (isButtonsMobile) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: submitButton,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: cancelButton,
                        ),
                        if (deleteButton != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: deleteButton,
                          ),
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      if (deleteButton != null) ...[
                        deleteButton,
                        const Spacer(),
                      ] else ...[
                        const Spacer(),
                      ],
                      SizedBox(
                        width: 130,
                        child: cancelButton,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      SizedBox(
                        width: 180,
                        child: submitButton,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderSection(BuildContext context) {
    final theme = Theme.of(context);
    return _buildFormSection(
      context,
      title: 'PROVIDER SELECTION',
      children: [
        _buildLabel('Select Provider'),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: _providers.map((p) {
            final isSelected = _selectedProvider == p;
            return ChoiceChip(
              label: Text(p),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedProvider = p),
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return _buildFormSection(
      context,
      title: _selectedProvider == 'Cash' ? 'COLLECTOR DETAILS' : 'ACCOUNT DETAILS',
      children: [
        _buildLabel(_selectedProvider == 'Cash' ? 'Collector / Officer Name' : 'Account Name'),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: _selectedProvider == 'Cash' ? "e.g., Treasurer's Name" : 'e.g., Juan Dela Cruz',
            prefixIcon: _buildPrefixIcon(Icons.person_outline_rounded),
          ),
          validator: (v) => v?.isEmpty == true 
              ? (_selectedProvider == 'Cash' ? 'Collector name is required' : 'Name is required') 
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildLabel(_selectedProvider == 'Cash' ? 'Payment Location / Instructions' : 'Account Number'),
        TextFormField(
          controller: _numberController,
          keyboardType: _selectedProvider == 'Cash' ? TextInputType.text : TextInputType.number,
          decoration: InputDecoration(
            hintText: _selectedProvider == 'Cash' ? "e.g., Office Room 101 or 'Pay in-person'" : 'Enter mobile or card number',
            prefixIcon: _buildPrefixIcon(_selectedProvider == 'Cash' ? Icons.info_outline_rounded : Icons.numbers_rounded),
          ),
          validator: (v) => v?.isEmpty == true 
              ? (_selectedProvider == 'Cash' ? 'Payment location/instructions are required' : 'Number is required') 
              : null,
        ),
      ],
    );
  }

  Widget _buildFormSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
