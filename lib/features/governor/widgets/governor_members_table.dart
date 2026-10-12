import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../organizations/providers/organization_provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import 'member_directory_helpers.dart';

import 'package:google_fonts/google_fonts.dart';

class GovernorMembersTable extends ConsumerStatefulWidget {
  final String searchQuery;
  final Map<String, dynamic> activeFilters;
  final VoidCallback? onClearFilters;

  const GovernorMembersTable({
    super.key,
    this.searchQuery = '',
    this.activeFilters = const {},
    this.onClearFilters,
  });

  @override
  ConsumerState<GovernorMembersTable> createState() =>
      _GovernorMembersTableState();
}

class _GovernorMembersTableState extends ConsumerState<GovernorMembersTable> {
  int _currentPage = 0;
  int _rowsPerPage = 10;
  String _sortValue = 'nameAsc';

  @override
  void didUpdateWidget(covariant GovernorMembersTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery ||
        !_mapsEqual(widget.activeFilters, oldWidget.activeFilters)) {
      _currentPage = 0;
    }
  }

  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key]?.toString() != b[key]?.toString()) return false;
    }
    return true;
  }

  bool get _isFiltered {
    if (widget.searchQuery.trim().isNotEmpty) return true;
    for (final value in widget.activeFilters.values) {
      if (value == null) continue;
      final asStr = value.toString().trim();
      if (asStr.isEmpty || asStr.toLowerCase() == 'null') continue;
      return true;
    }
    return false;
  }

  String _programYearText(UserModel member) {
    final program = member.programName ?? member.programCode;
    final year = member.yearLevel;
    if ((program == null || program.trim().isEmpty) && year == null) {
      return 'N/A';
    }
    if (program == null || program.trim().isEmpty) {
      return MemberDirectoryHelpers.yearLabel(year!);
    }
    if (year == null) return program;
    return '$program • ${MemberDirectoryHelpers.yearLabel(year)}';
  }

  String _initialOf(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final activeRoleName = workspace.activeRole?.roleName.toLowerCase() ?? '';
    final userProfile = ref.watch(userProfileProvider).value;
    final isSuperAdmin = userProfile?.role == 'super_admin';
    final canManageMembers = isSuperAdmin ||
                            activeRoleName.contains('governor') ||
                            activeRoleName.contains('president') ||
                            activeRoleName.contains('vice governor') ||
                            activeRoleName.contains('vice president');

    if (selectedOrg == null) {
      return const Center(child: Text('Please select an organization.'));
    }

    final membersAsync = ref.watch(organizationMembersProvider(selectedOrg.id));

    return membersAsync.when(
      data: (members) {
        final baseMembers = members.where((m) {
          final role = m.role.toLowerCase();
          return role == 'member' || role == 'student';
        }).toList();

        if (baseMembers.isEmpty) {
          return _buildEmptyState(
            theme,
            isFiltered: false,
            title: 'No members found',
            message: 'This organization doesn\'t have any members yet.',
          );
        }

        final filtered = baseMembers
            .where((m) => MemberDirectoryHelpers.matchesDirectoryFilters(
                m, widget.searchQuery, widget.activeFilters))
            .toList();
        final sorted = MemberDirectoryHelpers.applyDirectorySort(
            filtered, _sortValue);

        if (sorted.isEmpty) {
          return _buildEmptyState(
            theme,
            isFiltered: true,
            title: 'No results found',
            message: _isFiltered
                ? 'No members match your current search and filters. Try adjusting them.'
                : 'No members match.',
          );
        }

        final totalItems = sorted.length;
        final totalPages = (totalItems / _rowsPerPage).ceil();
        final safePage = _currentPage >= totalPages ? (totalPages > 0 ? totalPages - 1 : 0) : _currentPage;
        if (safePage != _currentPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _currentPage = safePage);
          });
        }

        final startIndex = safePage * _rowsPerPage;
        final endIndex = startIndex + _rowsPerPage > totalItems ? totalItems : startIndex + _rowsPerPage;
        final paginatedMembers = sorted.sublist(startIndex, endIndex);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToolbar(
              context,
              totalFiltered: totalItems,
              totalBase: baseMembers.length,
              filteredForExport: sorted,
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return _buildCardList(
                      paginatedMembers, canManageMembers, theme);
                }
                return _buildDesktopTable(
                    paginatedMembers, canManageMembers, theme);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPaginationFooter(totalItems, safePage, _rowsPerPage),
          ],
        );
      },
      loading: () => _buildLoadingSkeleton(theme),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text('Error loading members: $error'),
              TextButton(
                onPressed: () => ref.refresh(organizationMembersProvider(selectedOrg.id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context, {
    required int totalFiltered,
    required int totalBase,
    required List<UserModel> filteredForExport,
  }) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final resultText = _isFiltered
            ? '$totalFiltered of $totalBase members'
            : '$totalBase member${totalBase == 1 ? '' : 's'}';

        final sortDropdown = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortValue,
              icon: const Icon(Icons.arrow_drop_down, size: 18,
                  color: Colors.black54),
              elevation: 4,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
              items: [
                for (final opt in MemberDirectoryHelpers.sortOptions)
                  DropdownMenuItem<String>(
                    value: opt['value']!,
                    child: Text(
                      opt['label']!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _sortValue = val;
                    _currentPage = 0;
                  });
                }
              },
            ),
          ),
        );

        final exportButton = OutlinedButton.icon(
          onPressed: filteredForExport.isEmpty
              ? null
              : () => MemberDirectoryHelpers.exportDirectoryExcel(
                    context,
                    filteredForExport,
                    'Members_Directory_Report',
                    'Organization Members Report',
                  ),
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: Text(isNarrow ? 'Export' : 'Export Excel'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        );

        if (isNarrow) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people_alt_rounded,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          resultText,
                          style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Text('Sort: ',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54)),
                      Expanded(child: sortDropdown),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(width: double.infinity, child: exportButton),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.people_alt_rounded,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  resultText,
                  style: AppTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                const Text('Sort by: ',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                sortDropdown,
                const SizedBox(width: AppSpacing.md),
                exportButton,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(
    List<UserModel> paginatedMembers,
    bool canManageMembers,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: AppSpacing.lg,
                    headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)),
                    headingTextStyle: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    columns: [
                      const DataColumn(label: Text('Member')),
                      const DataColumn(label: Text('Student ID')),
                      const DataColumn(label: Text('Program & Year')),
                      const DataColumn(label: Text('Joined Date')),
                      const DataColumn(label: Text('Role')),
                      const DataColumn(label: Text('Status')),
                      if (canManageMembers) const DataColumn(label: Text('Actions')),
                    ],
                    rows: paginatedMembers.map((member) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                                  child: member.avatarUrl == null
                                      ? Text(
                                          _initialOf(member.fullName),
                                          style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 12),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(member.fullName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                    Text(member.email, style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(member.schoolId, style: AppTextStyles.bodySmall)),
                          DataCell(Text(
                            _programYearText(member),
                            style: AppTextStyles.bodySmall,
                          )),
                          DataCell(Text(
                            member.joinedAt != null ? DateFormat.yMMMd().format(member.joinedAt!) : 'N/A',
                            style: AppTextStyles.bodySmall,
                          )),
                          DataCell(_RoleBadge(role: member.role)),
                          DataCell(_StatusBadge(status: member.status)),
                          if (canManageMembers)
                            DataCell(
                              _buildMemberActions(context, member),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardList(
    List<UserModel> paginatedMembers,
    bool canManageMembers,
    ThemeData theme,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: paginatedMembers.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final member = paginatedMembers[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: member.avatarUrl != null
                      ? NetworkImage(member.avatarUrl!)
                      : null,
                  child: member.avatarUrl == null
                      ? Text(
                          _initialOf(member.fullName),
                          style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.fullName,
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text(member.email,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text(
                        '${member.schoolId} • ${_programYearText(member)}',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _RoleBadge(role: member.role),
                          _StatusBadge(status: member.status),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canManageMembers)
                  _buildMemberActions(context, member),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 90,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < 5; i++) ...[
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 10,
                          width: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (i < 4) const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              'Loading members...',
              style:
                  AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(int totalItems, int currentPage, int rowsPerPage) {
    final totalPages = (totalItems / rowsPerPage).ceil();
    final startItem = totalItems == 0 ? 0 : (currentPage * rowsPerPage) + 1;
    final endItem = (currentPage * rowsPerPage) + rowsPerPage > totalItems
        ? totalItems
        : (currentPage * rowsPerPage) + rowsPerPage;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        final dropdownWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isNarrow ? 'Rows:' : 'Rows per page:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: rowsPerPage,
                  icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54),
                  elevation: 4,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  items: [5, 10, 20, 50].map((val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text(
                        '$val',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _rowsPerPage = val;
                        _currentPage = 0;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        );

        final infoTextWidget = Text(
          'Showing $startItem-$endItem of $totalItems',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        );

        final navigationWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page_rounded, size: 18),
              onPressed: currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage = 0;
                      });
                    }
                  : null,
              tooltip: 'First Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 18),
              onPressed: currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage = currentPage - 1;
                      });
                    }
                  : null,
              tooltip: 'Previous Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${currentPage + 1} / ${totalPages > 0 ? totalPages : 1}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 18),
              onPressed: currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage = currentPage + 1;
                      });
                    }
                  : null,
              tooltip: 'Next Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.last_page_rounded, size: 18),
              onPressed: currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        _currentPage = totalPages - 1;
                      });
                    }
                  : null,
              tooltip: 'Last Page',
              color: AppColors.primary,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    dropdownWidget,
                    infoTextWidget,
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                navigationWidget,
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              dropdownWidget,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  infoTextWidget,
                  const SizedBox(width: 24),
                  navigationWidget,
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    ThemeData theme, {
    required bool isFiltered,
    required String title,
    required String message,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              isFiltered
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.25)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (isFiltered && widget.onClearFilters != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonalIcon(
                onPressed: widget.onClearFilters,
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Clear search & filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemberActions(BuildContext context, UserModel member) {
    final role = member.role.toLowerCase();
    final isEligible = role == 'member' || role == 'student' || role == 'staff';

    if (!isEligible) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (value) {
        if (value == 'promote_representative') {
          _showRepresentativeDialog(context, member);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'promote_representative',
          child: Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Promote to Representative'),
            ],
          ),
        ),
      ],
    );
  }

  void _showRepresentativeDialog(BuildContext context, UserModel member) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PromoteRepresentativeDialog(member: member),
    );
  }
}

