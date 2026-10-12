import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdvancedUserFilterPanel extends StatefulWidget {
  final List<FilterOption> filters;
  final Function(String query) onSearchChanged;
  final Function(Map<String, dynamic> activeFilters) onFiltersChanged;
  final String searchHint;
  final int resetToken;
  final VoidCallback? onClearAll;

  const AdvancedUserFilterPanel({
    super.key,
    required this.filters,
    required this.onSearchChanged,
    required this.onFiltersChanged,
    this.searchHint = 'Search by name, ID, or email...',
    this.resetToken = 0,
    this.onClearAll,
  });

  @override
  State<AdvancedUserFilterPanel> createState() =>
      _AdvancedUserFilterPanelState();
}

class _AdvancedUserFilterPanelState extends State<AdvancedUserFilterPanel> {
  final Map<String, dynamic> _activeFilters = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AdvancedUserFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // External reset (e.g. table "Clear search & filters" button).
    // Clear silently — the owner already reset its own query/filter state.
    if (widget.resetToken != oldWidget.resetToken) {
      setState(() {
        _searchController.clear();
        _activeFilters.clear();
      });
    } else {
      // Prune stale selections when dynamic options change (org switch).
      var pruned = false;
      final validKeys = widget.filters.map((f) => f.key).toSet();
      _activeFilters.removeWhere((key, value) {
        if (!validKeys.contains(key)) {
          pruned = true;
          return true;
        }
        if (value == null) {
          pruned = true;
          return true;
        }
        FilterOption? option;
        for (final o in widget.filters) {
          if (o.key == key) {
            option = o;
            break;
          }
        }
        if (option == null) {
          pruned = true;
          return true;
        }
        final stillValid = option.options
            .any((v) => v.value.toString() == value.toString());
        if (!stillValid) pruned = true;
        return !stillValid;
      });
      if (pruned) {
        // Defer to avoid calling callbacks during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {});
          widget.onFiltersChanged(Map<String, dynamic>.of(_activeFilters));
        });
      }
    }
  }

  int get _activeFilterCount {
    var count = 0;
    _activeFilters.forEach((_, value) {
      if (value == null) return;
      final asStr = value.toString().trim();
      if (asStr.isEmpty || asStr.toLowerCase() == 'null') return;
      count++;
    });
    return count;
  }

  String _chipLabel(String key, dynamic value) {
    for (final option in widget.filters) {
      if (option.key != key) continue;
      for (final v in option.options) {
        if (v.value.toString() == value.toString()) return v.label;
      }
    }
    return value.toString();
  }

  String _filterGroupLabel(String key) {
    for (final option in widget.filters) {
      if (option.key == key) return option.label;
    }
    return key;
  }

  void _clearAll() {
    setState(() {
      _searchController.clear();
      _activeFilters.clear();
    });
    widget.onSearchChanged('');
    widget.onFiltersChanged(<String, dynamic>{});
    widget.onClearAll?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasQuery = _searchController.text.trim().isNotEmpty;
    final hasActiveChips = hasQuery || _activeFilterCount > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: hasQuery
                          ? IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                setState(() => _searchController.clear());
                                widget.onSearchChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme.colorScheme.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                    ),
                    onChanged: widget.onSearchChanged,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                if (isMobile)
                  Badge(
                    isLabelVisible: _activeFilterCount > 0,
                    label: Text('$_activeFilterCount'),
                    child: IconButton.filledTonal(
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                      icon: Icon(_isExpanded
                          ? Icons.filter_list_off_rounded
                          : Icons.filter_list_rounded),
                      tooltip: _isExpanded ? 'Hide Filters' : 'Filters',
                    ),
                  )
                else
                  Badge(
                    isLabelVisible: _activeFilterCount > 0,
                    label: Text('$_activeFilterCount'),
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                      icon: Icon(_isExpanded
                          ? Icons.filter_list_off_rounded
                          : Icons.filter_list_rounded),
                      label: Text(_isExpanded ? 'Hide Filters' : 'Filters'),
                    ),
                  ),
              ],
            ),
            if (hasActiveChips) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (hasQuery)
                    InputChip(
                      label: Text(
                        '"${_searchController.text.trim()}"',
                        style: AppTextStyles.labelSmall
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      avatar: const Icon(Icons.search_rounded, size: 14),
                      onDeleted: () {
                        setState(() => _searchController.clear());
                        widget.onSearchChanged('');
                      },
                    ),
                  for (final entry in _activeFilters.entries)
                    if (entry.value != null &&
                        entry.value.toString().trim().isNotEmpty &&
                        entry.value.toString().toLowerCase() != 'null')
                      InputChip(
                        label: Text(
                          '${_filterGroupLabel(entry.key)}: ${_chipLabel(entry.key, entry.value)}',
                          style: AppTextStyles.labelSmall
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        onDeleted: () {
                          setState(() => _activeFilters[entry.key] = null);
                          widget.onFiltersChanged(
                              Map<String, dynamic>.of(_activeFilters));
                        },
                      ),
                  TextButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.clear_all_rounded, size: 16),
                    label: const Text('Clear all'),
                  ),
                ],
              ),
            ],
            if (_isExpanded) ...[
              const SizedBox(height: AppSpacing.md),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: widget.filters.map((filter) {
                          return SizedBox(
                            width: isMobile
                                ? (constraints.maxWidth - AppSpacing.xl) / 2 -
                                    10
                                : 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(filter.label,
                                    style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<dynamic>(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  isExpanded: true,
                                  value: _activeFilters[filter.key],
                                  items: [
                                    DropdownMenuItem(
                                        value: null,
                                        child:
                                            Text('All ${filter.label}')),
                                    ...filter.options.map((opt) =>
                                        DropdownMenuItem(
                                            value: opt.value,
                                            child: Text(opt.label))),
                                  ],
                                  onChanged: (val) {
                                    setState(() =>
                                        _activeFilters[filter.key] = val);
                                    widget.onFiltersChanged(
                                        Map<String, dynamic>.of(
                                            _activeFilters));
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      if (_activeFilterCount > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() => _activeFilters.clear());
                              widget.onFiltersChanged(
                                  Map<String, dynamic>.of(_activeFilters));
                            },
                            icon: const Icon(Icons.restart_alt_rounded,
                                size: 16),
                            label: const Text('Reset filters'),
                          ),
                        ),
                      ],
                      if (widget.filters.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No additional filters available for this organization.',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.grey[600]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class FilterOption {
  final String label;
  final String key;
  final List<FilterValue> options;

  const FilterOption(
      {required this.label, required this.key, required this.options});
}

class FilterValue {
  final String label;
  final dynamic value;

  const FilterValue({required this.label, required this.value});
}
