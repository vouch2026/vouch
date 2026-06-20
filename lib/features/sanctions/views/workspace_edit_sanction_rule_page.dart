import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/config/supabase_config.dart';
import '../providers/sanction_provider.dart';

class WorkspaceEditSanctionRulePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> rule;
  const WorkspaceEditSanctionRulePage({super.key, required this.rule});

  @override
  ConsumerState<WorkspaceEditSanctionRulePage> createState() => _WorkspaceEditSanctionRulePageState();
}

class _WorkspaceEditSanctionRulePageState extends ConsumerState<WorkspaceEditSanctionRulePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _minScoreController;
  late final TextEditingController _maxScoreController;
  late final TextEditingController _worthController;
  late final TextEditingController _itemController;
  
  late String _ruleType;
  bool _isLoading = false;
  final _client = SupabaseConfig.client;

  @override
  void initState() {
    super.initState();
    final minAbsence = widget.rule['min_absence'] as num;
    final maxAbsence = widget.rule['max_absence'] as num?;
    final worth = widget.rule['required_value'] as num?;
    final itemDesc = widget.rule['item_description'] as String? ?? '';

    // Determine rule type
    if (maxAbsence == null) {
      _ruleType = 'above';
    } else if (minAbsence == maxAbsence) {
      _ruleType = 'single';
    } else {
      _ruleType = 'range';
    }

    _minScoreController = TextEditingController(
      text: minAbsence % 1 == 0 ? minAbsence.toInt().toString() : minAbsence.toString(),
    );
    _maxScoreController = TextEditingController(
      text: maxAbsence == null
          ? ''
          : (maxAbsence % 1 == 0 ? maxAbsence.toInt().toString() : maxAbsence.toString()),
    );
    _worthController = TextEditingController(
      text: worth == null ? '' : worth.toStringAsFixed(2),
    );
    _itemController = TextEditingController(text: itemDesc);
  }

  @override
  void dispose() {
    _minScoreController.dispose();
    _maxScoreController.dispose();
    _worthController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double minScore = double.parse(_minScoreController.text.trim());
      double? maxScore;
      if (_ruleType == 'single') {
        maxScore = minScore;
      } else if (_ruleType == 'range') {
        maxScore = double.parse(_maxScoreController.text.trim());
        if (maxScore < minScore) {
          throw Exception('Max score cannot be less than Min score');
        }
      }

      final double? worth = _worthController.text.trim().isNotEmpty
          ? double.parse(_worthController.text.trim())
          : null;
      final String itemDesc = _itemController.text.trim();

      await _client.from('sanction_rules').update({
        'min_absence': minScore,
        'max_absence': maxScore,
        'required_value': worth,
        'item_description': itemDesc,
      }).eq('id', widget.rule['id']);

      ref.invalidate(sanctionRulesProvider);
      ref.invalidate(workspaceSanctionsProvider);
      ref.invalidate(mySanctionsProvider);
      ref.invalidate(workspaceMandatoryEventsCountProvider);

      if (mounted) {
        context.pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sanction rule updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildMaxScoreBadge(int maxScore) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.assignment_turned_in_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Max Sanction Score: $maxScore',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;
    final padding = isMobile ? AppSpacing.lg : AppSpacing.xl;

    final maxSanctionScoreAsync = ref.watch(workspaceMandatoryEventsCountProvider);
    final maxSanctionScore = maxSanctionScoreAsync.value ?? 0;

    return DashboardLayout(
      title: 'Edit Sanction Rule',
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
                          'Edit Rule',
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
                    'Edit Sanction Rule',
                    style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Update the requirements or range of this sanction rule.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: _formKey,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rule Details',
                                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    _buildMaxScoreBadge(maxSanctionScore),
                                  ],
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
                                  Text(
                                    'Sanction Score',
                                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  TextFormField(
                                    controller: _minScoreController,
                                    decoration: InputDecoration(
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
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Min Score',
                                              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: AppSpacing.xs),
                                            TextFormField(
                                              controller: _minScoreController,
                                              decoration: InputDecoration(
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
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Max Score',
                                              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: AppSpacing.xs),
                                            TextFormField(
                                              controller: _maxScoreController,
                                              decoration: InputDecoration(
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (_ruleType == 'above') ...[
                                  Text(
                                    'Threshold Score (And Above)',
                                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  TextFormField(
                                    controller: _minScoreController,
                                    decoration: InputDecoration(
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
                                Text(
                                  'Monetary Worth (PHP) - Optional',
                                  style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                TextFormField(
                                  controller: _worthController,
                                  decoration: InputDecoration(
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
                                Text(
                                  'Item/Donation Description',
                                  style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                TextFormField(
                                  controller: _itemController,
                                  decoration: InputDecoration(
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

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    FilledButton(
                                      onPressed: _submit,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      child: const Text('Update Rule', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
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
