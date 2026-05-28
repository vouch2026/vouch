import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class GovernorAddReceiverPage extends ConsumerStatefulWidget {
  const GovernorAddReceiverPage({super.key});

  @override
  ConsumerState<GovernorAddReceiverPage> createState() => _GovernorAddReceiverPageState();
}

class _GovernorAddReceiverPageState extends ConsumerState<GovernorAddReceiverPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedProvider = 'GCash';
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _positionController = TextEditingController();

  final List<String> _providers = ['GCash', 'Maya', 'ShopeePay', 'Bank Transfer'];

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardLayout(
      title: 'Add Payment Card',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Payment Reference',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Add a new bank card or e-wallet for receiving student payments.',
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
                title: 'ACCOUNT DETAILS',
                children: [
                  _buildLabel('Account Name'),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Juan Dela Cruz',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLabel('Account Number'),
                  TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter mobile or card number',
                      prefixIcon: Icon(Icons.numbers_rounded),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Number is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLabel('Position / Title'),
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Treasurer',
                      prefixIcon: Icon(Icons.work_outline_rounded),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Position is required' : null,
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
                      child: const Text('Save Reference'),
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
}
