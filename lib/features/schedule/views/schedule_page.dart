import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../core/config/supabase_config.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';
import '../../../shared/layouts/responsive_layout.dart';
import '../../../core/widgets/states/offline_state_view.dart';
import '../../../core/services/notification_service.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // ignore: unused_field
  bool _isOnline = true;
  // ignore: unused_field
  bool _checkingConnectivity = false;

  final List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    // Default tab index to today (0 = Monday, 6 = Sunday)
    final todayWeekday = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    _tabController = TabController(
      length: _weekdays.length,
      vsync: this,
      initialIndex: todayWeekday - 1,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tabController.animateTo(todayWeekday - 1);
      }
    });
    _checkConnectivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    if (kIsWeb) {
      setState(() {
        _isOnline = true;
      });
      return;
    }
    setState(() => _checkingConnectivity = true);
    try {
      final client = SupabaseConfig.client;
      final host = Uri.parse(client.rest.url).host;
      final result = await InternetAddress.lookup(host).timeout(const Duration(seconds: 2));
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (mounted) {
        setState(() {
          _isOnline = online;
          _checkingConnectivity = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isOnline = false;
          _checkingConnectivity = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _checkConnectivity();
    await ref.read(schedulesProvider.notifier).syncAndRefresh();
  }

  void _showAddEditScheduleModal({ScheduleModel? schedule}) {
    showDialog(
      context: context,
      builder: (context) => _AddEditScheduleModal(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(schedulesProvider);
    final activeTermAsync = ref.watch(activeTermProvider);
    final isMobile = ResponsiveLayout.isMobile(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return DashboardLayout(
      title: 'School Schedule',
      floatingActionButton: (isMobile || isTablet)
          ? FloatingActionButton(
              onPressed: () => _showAddEditScheduleModal(),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      child: activeTermAsync.when(
        data: (activeTerm) {
          if (activeTerm == null) {
            return _buildNoActiveTermState();
          }

          return schedulesAsync.when(
            data: (schedules) {
              return Column(
                children: [
                  // Simple top row containing A.Y., status, sync and add button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weekly Schedule',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'A.Y. ${activeTerm.academicYear} — ${activeTerm.semester}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              onPressed: () async {
                                await NotificationService.showInstantTestNotification();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Test notification scheduled in 5 seconds! Feel free to lock your screen.'),
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.notifications_active, color: AppColors.primary),
                              tooltip: 'Test Notification',
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                            if (isDesktop) ...[
                              const SizedBox(width: AppSpacing.md),
                              FilledButton.icon(
                                onPressed: () => _showAddEditScheduleModal(),
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Add Subject'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
                                  minimumSize: const Size(0, 32),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Weekday Tab Bar
                  const SizedBox(height: AppSpacing.md),
                  TabBar(
                    controller: _tabController,
                    isScrollable: !isMobile,
                    tabAlignment: isMobile ? TabAlignment.fill : TabAlignment.start,
                    labelPadding: isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textGrey,
                    indicatorColor: AppColors.primary,
                    dividerColor: AppColors.border,
                    tabs: _weekdays.map((day) => Tab(text: day.substring(0, 3))).toList(),
                  ),

                  // Tab Views / Subject Lists
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _weekdays.map((day) {
                        final daySchedules = schedules
                            .where((s) => s.days.contains(day))
                            .toList()
                          ..sort((a, b) => a.startTime.compareTo(b.startTime));

                        return RefreshIndicator(
                          onRefresh: _handleRefresh,
                          child: _buildDayScheduleList(day, daySchedules),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: FlickrLoader()),
            error: (err, _) => _buildErrorState(err.toString()),
          );
        },
        loading: () => const Center(child: FlickrLoader()),
        error: (err, _) => _buildErrorState(err.toString()),
      ),
    );
  }

  Widget _buildNoActiveTermState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_rounded, size: 64, color: AppColors.textGrey),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Active Academic Term',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Subject schedules cannot be loaded or managed without an active academic year term. Please contact administrators.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    if (OfflineStateView.isOfflineError(message)) {
      return OfflineStateView(
        onRetry: _handleRefresh,
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text('Error: $message', style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _handleRefresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }



  Widget _buildDayScheduleList(String day, List<ScheduleModel> items) {
    if (items.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: 300,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 48, color: AppColors.textGrey),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No classes scheduled',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Enjoy your free day or add schedules for $day.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final schedule = items[index];
        return _buildScheduleCard(schedule);
      },
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${schedule.subjectCode}: ${schedule.subjectName}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (!kIsWeb && schedule.syncStatus != 'synced') ...[
              const SizedBox(width: AppSpacing.xs),
              Tooltip(
                message: 'Pending Sync',
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textGrey),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${schedule.startTime} - ${schedule.endTime}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (schedule.teacher.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textGrey),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    schedule.teacher,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
            ],
            if (schedule.room.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.meeting_room_outlined, size: 14, color: AppColors.textGrey),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Room: ${schedule.room}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            // Highlight days row
            _buildDaysIndicator(schedule.days),
          ],
        ),
        trailing: PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (val) {
            if (val == 'edit') {
              _showAddEditScheduleModal(schedule: schedule);
            } else if (val == 'delete') {
              _confirmDeleteSchedule(schedule.id!);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_rounded, size: 20),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                title: Text('Delete', style: TextStyle(color: AppColors.error)),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysIndicator(List<String> selectedDays) {
    final shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final fullDays = _weekdays;

    return Wrap(
      spacing: 6,
      children: List.generate(shortDays.length, (index) {
        final isHighlighted = selectedDays.contains(fullDays[index]);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHighlighted ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
            ),
          ),
          child: Text(
            shortDays[index],
            style: AppTextStyles.labelSmall.copyWith(
              color: isHighlighted ? AppColors.primary : AppColors.textGrey,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              fontSize: 10,
            ),
          ),
        );
      }),
    );
  }

  void _confirmDeleteSchedule(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this subject schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(schedulesProvider.notifier).deleteSchedule(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddEditScheduleModal extends ConsumerStatefulWidget {
  final ScheduleModel? schedule;

  const _AddEditScheduleModal({this.schedule});

  @override
  ConsumerState<_AddEditScheduleModal> createState() => _AddEditScheduleModalState();
}

class _AddEditScheduleModalState extends ConsumerState<_AddEditScheduleModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _teacherController;
  late TextEditingController _startController;
  late TextEditingController _endController;
  late TextEditingController _roomController;
  
  List<String> _selectedDays = [];
  bool _isLoading = false;
  int _reminderMinutes = 0;

  final List<String> _allWeekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.schedule?.subjectCode ?? '');
    _nameController = TextEditingController(text: widget.schedule?.subjectName ?? '');
    _teacherController = TextEditingController(text: widget.schedule?.teacher ?? '');
    _startController = TextEditingController(text: widget.schedule?.startTime ?? '');
    _endController = TextEditingController(text: widget.schedule?.endTime ?? '');
    _roomController = TextEditingController(text: widget.schedule?.room ?? '');
    _selectedDays = widget.schedule != null ? List<String>.from(widget.schedule!.days) : [];
    _reminderMinutes = widget.schedule?.reminderMinutes ?? 0;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _teacherController.dispose();
    _startController.dispose();
    _endController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    // Parse current value if exists
    TimeOfDay initial = TimeOfDay.now();
    if (controller.text.isNotEmpty) {
      try {
        final format = DateFormat.jm(); // 12-hour format
        final dt = format.parse(controller.text);
        initial = TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (_) {}
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null && mounted) {
      controller.text = picked.format(context);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.schedule == null) {
        await ref.read(schedulesProvider.notifier).addSchedule(
              subjectCode: _codeController.text.trim(),
              subjectName: _nameController.text.trim(),
              teacher: _teacherController.text.trim(),
              startTime: _startController.text.trim(),
              endTime: _endController.text.trim(),
              days: _selectedDays,
              room: _roomController.text.trim(),
              reminderMinutes: _reminderMinutes,
            );
      } else {
        final updated = widget.schedule!.copyWith(
          subjectCode: _codeController.text.trim(),
          subjectName: _nameController.text.trim(),
          teacher: _teacherController.text.trim(),
          startTime: _startController.text.trim(),
          endTime: _endController.text.trim(),
          days: _selectedDays,
          room: _roomController.text.trim(),
          reminderMinutes: _reminderMinutes,
        );
        await ref.read(schedulesProvider.notifier).updateSchedule(updated);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.schedule == null
                  ? 'Subject schedule created successfully'
                  : 'Subject schedule updated successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.schedule != null;
    final isMobile = ResponsiveLayout.isMobile(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 16 : 24)),
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0)
          : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      child: Container(
        width: isMobile ? double.infinity : 520,
        padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Class Schedule' : 'Add Class Schedule',
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Code and Name row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Subject Code', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _codeController,
                            decoration: const InputDecoration(hintText: 'e.g. IT201'),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Subject Name', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(hintText: 'e.g. Database Systems'),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Teacher
                Text('Teacher / Professor (Optional)', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _teacherController,
                  decoration: const InputDecoration(hintText: 'e.g. Dr. Alan Turing'),
                ),
                const SizedBox(height: AppSpacing.md),

                // Room
                Text('Room / Location (Optional)', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(hintText: 'e.g. Room 302 / IT Lab 1'),
                ),
                const SizedBox(height: AppSpacing.md),

                // Times row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Time', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _startController,
                            readOnly: true,
                            onTap: () => _selectTime(_startController),
                            decoration: const InputDecoration(
                              hintText: 'Select Start',
                              suffixIcon: Icon(Icons.access_time_rounded),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End Time', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _endController,
                            readOnly: true,
                            onTap: () => _selectTime(_endController),
                            decoration: const InputDecoration(
                              hintText: 'Select End',
                              suffixIcon: Icon(Icons.access_time_rounded),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Weekday selection
                Text('Days of the Week', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _allWeekdays.map((day) {
                    final isSelected = _selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day.substring(0, 3)),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textGrey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Reminder selection
                Text('Reminder (Before Class)', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<int>(
                  value: _reminderMinutes,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.notifications_active_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('None')),
                    DropdownMenuItem(value: 15, child: Text('15 minutes before')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _reminderMinutes = val);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : FilledButton(
                            onPressed: _save,
                            child: Text(isEdit ? 'Save Changes' : 'Create Schedule'),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
