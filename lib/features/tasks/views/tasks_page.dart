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

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  bool _isOnline = true;
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
            final completedCount = tasks.where((t) => t.isCompleted).length;
            final pendingCount = tasks.length - completedCount;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sync status header & quick actions
                  _buildHeaderCard(tasks.length, completedCount, pendingCount),
                  const SizedBox(height: AppSpacing.xl),

                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Task List',
                        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (isDesktop)
                        TextButton.icon(
                          onPressed: () => _showAddEditTaskModal(),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Add Task'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Task items
                  if (tasks.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskCard(task);
                      },
                    ),
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
                Text('Error loading tasks: $err', style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _handleRefresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(int total, int completed, int pending) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Connectivity Status Badge
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _isOnline ? AppColors.success : AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    kIsWeb
                        ? 'Cloud Syncing (Web)'
                        : (_isOnline ? 'Online (Synced)' : 'Offline (Local Only)'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _isOnline ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Refresh Icon
              IconButton(
                onPressed: _handleRefresh,
                icon: _checkingConnectivity
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : const Icon(Icons.sync_rounded, color: AppColors.primary),
                tooltip: 'Sync and Refresh',
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', total.toString(), Icons.playlist_add_check_rounded),
              _buildStatItem('Pending', pending.toString(), Icons.hourglass_empty_rounded, color: AppColors.warning),
              _buildStatItem('Completed', completed.toString(), Icons.check_circle_outline_rounded, color: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count, IconData icon, {Color color = AppColors.primary}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(count, style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
      ],
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
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: task.isCompleted,
            activeColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (_) {
              ref.read(tasksProvider.notifier).toggleTaskCompletion(task);
            },
          ),
        ),
        title: Row(
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
        subtitle: Column(
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                      DateFormat('MMM dd, yyyy').format(task.dueDate!),
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
        ),
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
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.dueDate;
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.task == null) {
        // Create
        await ref.read(tasksProvider.notifier).addTask(
              _titleController.text.trim(),
              _descController.text.trim(),
              _selectedDate,
            );
      } else {
        // Edit
        final updated = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          dueDate: _selectedDate,
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AppSpacing.xl),
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
