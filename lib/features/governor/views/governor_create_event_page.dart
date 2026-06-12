import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/providers/storage_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../events/models/event_model.dart';
import '../../events/providers/event_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../academic_structure/providers/term_provider.dart';

class GovernorCreateEventPage extends ConsumerStatefulWidget {
  const GovernorCreateEventPage({super.key});

  @override
  ConsumerState<GovernorCreateEventPage> createState() => _GovernorCreateEventPageState();
}

class _GovernorCreateEventPageState extends ConsumerState<GovernorCreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _fullDescriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _timeInStart;
  TimeOfDay? _timeInEnd;
  TimeOfDay? _timeOutStart;
  TimeOfDay? _timeOutEnd;
  
  XFile? _eventImage;
  Uint8List? _eventImageBytes;
  final _picker = ImagePicker();
  
  bool _isMandatory = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescriptionController.dispose();
    _fullDescriptionController.dispose();
    _locationController.dispose();
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _eventImage = pickedFile;
        _eventImageBytes = bytes;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<TimeOfDay?> _selectTime(String label) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: label,
    );
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Not set';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }

  String _timeToDbString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null || _timeInStart == null || _timeInEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required date and time fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final workspace = ref.read(workspaceProvider);
      final org = workspace.selectedOrganization!;
      final user = ref.read(userProfileProvider).value!;
      final activeTerm = await ref.read(activeTermProvider.future);
      
      if (activeTerm == null) {
        throw Exception('No active academic term found. Please contact an administrator.');
      }
      
      String? imageUrl;
      if (_eventImage != null) {
        imageUrl = await ref.read(storageServiceProvider).uploadEventImage(
          file: _eventImage!,
          eventName: _nameController.text,
        );
      }
      
      final scopeType = org.type == 'campus-based' 
          ? 'Institutional' 
          : (org.type == 'faculty-based' ? 'Faculty' : 'Program');
      
      final scopeId = org.type == 'campus-based' 
          ? org.campusId 
          : (org.type == 'faculty-based' ? org.facultyId : org.programId);

      final event = EventModel(
        name: _nameController.text,
        eventDate: _selectedDate!,
        shortDescription: _shortDescriptionController.text,
        fullDescription: _fullDescriptionController.text,
        location: _locationController.text,
        imageUrl: imageUrl,
        timeInStart: _timeToDbString(_timeInStart!),
        timeInEnd: _timeToDbString(_timeInEnd!),
        timeOutStart: _timeOutStart != null ? _timeToDbString(_timeOutStart!) : '00:00:00',
        timeOutEnd: _timeOutEnd != null ? _timeToDbString(_timeOutEnd!) : '00:00:00',
        scopeType: scopeType,
        scopeId: scopeId!,
        isMandatory: _isMandatory,
        academicTermId: activeTerm.id,
        createdByUserId: user.id,
      );

      await ref.read(eventRepositoryProvider).createEvent(event);
      
      if (mounted) {
        ref.invalidate(workspaceEventsProvider);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Create New Event',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/workspace/events');
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/workspace/events');
                        }
                      },
                      child: Text(
                        'Events',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text(
                      'Create Event',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Event Visuals'),
                        const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                    image: _eventImageBytes != null
                        ? DecorationImage(image: MemoryImage(_eventImageBytes!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _eventImageBytes == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Click to upload event banner', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSectionTitle('General Information'),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'e.g., General Assembly 2026',
                  prefixIcon: _buildPrefixIcon(Icons.event),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., University Social Hall',
                  prefixIcon: _buildPrefixIcon(Icons.location_on),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _shortDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Short Description',
                  hintText: 'A brief summary of the event',
                  prefixIcon: _buildPrefixIcon(Icons.description_outlined),
                ),
                maxLength: 255,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _fullDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Full Description',
                  hintText: 'Detailed information about the event',
                  prefixIcon: _buildPrefixIcon(Icons.notes_rounded),
                ),
                maxLines: 5,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Date & Schedule'),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _buildPrefixIcon(Icons.calendar_month_rounded),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event Date', 
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textGrey, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedDate == null 
                                ? 'Not selected' 
                                : DateFormat.yMMMMd().format(_selectedDate!),
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _selectDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const Divider(),
              _buildTimeRow('Time In Window', _timeInStart, _timeInEnd, (start, end) {
                setState(() {
                  if (start != null) _timeInStart = start;
                  if (end != null) _timeInEnd = end;
                });
              }),
              const Divider(),
              _buildTimeRow('Time Out Window', _timeOutStart, _timeOutEnd, (start, end) {
                setState(() {
                  if (start != null) _timeOutStart = start;
                  if (end != null) _timeOutEnd = end;
                });
              }),
              
              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Event Settings'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mandatory Attendance'),
                subtitle: const Text('If enabled, this event will be required for all members'),
                value: _isMandatory,
                onChanged: (v) => setState(() => _isMandatory = v),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      : Text(
                          'Create Event', 
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
    );
  }

  Widget _buildTimeRow(String label, TimeOfDay? start, TimeOfDay? end, Function(TimeOfDay?, TimeOfDay?) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final t = await _selectTime('$label (Start)');
                  onPicked(t, null);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                  foregroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.access_time_rounded, size: 16),
                label: Text(
                  start == null ? 'Start Time' : _formatTimeOfDay(start),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('to', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final t = await _selectTime('$label (End)');
                  onPicked(null, t);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                  foregroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.access_time_rounded, size: 16),
                label: Text(
                  end == null ? 'End Time' : _formatTimeOfDay(end),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
