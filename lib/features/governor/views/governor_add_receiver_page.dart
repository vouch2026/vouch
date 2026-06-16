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

  Future<void> _deleteReceiver() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Reference'),
        content: const Text('Are you sure you want to delete this payment reference? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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

    return DashboardLayout(
      title: isEdit ? 'Edit Payment Card' : 'Add Payment Card',
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
              
              _buildFormSection(
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
                      );
                    }).toList(),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              _buildFormSection(
                context,
                title: _selectedProvider == 'Cash' ? 'COLLECTOR DETAILS' : 'ACCOUNT DETAILS',
                children: [
                  _buildLabel(_selectedProvider == 'Cash' ? 'Collector / Officer Name' : 'Account Name'),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: _selectedProvider == 'Cash' ? "e.g., Treasurer's Name" : 'e.g., Juan Dela Cruz',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
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
                      prefixIcon: Icon(_selectedProvider == 'Cash' ? Icons.info_outline_rounded : Icons.numbers_rounded),
                    ),
                    validator: (v) => v?.isEmpty == true 
                        ? (_selectedProvider == 'Cash' ? 'Payment location/instructions are required' : 'Number is required') 
                        : null,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: FlickrLoader())
                        : Text(isEdit ? 'Save Changes' : 'Save Reference'),
                    ),
                  ),
                ],
              ),
              if (isEdit) ...[
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _deleteReceiver,
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    label: const Text(
                      'Delete Reference',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
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