class _PromoteRepresentativeDialog extends ConsumerStatefulWidget {
  final UserModel member;
  const _PromoteRepresentativeDialog({required this.member});

  @override
  ConsumerState<_PromoteRepresentativeDialog> createState() => _PromoteRepresentativeDialogState();
}

class _PromoteRepresentativeDialogState extends ConsumerState<_PromoteRepresentativeDialog> {
  String _durationOption = '24h'; // '24h' or 'permanent'
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;

    return AlertDialog(
      title: Container(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const Icon(Icons.trending_up_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            const Text('Promote to Representative'),
          ],
        ),
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to promote ${widget.member.fullName} to Representative?',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'This will assign them the Representative role, allowing them to view events, scan attendance, and request clearance.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Role Duration',
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Temporary (24 Hours)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Automatically demotes back to Member after 24 hours', style: TextStyle(fontSize: 12)),
                      value: '24h',
                      groupValue: _durationOption,
                      activeColor: AppColors.primary,
                      onChanged: _isSubmitting ? null : (val) => setState(() => _durationOption = val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('Permanent Duration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Active for the duration of the Academic Term', style: TextStyle(fontSize: 12)),
                      value: 'permanent',
                      groupValue: _durationOption,
                      activeColor: AppColors.primary,
                      onChanged: _isSubmitting ? null : (val) => setState(() => _durationOption = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting
              ? null
              : () => _handlePromotion(selectedOrg),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Confirm Promotion'),
        ),
      ],
    );
  }

  Future<void> _handlePromotion(dynamic selectedOrg) async {
    if (selectedOrg == null) {
      _showError('No organization selected.');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSubmitting = true);

    try {
      final activeTerm = await ref.read(activeTermProvider.future);
      if (activeTerm == null) {
        _showError('No active academic term found. Please contact the administrator.');
        return;
      }

      final roles = await ref.read(availableRolesProvider.future);
      final repRole = roles.firstWhere(
        (r) => r['name'].toString().toLowerCase() == 'representative',
        orElse: () => {},
      );
      if (repRole.isEmpty) {
        _showError('Representative role not found in database.');
        return;
      }

      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        _showError('Authentication error. Please log in again.');
        return;
      }

      final expiredAt = _durationOption == '24h'
          ? DateTime.now().add(const Duration(hours: 24))
          : null;

      await ref.read(organizationRepositoryProvider).assignOfficer(
        userId: widget.member.id!,
        orgId: selectedOrg.id,
        roleId: repRole['id'],
        termId: activeTerm.id,
        assignedBy: currentUser.id,
        workspaceType: selectedOrg.type,
        expiredAt: expiredAt,
      );

      ref.invalidate(organizationMembersProvider(selectedOrg.id));
      ref.invalidate(organizationOfficersProvider(selectedOrg.id));

      if (mounted) {
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text('${widget.member.fullName} successfully promoted to Representative.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('Promotion error: $e\n$stack');
      if (mounted) {
        _showError('Error promoting user: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    final lowerRole = role.toLowerCase();

    if (lowerRole.contains('governor')) {
      color = AppColors.primary;
    } else if (lowerRole.contains('treasurer')) {
      color = Colors.orange;
    } else if (lowerRole.contains('officer') || lowerRole.contains('dean') || lowerRole.contains('head') || lowerRole.contains('representative')) {
      color = Colors.blue;
    } else if (lowerRole.contains('staff')) {
      color = Colors.purple;
    } else if (lowerRole.contains('student') || lowerRole.contains('member')) {
      color = Colors.green;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.trim().toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CountdownTimerText extends StatefulWidget {
  final DateTime expiredAt;
  const _CountdownTimerText({required this.expiredAt});

  @override
  State<_CountdownTimerText> createState() => _CountdownTimerTextState();
}

class _CountdownTimerTextState extends State<_CountdownTimerText> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateRemaining();
        });
      }
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    _remaining = widget.expiredAt.difference(now);
    if (_remaining.isNegative) {
      _remaining = Duration.zero;
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text(
        'Expired',
        style: TextStyle(
          color: Colors.red[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }

    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$hours:$minutes:$seconds remaining',
      style: TextStyle(
        color: Colors.orange[800],
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    );
  }
}
