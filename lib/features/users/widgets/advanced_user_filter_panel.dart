import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdvancedUserFilterPanel extends StatefulWidget {
  final List<FilterOption> filters;
  final Function(String query) onSearchChanged;
  final Function(Map<String, dynamic> activeFilters) onFiltersChanged;

  const AdvancedUserFilterPanel({
    super.key,
    required this.filters,
    required this.onSearchChanged,
    required this.onFiltersChanged,
  });

  @override
  State<AdvancedUserFilterPanel> createState() => _AdvancedUserFilterPanelState();
}

class _AdvancedUserFilterPanelState extends State<AdvancedUserFilterPanel> {
  final Map<String, dynamic> _activeFilters = {};
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, or email...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                ),
                onChanged: widget.onSearchChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            FilledButton.tonalIcon(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              icon: Icon(_isExpanded ? Icons.filter_list_off_rounded : Icons.filter_list_rounded),
              label: Text(_isExpanded ? 'Hide Filters' : 'Filters'),
            ),
          ],
        ),
        if (_isExpanded) ...[
          const SizedBox(height: AppSpacing.md),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: widget.filters.map((filter) {
                  return SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(filter.label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<dynamic>(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          isExpanded: true,
                          value: _activeFilters[filter.key],
                          items: [
                            DropdownMenuItem(value: null, child: Text('All ${filter.label}')),
                            ...filter.options.map((opt) => DropdownMenuItem(value: opt.value, child: Text(opt.label))),
                          ],
                          onChanged: (val) {
                            setState(() => _activeFilters[filter.key] = val);
                            widget.onFiltersChanged(_activeFilters);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class FilterOption {
  final String label;
  final String key;
  final List<FilterValue> options;

  const FilterOption({required this.label, required this.key, required this.options});
}

class FilterValue {
  final String label;
  final dynamic value;

  const FilterValue({required this.label, required this.value});
}
