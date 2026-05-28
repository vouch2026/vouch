import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class GovernorCreateFeePage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialData;

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
  bool _isMandatory = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData?['title']);
    _amountController = TextEditingController(text: widget.initialData?['amount']?.toString());
    _descriptionController = TextEditingController(text: widget.initialData?['description']);
    _dueDateController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
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
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                prefixIcon: Icon(Icons.payments_outlined),
                              ),
                              validator: (v) => v?.isEmpty == true ? 'Amount is required' : null,
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
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, true);
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Text(isEdit ? 'Update Fee' : 'Create Fee'),
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
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }
}
