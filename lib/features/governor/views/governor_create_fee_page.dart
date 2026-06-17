import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final padding = isMobile ? AppSpacing.lg : AppSpacing.xl;

    return DashboardLayout(
      title: isEdit ? 'Edit Fee' : 'Create New Fee',
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
                      isEdit ? 'Edit Fee' : 'Create Fee',
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
                isEdit ? 'Update Fee Details' : 'Set Up New Collection',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Define the amount, due date, and instructions for this fee.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              if (!isMobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildBasicInfoSection(context),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      flex: 5,
                      child: _buildInstructionsSection(context),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildBasicInfoSection(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildInstructionsSection(context),
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
                      : Text(isEdit ? 'Update Fee' : 'Create Fee'),
                  );

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
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 150,
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

  Widget _buildBasicInfoSection(BuildContext context) {
    return _buildFormSection(
      context,
      title: 'BASIC INFORMATION',
      children: [
        _buildLabel('Fee Title'),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., Membership Fee, T-Shirt, etc.',
            prefixIcon: _buildPrefixIcon(Icons.title_rounded),
          ),
          validator: (v) => v?.isEmpty == true ? 'Title is required' : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Amount and Due Date side-by-side or stacked responsive
        LayoutBuilder(
          builder: (context, fieldConstraints) {
            final isFieldsStacked = fieldConstraints.maxWidth < 450;
            
            final amountField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Amount (₱)'),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixIcon: _buildPrefixIcon(Icons.payments_outlined),
                  ),
                  validator: (v) {
                    if (v?.isEmpty == true) return 'Amount is required';
                    if (double.tryParse(v!) == null) return 'Invalid amount';
                    return null;
                  },
                ),
              ],
            );
            
            final dueDateField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Due Date'),
                TextFormField(
                  controller: _dueDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select Date',
                    prefixIcon: _buildPrefixIcon(Icons.calendar_today_rounded),
                    suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                  ),
                  onTap: () => _selectDate(context),
                  validator: (v) => v?.isEmpty == true ? 'Due date is required' : null,
                ),
              ],
            );

            if (isFieldsStacked) {
              return Column(
                children: [
                  amountField,
                  const SizedBox(height: AppSpacing.lg),
                  dueDateField,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: amountField,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: dueDateField,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInstructionsSection(BuildContext context) {
    final theme = Theme.of(context);
    return _buildFormSection(
      context,
      title: 'INSTRUCTIONS & SETTINGS',
      children: [
        _buildLabel('Instructions / Description'),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Add payment instructions or notes for students...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: SwitchListTile(
              title: const Text('Mandatory Fee', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Require all organization members to pay this fee'),
              value: _isMandatory,
              onChanged: (v) => setState(() => _isMandatory = v),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
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

  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final firstSelectableDate = _selectedDueDate != null && _selectedDueDate!.isBefore(today)
        ? _selectedDueDate!
        : today;
    
    final lastSelectableDate = _selectedDueDate != null && _selectedDueDate!.isAfter(today.add(const Duration(days: 365)))
        ? _selectedDueDate!
        : today.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? today.add(const Duration(days: 7)),
      firstDate: firstSelectableDate,
      lastDate: lastSelectableDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }
}
