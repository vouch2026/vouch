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
import '../models/task_model.dart';
import '../providers/task_provider.dart';

import '../../../shared/layouts/responsive_layout.dart';
import '../../../core/widgets/states/offline_state_view.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  // ignore: unused_field
  bool _isOnline = true;
  // ignore: unused_field
  bool _checkingConnectivity = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
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
    await ref.read(tasksProvider.notifier).syncAndRefresh();
  }

  void _showAddEditTaskModal({TaskModel? task}) {
    showDialog(
      context: context,
      builder: (context) => _AddEditTaskModal(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return DashboardLayout(
      title: 'My Tasks',
      floatingActionButton: !isDesktop
          ? FloatingActionButton(
              onPressed: () => _showAddEditTaskModal(),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: tasksAsync.when(
          data: (tasks) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            // Filter uncompleted tasks
            final pastTasks = tasks.where((t) {
              if (t.isCompleted || t.dueDate == null) return false;
              final dueDay = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
              return dueDay.isBefore(today);
            }).toList();

            final todayTasks = tasks.where((t) {
              if (t.isCompleted || t.dueDate == null) return false;
              final dueDay = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
              return dueDay.isAtSameMomentAs(today);
            }).toList();

            final upcomingTasks = tasks.where((t) {
              if (t.isCompleted) return false;
              if (t.dueDate == null) return true;
              final dueDay = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
              return dueDay.isAfter(today);
            }).toList();

            // Filter completed tasks
            final completedTasks = tasks.where((t) => t.isCompleted).toList();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Task List',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          if (isDesktop) ...[
                            TextButton.icon(
                              onPressed: () => _showAddEditTaskModal(),
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: const Text('Add Task'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (val) {
                              if (val == 'delete_completed') {
                                _confirmDeleteAllCompletedTasks();
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'delete_completed',
                                enabled: completedTasks.isNotEmpty,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.delete_sweep_rounded,
                                    color: completedTasks.isNotEmpty ? AppColors.error : AppColors.textGrey,
                                    size: 20,
                                  ),
                                  title: Text(
                                    'Delete Completed',
                                    style: TextStyle(
                                      color: completedTasks.isNotEmpty ? AppColors.error : AppColors.textGrey,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Task items
                  if (tasks.isEmpty)
                    _buildEmptyState()
                  else ...[
                    if (pastTasks.isEmpty && todayTasks.isEmpty && upcomingTasks.isEmpty)
                      _buildAllDoneState()
                    else ...[
                      if (pastTasks.isNotEmpty) ...[
                        _TaskGroupCard(
                          title: 'Past Tasks',
                          subtitle: '${pastTasks.length} task${pastTasks.length == 1 ? '' : 's'} overdue',
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.error,
                          tasks: pastTasks,
                          taskBuilder: _buildTaskCard,
                          initiallyExpanded: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (todayTasks.isNotEmpty) ...[
                        _TaskGroupCard(
                          title: "Today's Tasks",
                          subtitle: '${todayTasks.length} task${todayTasks.length == 1 ? '' : 's'} due today',
                          icon: Icons.today_rounded,
                          color: AppColors.primary,
                          tasks: todayTasks,
                          taskBuilder: _buildTaskCard,
                          initiallyExpanded: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (upcomingTasks.isNotEmpty) ...[
                        _TaskGroupCard(
                          title: 'Upcoming Tasks',
                          subtitle: '${upcomingTasks.length} task${upcomingTasks.length == 1 ? '' : 's'} upcoming',
                          icon: Icons.calendar_month_outlined,
                          color: AppColors.info,
                          tasks: upcomingTasks,
                          taskBuilder: _buildTaskCard,
                          initiallyExpanded: false,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                    if (completedTasks.isNotEmpty) ...[
                      _TaskGroupCard(
                        title: 'Completed Tasks',
                        subtitle: '${completedTasks.length} task${completedTasks.length == 1 ? '' : 's'} completed',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.success,
                        tasks: completedTasks,
                        taskBuilder: _buildTaskCard,
                        initiallyExpanded: false,
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: FlickrLoader()),
          error: (err, stack) {
            if (OfflineStateView.isOfflineError(err)) {
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
                  Text('Error loading tasks: $err', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _handleRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.playlist_add_rounded,
            size: 64,
            color: AppColors.textGrey,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No tasks found',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Keep track of your projects and duties by adding tasks.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => _showAddEditTaskModal(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Your First Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return Container(
      decoration: BoxDecoration(
        color: task.isCompleted ? AppColors.background : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted ? Colors.transparent : AppColors.border,
        ),
        boxShadow: [
          if (!task.isCompleted)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        isThreeLine: task.description.isNotEmpty || task.dueDate != null,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: task.isCompleted,
            activeColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (_) async {
              try {
                await ref.read(tasksProvider.notifier).toggleTaskCompletion(task);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update task: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  color: task.isCompleted ? AppColors.textGrey : AppColors.textDark,
                ),
              ),
            ),
            // Unsynced Indicator Icon for mobile
            if (!kIsWeb && task.syncStatus != 'synced') ...[
              const SizedBox(width: AppSpacing.xs),
              Tooltip(
                message: task.syncStatus == 'to_create' ? 'Saved locally (pending upload)' : 'Pending sync',
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
              ),
            ],
          ],
        ),
        subtitle: (task.description.isNotEmpty || task.dueDate != null)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      task.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textGrey,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                  if (task.dueDate != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOverdue ? AppColors.error.withValues(alpha: 0.08) : AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: isOverdue ? AppColors.error : AppColors.textGrey,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            task.dueDate!.hour == 0 && task.dueDate!.minute == 0
                                ? DateFormat('MMM dd, yyyy').format(task.dueDate!)
                                : DateFormat('MMM dd, yyyy \'at\' h:mm a').format(task.dueDate!),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isOverdue ? AppColors.error : AppColors.textGrey,
                              fontWeight: isOverdue ? FontWeight.bold : null,
                            ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Overdue',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              )
            : null,
        trailing: PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (val) {
            if (val == 'edit') {
              _showAddEditTaskModal(task: task);
            } else if (val == 'delete') {
              _confirmDeleteTask(task.id!);
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

  void _confirmDeleteTask(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              try {
                await ref.read(tasksProvider.notifier).deleteTask(id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete task: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAllCompletedTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Completed Tasks'),
        content: const Text('Are you sure you want to delete all completed tasks? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              try {
                await ref.read(tasksProvider.notifier).deleteAllCompletedTasks();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete completed tasks: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Widget _buildAllDoneState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.done_all_rounded,
              size: 40,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'All tasks completed!',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Great job! You have no pending tasks.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddEditTaskModal extends ConsumerStatefulWidget {
  final TaskModel? task;

  const _AddEditTaskModal({this.task});

  @override
  ConsumerState<_AddEditTaskModal> createState() => _AddEditTaskModalState();
}

class _AddEditTaskModalState extends ConsumerState<_AddEditTaskModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.dueDate;
    if (widget.task?.dueDate != null) {
      _selectedTime = TimeOfDay(
        hour: widget.task!.dueDate!.hour,
        minute: widget.task!.dueDate!.minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      DateTime? finalDueDate;
      if (_selectedDate != null) {
        final time = _selectedTime ?? const TimeOfDay(hour: 0, minute: 0);
        finalDueDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          time.hour,
          time.minute,
        );
      }

      if (widget.task == null) {
        // Create
        await ref.read(tasksProvider.notifier).addTask(
              _titleController.text.trim(),
              _descController.text.trim(),
              finalDueDate,
            );
      } else {
        // Edit
        final updated = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          dueDate: finalDueDate,
        );
        await ref.read(tasksProvider.notifier).updateTask(updated);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.task == null ? 'Task created successfully' : 'Task updated successfully',
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
    final isEdit = widget.task != null;
    final isMobile = ResponsiveLayout.isMobile(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 16 : 24)),
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0)
          : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      child: Container(
        width: isMobile ? double.infinity : 500,
        padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
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
                    isEdit ? 'Edit Task' : 'Add New Task',
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Task Title',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Prepare financial statement',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Description
              Text(
                'Description (Optional)',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add details about this task...',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Due Date Picker
              Text(
                'Due Date (Optional)',
                style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'No due date selected'
                            : DateFormat('MMMM dd, yyyy').format(_selectedDate!),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _selectedDate == null ? AppColors.textGrey : AppColors.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          if (_selectedDate != null)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDate = null;
                                });
                              },
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedDate != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Due Time (Optional)',
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                InkWell(
                  onTap: _selectTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTime == null
                              ? 'Default (12:00 AM)'
                              : _selectedTime!.format(context),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _selectedTime == null ? AppColors.textGrey : AppColors.textDark,
                          ),
                        ),
                        Row(
                          children: [
                            if (_selectedTime != null)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedTime = null;
                                  });
                                },
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(Icons.access_time_rounded, color: AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),

              // Submit Action
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
                          child: Text(isEdit ? 'Save Changes' : 'Create Task'),
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

class _TaskGroupCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<TaskModel> tasks;
  final Widget Function(TaskModel) taskBuilder;
  final bool initiallyExpanded;

  const _TaskGroupCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tasks,
    required this.taskBuilder,
    this.initiallyExpanded = false,
  });

  @override
  State<_TaskGroupCard> createState() => _TaskGroupCardState();
}

class _TaskGroupCardState extends State<_TaskGroupCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.white,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.color, size: 20),
          ),
          title: Text(
            widget.title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          subtitle: Text(
            widget.subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
          ),
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            color: AppColors.textGrey,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.tasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  return widget.taskBuilder(widget.tasks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
