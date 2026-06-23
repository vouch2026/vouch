import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../events/models/event_model.dart';
import '../../events/providers/event_provider.dart';
import '../../events/views/student_event_details_page.dart';
import '../../organizations/providers/organization_provider.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';
import '../../../core/utils/time_formatter.dart';

// A provider to resolve all scope/org IDs to human-readable names
final scopeNamesProvider = FutureProvider<Map<String, String>>((ref) async {
  final Map<String, String> map = {};
  
  // Load organizations
  try {
    final orgs = await ref.read(organizationsProvider.future);
    for (final org in orgs) {
      map[org.id] = org.name;
    }
  } catch (_) {}

  // Load campuses
  try {
    final campuses = await ref.read(campusesProvider.future);
    for (final campus in campuses) {
      map[campus.id] = campus.name;
    }
  } catch (_) {}

  // Load faculties
  try {
    final faculties = await ref.read(facultiesProvider.future);
    for (final faculty in faculties) {
      map[faculty.id] = faculty.name;
    }
  } catch (_) {}

  // Load programs
  try {
    final programs = await ref.read(programsProvider.future);
    for (final program in programs) {
      map[program.id] = program.name;
    }
  } catch (_) {}

  return map;
});

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
  }

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    
    // Convert weekday offset to Sunday-first (0 = Sunday, 6 = Saturday)
    final weekdayOffset = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    
    final days = <DateTime>[];
    
    // Add previous month's trailing days
    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final daysInPrevMonth = DateTime(month.year, month.month, 0).day;
    for (int i = weekdayOffset - 1; i >= 0; i--) {
      days.add(DateTime(prevMonth.year, prevMonth.month, daysInPrevMonth - i));
    }
    
    // Add current month's days
    final daysInCurrentMonth = DateTime(month.year, month.month + 1, 0).day;
    for (int i = 1; i <= daysInCurrentMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    
    // Fill remaining cells for standard grid rows
    final totalDaysNeeded = ((days.length / 7).ceil() * 7);
    final trailingDaysNeeded = totalDaysNeeded - days.length;
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    for (int i = 1; i <= trailingDaysNeeded; i++) {
      days.add(DateTime(nextMonth.year, nextMonth.month, i));
    }
    
    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasEvents(DateTime day, List<EventModel> events) {
    return events.any((e) => _isSameDay(e.eventDate, day));
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(allEventsProvider);
    final scopesAsync = ref.watch(scopeNamesProvider);

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;

    return DashboardLayout(
      title: 'Academic Calendar',
      child: eventsAsync.when(
        data: (events) {
          final scopesMap = scopesAsync.value ?? {};
          final days = _generateDaysInMonth(_focusedDay);

          // Get events for the selected day
          final selectedDayEvents = events.where((e) => _isSameDay(e.eventDate, _selectedDay)).toList()
            ..sort((a, b) => a.timeInStart.compareTo(b.timeInStart));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Calendar Grid
                      Expanded(
                        flex: 4,
                        child: _buildCalendarCard(days, events),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      // Right Column: Selected Day Events
                      Expanded(
                        flex: 3,
                        child: _buildEventsListCard(selectedDayEvents, scopesMap),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildCalendarCard(days, events),
                      const SizedBox(height: AppSpacing.lg),
                      _buildEventsListCard(selectedDayEvents, scopesMap),
                    ],
                  ),
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text('Error loading calendar events: $err', style: AppTextStyles.bodyLarge),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => ref.invalidate(allEventsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard(List<DateTime> days, List<EventModel> events) {
    final weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month/Year navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_focusedDay),
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _prevMonth,
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                    tooltip: 'Previous Month',
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded, size: 28),
                    tooltip: 'Next Month',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Weekday Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: AppSpacing.lg),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = _isSameDay(day, _selectedDay);
              final isToday = _isSameDay(day, DateTime.now());
              final isCurrentMonth = day.month == _focusedDay.month;
              final dayHasEvents = _hasEvents(day, events);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isToday ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Day Number
                        Text(
                          day.day.toString(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? AppColors.white
                                : (isCurrentMonth ? AppColors.textDark : AppColors.textGrey.withValues(alpha: 0.5)),
                          ),
                        ),
                        // Event dot indicator
                        if (dayHasEvents)
                          Positioned(
                            bottom: 6,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accent : AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsListCard(List<EventModel> dayEvents, Map<String, String> scopesMap) {
    final formattedDate = DateFormat('MMMM dd, yyyy').format(_selectedDay);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header showing selected date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule Events',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${dayEvents.length} Event${dayEvents.length == 1 ? '' : 's'}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),

          // Events list
          if (dayEvents.isEmpty)
            _buildEmptyEventsState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dayEvents.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final event = dayEvents[index];
                return _buildEventTile(event, scopesMap);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 40,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No events scheduled',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'There are no organization activities scheduled for this day.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(EventModel event, Map<String, String> scopesMap) {
    final scopeName = scopesMap[event.scopeId] ?? event.scopeType;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentEventDetailsPage(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Organization scope & Mandatory badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.corporate_fare_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            scopeName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: event.isMandatory
                          ? AppColors.accent.withValues(alpha: 0.1)
                          : AppColors.textGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.isMandatory ? 'Mandatory' : 'Optional',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: event.isMandatory ? AppColors.primaryDark : AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Event Name
              Text(
                event.name,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              if (event.shortDescription != null && event.shortDescription!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  event.shortDescription!,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Divider(height: AppSpacing.md),

              // Location & Time row
              Row(
                children: [
                  // Time
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textGrey),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            TimeFormatter.formatTimeRange(event.timeInStart, event.timeOutEnd),
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Location
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textGrey),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            event.location,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
}
