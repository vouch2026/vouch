import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../../core/config/supabase_config.dart';
import '../providers/sanction_provider.dart';

class WorkspaceCreateSanctionRulePage extends ConsumerStatefulWidget {
  const WorkspaceCreateSanctionRulePage({super.key});

  @override
  ConsumerState<WorkspaceCreateSanctionRulePage> createState() => _WorkspaceCreateSanctionRulePageState();
}

class _WorkspaceCreateSanctionRulePageState extends ConsumerState<WorkspaceCreateSanctionRulePage> {
  final _formKey = GlobalKey<FormState>();
  final _minScoreController = TextEditingController();
  final _maxScoreController = TextEditingController();
  final _worthController = TextEditingController();
  final _itemController = TextEditingController();
  
  String _ruleType = 'single'; // 'single', 'range', 'above'
  bool _isLoading = false;
  final _client = SupabaseConfig.client;

  @override
  void dispose() {
    _minScoreController.dispose();
    _maxScoreController.dispose();
    _worthController.dispose();
    _itemController.dispose();
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

    final workspace = ref.read(workspaceProvider);
    final org = workspace.selectedOrganization;
    final term = ref.read(activeTermProvider).value;
    final user = ref.read(userProfileProvider).value;

    if (org == null || term == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing workspace, term, or user details.')),
      );
      return;
    }

    final double? minVal = double.tryParse(_minScoreController.text);
    if (minVal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid sanction score')),
      );
      return;
    }

    double? maxVal;
    if (_ruleType == 'single') {
      maxVal = minVal;
    } else if (_ruleType == 'range') {
      maxVal = double.tryParse(_maxScoreController.text);
      if (maxVal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid max score')),
        );
        return;
      }
      if (maxVal < minVal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Max score cannot be less than min score')),
        );
        return;
      }
    }

    double? worthVal;
    if (_worthController.text.isNotEmpty) {
      worthVal = double.tryParse(_worthController.text);
      if (worthVal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid numeric worth value')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final String scopeId = org.id;
    String scopeType = 'Institutional';
    if (org.type == 'faculty-based') {
      scopeType = 'Faculty';
    } else if (org.type == 'program-based') {
      scopeType = 'Program';
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _client.from('sanction_rules').insert({
        'scope_id': scopeId,
        'scope_type': scopeType,
        'academic_term_id': term.id,
        'min_absence': minVal,
        'max_absence': maxVal,
        'required_value': worthVal,
        'item_description': _itemController.text,
        'sanction_type': 'Donation',
        'created_by_user_id': user.id,
      });

      ref.invalidate(sanctionRulesProvider);
      ref.invalidate(workspaceSanctionsProvider);
      ref.invalidate(mySanctionsProvider);
      ref.invalidate(workspaceMandatoryEventsCountProvider);

      if (mounted) {
        navigator.pop(true);
        messenger.showSnackBar(
          const SnackBar(content: Text('Sanction rule created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final padding = isMobile ? AppSpacing.lg : AppSpacing.xl;

    return DashboardLayout(
      title: 'Create Sanction Rule',
      onBack: () => context.pop(),
      child: _isLoading
          ? const Center(child: FlickrLoader())
          : SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumbs Header
                  Row(
                    children: [
                      Icon(Icons.gavel_rounded, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context.pop(),
                        child: Text(
                          'Sanctions',
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
                          'Create Rule',
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
                    'Create Sanction Rule',
                    style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Define a rule requiring item donation based on student absences.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Form(
                    key: _formKey,
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rule Details',
                                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Rule Type Dropdown
                                const Text(
                                  'Rule Application Type',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textGrey),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _ruleType,
                                  decoration: InputDecoration(
                                    prefixIcon: _buildPrefixIcon(Icons.rule_rounded),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 12),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'single', child: Text('Single Score (e.g. exactly 1)')),
                                    DropdownMenuItem(value: 'range', child: Text('Score Range (e.g. 1 - 2)')),
                                    DropdownMenuItem(value: 'above', child: Text('Score and Above (e.g. 3+)')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _ruleType = val;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Score input fields
                                if (_ruleType == 'single') ...[
                                  TextFormField(
                                    controller: _minScoreController,
                                    decoration: InputDecoration(
                                      labelText: 'Sanction Score',
                                      hintText: 'e.g. 1 or 1.5',
                                      prefixIcon: _buildPrefixIcon(Icons.gavel_rounded),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Please enter a sanction score';
                                      if (double.tryParse(val) == null) return 'Please enter a valid numeric value';
                                      return null;
                                    },
                                  ),
                                ] else if (_ruleType == 'range') ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _minScoreController,
                                          decoration: InputDecoration(
                                            labelText: 'Min Score',
                                            hintText: 'e.g. 1',
                                            prefixIcon: _buildPrefixIcon(Icons.chevron_right_rounded),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          validator: (val) {
                                            if (val == null || val.isEmpty) return 'Required';
                                            if (double.tryParse(val) == null) return 'Invalid';
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _maxScoreController,
                                          decoration: InputDecoration(
                                            labelText: 'Max Score',
                                            hintText: 'e.g. 2',
                                            prefixIcon: _buildPrefixIcon(Icons.chevron_left_rounded),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          validator: (val) {
                                            if (val == null || val.isEmpty) return 'Required';
                                            if (double.tryParse(val) == null) return 'Invalid';
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (_ruleType == 'above') ...[
                                  TextFormField(
                                    controller: _minScoreController,
                                    decoration: InputDecoration(
                                      labelText: 'Threshold Score (And Above)',
                                      hintText: 'e.g. 3',
                                      prefixIcon: _buildPrefixIcon(Icons.keyboard_double_arrow_up_rounded),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Please enter a threshold score';
                                      if (double.tryParse(val) == null) return 'Please enter a valid numeric value';
                                      return null;
                                    },
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.lg),

                                // Worth (PHP) - Optional
                                TextFormField(
                                  controller: _worthController,
                                  decoration: InputDecoration(
                                    labelText: 'Monetary Worth (PHP) - Optional',
                                    hintText: 'e.g. 100.00',
                                    prefixIcon: _buildPrefixIcon(Icons.payments_rounded),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (val) {
                                    if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
                                      return 'Please enter a valid numeric value';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Item/Donation Description
                                TextFormField(
                                  controller: _itemController,
                                  decoration: InputDecoration(
                                    labelText: 'Item/Donation Description',
                                    hintText: 'e.g. 2 pieces A4 Bond Paper',
                                    prefixIcon: _buildPrefixIcon(Icons.inventory_2_rounded),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) return 'Please enter an item description';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.xl),

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: _submit,
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Create Rule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
