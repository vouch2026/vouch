import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../finance/models/fee_model.dart';
import '../../finance/providers/finance_provider.dart';

class GovernorCreateFeePage extends ConsumerStatefulWidget {
  final FeeModel? initialData;

  const GovernorCreateFeePage({super.key, this.initialData});

  @override
  ConsumerState<GovernorCreateFeePage> createState() => _GovernorCreateFeePageState();
}

class _GovernorCreateFeePageState extends ConsumerState<GovernorCreateFeePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dueDateController;
  
  DateTime? _selectedDueDate;
  bool _isMandatory = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData?.name);
    _amountController = TextEditingController(text: widget.initialData?.amount.toString());
    _descriptionController = TextEditingController(text: widget.initialData?.description);
    _dueDateController = TextEditingController();
    
    if (widget.initialData != null) {
      _selectedDueDate = widget.initialData!.dueDate;
      _dueDateController.text = DateFormat.yMMMd().format(_selectedDueDate!);
      _isMandatory = widget.initialData!.isMandatory;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final workspace = ref.read(workspaceProvider);
      final org = workspace.selectedOrganization!;
      final user = ref.read(userProfileProvider).value!;
      final activeTerm = await ref.read(activeTermProvider.future);

      if (activeTerm == null) {
        throw Exception('No active academic term found. Please contact an administrator.');
      }

      final scopeType = org.type == 'campus-based' 
          ? 'Institutional' 
          : (org.type == 'faculty-based' ? 'Faculty' : 'Program');
      
      final scopeId = org.type == 'campus-based' 
          ? org.campusId 
          : (org.type == 'faculty-based' ? org.facultyId : org.programId);

      final fee = FeeModel(
        id: widget.initialData?.id,
        name: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        scopeType: scopeType,
        scopeId: scopeId!,
        isMandatory: _isMandatory,
        dueDate: _selectedDueDate!,
        academicTermId: activeTerm.id,
        createdByUserId: user.id,
      );

      if (widget.initialData != null) {
        await ref.read(financeRepositoryProvider).updateFee(fee);
      } else {
        await ref.read(financeRepositoryProvider).createFee(fee);
      }

      if (mounted) {
        ref.invalidate(workspaceFeesProvider);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fee ${widget.initialData != null ? 'updated' : 'created'} successfully')),
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
      title: isEdit ? 'Edit Fee' : 'Create New Fee',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Update Fee Details' : 'Set Up New Collection',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Define the amount, due date, and instructions for this fee.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildFormSection(
                context,
                title: 'BASIC INFORMATION',
                children: [
                  _buildLabel('Fee Title'),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., membership Fee, T-Shirt, etc.',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Amount (₱)'),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                prefixIcon: Icon(Icons.payments_outlined),
                              ),
                              validator: (v) {
                                if (v?.isEmpty == true) return 'Amount is required';
                                if (double.tryParse(v!) == null) return 'Invalid amount';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Due Date'),
                            TextFormField(
                              controller: _dueDateController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                hintText: 'Select Date',
                                prefixIcon: Icon(Icons.calendar_today_rounded),
                                suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                              ),
                              onTap: () => _selectDate(context),
                              validator: (v) => v?.isEmpty == true ? 'Due date is required' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              _buildFormSection(
                context,
                title: 'INSTRUCTIONS & SETTINGS',
                children: [
                  _buildLabel('Instructions / Description'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Add payment instructions or notes for students...',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SwitchListTile(
                    title: const Text('Mandatory Fee', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Require all organization members to pay this fee'),
                    value: _isMandatory,
                    onChanged: (v) => setState(() => _isMandatory = v),
                    contentPadding: EdgeInsets.zero,
                    activeColor: theme.colorScheme.primary,
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
                        : Text(isEdit ? 'Update Fee' : 'Create Fee'),
                    ),
                  ),
                ],
              ),
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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }
}
