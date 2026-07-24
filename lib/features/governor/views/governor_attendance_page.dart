import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../core/enums/attendance_mode.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../events/models/event_model.dart';
import '../../events/providers/event_provider.dart';
import '../../attendance/views/attendance_history_page.dart';
import '../../attendance/views/attendance_report_page.dart';
import '../../attendance/widgets/event_scanner_screen.dart';
import '../../users/widgets/user_management_header.dart';

class GovernorAttendancePage extends ConsumerStatefulWidget {
  const GovernorAttendancePage({super.key});

  @override
  ConsumerState<GovernorAttendancePage> createState() => _GovernorAttendancePageState();
}

class _GovernorAttendancePageState extends ConsumerState<GovernorAttendancePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'All'; // All, Today, Upcoming, Past
  int _currentPage = 0;
  static const int _rowsPerPage = 10;

  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _currentPage = 0; // Reset pagination on search query change
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(workspaceEventsProvider);

    return DashboardLayout(
      title: 'Organization Attendance',
      child: eventsAsync.when(
        data: (events) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          // Calculate KPI metrics
          final totalEvents = events.length;
          final activeToday = events.where((e) {
            final eDate = DateTime(e.eventDate.year, e.eventDate.month, e.eventDate.day);
            return eDate.isAtSameMomentAs(today) && !e.isPastTimeout;
          }).length;
          final mandatoryEvents = events.where((e) => e.isMandatory).length;
          final completedEvents = events.where((e) => e.isPastTimeout).length;

          // Apply filters
          final query = _searchController.text.toLowerCase().trim();
          List<EventModel> filteredEvents = events.where((e) {
            final matchesSearch = e.name.toLowerCase().contains(query) ||
                e.location.toLowerCase().contains(query);

            final eDate = DateTime(e.eventDate.year, e.eventDate.month, e.eventDate.day);
            bool matchesTab = true;
            if (_selectedTab == 'Today') {
              matchesTab = eDate.isAtSameMomentAs(today);
            } else if (_selectedTab == 'Upcoming') {
              matchesTab = e.eventDate.isAfter(today) && !eDate.isAtSameMomentAs(today);
            } else if (_selectedTab == 'Past') {
              matchesTab = e.isPastTimeout || e.eventDate.isBefore(today);
            }

            return matchesSearch && matchesTab;
          }).toList();

          // Apply Sorting
          if (_sortColumnIndex != null) {
            filteredEvents.sort((a, b) {
              int cmp = 0;
              if (_sortColumnIndex == 0) {
                cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
              } else if (_sortColumnIndex == 1) {
                cmp = a.eventDate.compareTo(b.eventDate);
              } else if (_sortColumnIndex == 2) {
                cmp = a.location.toLowerCase().compareTo(b.location.toLowerCase());
              }
              return _sortAscending ? cmp : -cmp;
            });
          } else {
            // Default sort: Date descending (latest events first)
            filteredEvents.sort((a, b) => b.eventDate.compareTo(a.eventDate));
          }

          // Apply Pagination
          final totalFilteredRows = filteredEvents.length;
          final totalPages = (totalFilteredRows / _rowsPerPage).ceil();
          if (_currentPage >= totalPages && totalPages > 0) {
            _currentPage = totalPages - 1;
          }
          final startIndex = _currentPage * _rowsPerPage;
          final endIndex = (startIndex + _rowsPerPage > totalFilteredRows)
              ? totalFilteredRows
              : startIndex + _rowsPerPage;
          final paginatedEvents = (totalFilteredRows > 0)
              ? filteredEvents.sublist(startIndex, endIndex)
              : <EventModel>[];

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final verticalGap = isMobile ? AppSpacing.lg : AppSpacing.xl;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    UserManagementHeader(
                      title: 'Event Attendance',
                      subtitle: 'Monitor student check-ins, view scan logs, and manage QR scanning capabilities for organization events.',
                      actions: [
                        HeaderActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'Refresh',
                          onPressed: () => ref.refresh(workspaceEventsProvider),
                        ),
                      ],
                    ),
                    SizedBox(height: verticalGap),

                    // KPIs Summary Section
                    LayoutBuilder(
                      builder: (context, kpiConstraints) {
                        int crossAxisCount = 1;
                        if (kpiConstraints.maxWidth > 1000) {
                          crossAxisCount = 4;
                        } else if (kpiConstraints.maxWidth > 600) {
                          crossAxisCount = 2;
                        }

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisExtent: 84,
                          children: [
                            _KpiCard(
                              title: 'Total Events',
                              value: '$totalEvents',
                              icon: LucideIcons.calendar,
                              color: AppColors.primary,
                            ),
                            _KpiCard(
                              title: 'Active Today',
                              value: '$activeToday',
                              icon: LucideIcons.activity,
                              color: AppColors.success,
                            ),
                            _KpiCard(
                              title: 'Mandatory Events',
                              value: '$mandatoryEvents',
                              icon: LucideIcons.alertCircle,
                              color: Colors.orange,
                            ),
                            _KpiCard(
                              title: 'Completed Events',
                              value: '$completedEvents',
                              icon: LucideIcons.checkCircle2,
                              color: Colors.blueGrey,
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: verticalGap),

                    // Filters and Search Control
                    _buildFiltersAndSearch(context, isMobile),
                    const SizedBox(height: AppSpacing.lg),

                    // Main Table representation
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (paginatedEvents.isEmpty)
                            _buildEmptyState(context)
                          else
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                child: DataTable(
                                  columnSpacing: AppSpacing.lg,
                                  headingRowColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                  ),
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _sortAscending,
                                  columns: [
                                    DataColumn(
                                      label: const Text('Event Name'),
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: const Text('Date'),
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: const Text('Location'),
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                    const DataColumn(label: Text('Time In')),
                                    const DataColumn(label: Text('Time Out')),
                                    const DataColumn(label: Text('Status')),
                                    const DataColumn(label: Text('Actions')),
                                  ],
                                  rows: paginatedEvents.map((event) {
                                    final now = DateTime.now();
                                    final isToday = event.eventDate.year == now.year &&
                                        event.eventDate.month == now.month &&
                                        event.eventDate.day == now.day;
                                    final isScannerActive = isToday && !event.isPastTimeout;

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withOpacity(0.06),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  LucideIcons.calendar,
                                                  size: 16,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              const SizedBox(width: AppSpacing.md),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        event.name,
                                                        style: AppTextStyles.bodyMedium.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      if (event.isMandatory) ...[
                                                        const SizedBox(width: AppSpacing.xs),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: Colors.amber.withOpacity(0.15),
                                                            borderRadius: BorderRadius.circular(4),
                                                            border: Border.all(color: Colors.amber.withOpacity(0.4)),
                                                          ),
                                                          child: const Text(
                                                            'MANDATORY',
                                                            style: TextStyle(
                                                              color: Colors.orange,
                                                              fontSize: 8,
                                                              fontWeight: FontWeight.bold,
                                                              letterSpacing: 0.5,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  if (event.shortDescription != null)
                                                    Text(
                                                      event.shortDescription!,
                                                      style: AppTextStyles.labelSmall.copyWith(
                                                        color: AppColors.textGrey,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            DateFormat.yMMMd().format(event.eventDate),
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textGrey),
                                              const SizedBox(width: 4),
                                              Text(
                                                event.location,
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            TimeFormatter.formatTimeRange(event.timeInStart, event.timeInEnd),
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            TimeFormatter.formatTimeRange(event.timeOutStart, event.timeOutEnd),
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ),
                                        DataCell(_buildStatusBadge(event)),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(LucideIcons.scan, size: 16),
                                                color: isScannerActive ? AppColors.success : Colors.grey,
                                                tooltip: isScannerActive ? 'Scan QR Code' : 'Scanner not active',
                                                onPressed: isScannerActive
                                                    ? () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) => EventScannerScreen(event: event),
                                                          ),
                                                        );
                                                      }
                                                    : null,
                                              ),
                                              IconButton(
                                                icon: const Icon(LucideIcons.history, size: 16),
                                                color: AppColors.primary,
                                                tooltip: 'View Scan Logs',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => AttendanceHistoryPage(
                                                        eventId: event.id!,
                                                        eventName: event.name,
                                                        event: event,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(LucideIcons.barChart2, size: 16),
                                                color: AppColors.primary,
                                                tooltip: 'Attendance Report',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => AttendanceReportPage(event: event),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          if (paginatedEvents.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Showing ${startIndex + 1} to $endIndex of $totalFilteredRows events',
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: _currentPage > 0
                                            ? () => setState(() => _currentPage--)
                                            : null,
                                        child: const Text('Previous'),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      TextButton(
                                        onPressed: _currentPage < totalPages - 1
                                            ? () => setState(() => _currentPage++)
                                            : null,
                                        child: const Text('Next'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: FlickrLoader(),
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text('Error loading events: $err'),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () => ref.refresh(workspaceEventsProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch(BuildContext context, bool isMobile) {
    final searchField = Container(
      width: isMobile ? double.infinity : 280,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search events or location...',
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.35), fontSize: 12),
          prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.xCircle, size: 16, color: Colors.black26),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );

    final tabs = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Today', 'Upcoming', 'Past'].map((tab) {
          final isSelected = _selectedTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                tab,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.textGrey,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTab = tab;
                    _currentPage = 0;
                  });
                }
              },
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchField,
          const SizedBox(height: 12),
          tabs,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        tabs,
        searchField,
      ],
    );
  }

  Widget _buildStatusBadge(EventModel event) {
    Color color;
    String label;
    final mode = event.currentAttendanceMode;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eDate = DateTime(event.eventDate.year, event.eventDate.month, event.eventDate.day);

    if (event.isPastTimeout) {
      color = Colors.grey;
      label = 'Completed';
    } else if (eDate.isAtSameMomentAs(today)) {
      if (mode == AttendanceMode.timeIn) {
        color = AppColors.success;
        label = 'Time In Open';
      } else if (mode == AttendanceMode.timeOut) {
        color = AppColors.primary;
        label = 'Time Out Open';
      } else {
        color = Colors.blueGrey;
        label = 'Today - Closed';
      }
    } else if (event.eventDate.isAfter(today)) {
      color = Colors.orange;
      label = 'Upcoming';
    } else {
      color = Colors.grey;
      label = 'Completed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Icon(LucideIcons.calendarOff, size: 48, color: theme.colorScheme.primary.withOpacity(0.2)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No events found',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search criteria.'
                : 'There are no events in this category yet.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
