import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CreateElectionModal extends StatefulWidget {
  const CreateElectionModal({super.key});

  @override
  State<CreateElectionModal> createState() => _CreateElectionModalState();
}

class _CreateElectionModalState extends State<CreateElectionModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'Organization';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Create New Election', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildLabel('Election Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'e.g. SSC General Election 2026'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Election Type'),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            items: ['Organization', 'SSC', 'Department', 'COMSELEC']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedType = val!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Organization'),
                          DropdownButtonFormField<String>(
                            items: const [
                              DropdownMenuItem(value: 'ssc', child: Text('SSC')),
                              DropdownMenuItem(value: 'fcet', child: Text('FCET')),
                            ],
                            onChanged: (v) {},
                            decoration: const InputDecoration(hintText: 'Select Org'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildLabel('Voting Period'),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        label: const Text('Start Date'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        label: const Text('End Date'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Initialize Election'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
