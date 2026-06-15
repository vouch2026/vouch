import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
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

  // Multiple sessions variables
  bool _createMultipleSessions = false;

  bool _morningEnabled = true;
  TimeOfDay? _morningTimeInStart;
  TimeOfDay? _morningTimeInEnd;
  TimeOfDay? _morningTimeOutStart;
  TimeOfDay? _morningTimeOutEnd;

  bool _afternoonEnabled = true;
  TimeOfDay? _afternoonTimeInStart;
  TimeOfDay? _afternoonTimeInEnd;
  TimeOfDay? _afternoonTimeOutStart;
  TimeOfDay? _afternoonTimeOutEnd;

  bool _eveningEnabled = false;
  TimeOfDay? _eveningTimeInStart;
  TimeOfDay? _eveningTimeInEnd;
  TimeOfDay? _eveningTimeOutStart;
  TimeOfDay? _eveningTimeOutEnd;
  
  final _timeInLongevityController = TextEditingController(text: '15');
  final _timeOutLongevityController = TextEditingController(text: '15');

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
    _timeInLongevityController.dispose();
    _timeOutLongevityController.dispose();
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
    
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event date')),
      );
      return;
    }

    if (_createMultipleSessions) {
      if (!_morningEnabled && !_afternoonEnabled && !_eveningEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable at least one session')),
        );
        return;
      }
      if (_morningEnabled && (_morningTimeInStart == null || _morningTimeInEnd == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill Time In for Morning session')),
        );
        return;
      }
      if (_afternoonEnabled && (_afternoonTimeInStart == null || _afternoonTimeInEnd == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill Time In for Afternoon session')),
        );
        return;
      }
      if (_eveningEnabled && (_eveningTimeInStart == null || _eveningTimeInEnd == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill Time In for Evening session')),
        );
        return;
      }
    } else {
      if (_timeInStart == null || _timeInEnd == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required Time In fields')),
        );
        return;
      }
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

      final List<EventModel> eventsToCreate = [];

      if (_createMultipleSessions) {
        if (_morningEnabled) {
          eventsToCreate.add(EventModel(
            name: '${_nameController.text} (Morning)',
            eventDate: _selectedDate!,
            shortDescription: _shortDescriptionController.text,
            fullDescription: _fullDescriptionController.text,
            location: _locationController.text,
            imageUrl: imageUrl,
            timeInStart: _timeToDbString(_morningTimeInStart!),
            timeInEnd: _timeToDbString(_morningTimeInEnd!),
            timeOutStart: _morningTimeOutStart != null ? _timeToDbString(_morningTimeOutStart!) : '00:00:00',
            timeOutEnd: _morningTimeOutEnd != null ? _timeToDbString(_morningTimeOutEnd!) : '00:00:00',
            scopeType: scopeType,
            scopeId: scopeId!,
            isMandatory: _isMandatory,
            academicTermId: activeTerm.id,
            createdByUserId: user.id,
          ));
        }
        if (_afternoonEnabled) {
          eventsToCreate.add(EventModel(
            name: '${_nameController.text} (Afternoon)',
            eventDate: _selectedDate!,
            shortDescription: _shortDescriptionController.text,
            fullDescription: _fullDescriptionController.text,
            location: _locationController.text,
            imageUrl: imageUrl,
            timeInStart: _timeToDbString(_afternoonTimeInStart!),
            timeInEnd: _timeToDbString(_afternoonTimeInEnd!),
            timeOutStart: _afternoonTimeOutStart != null ? _timeToDbString(_afternoonTimeOutStart!) : '00:00:00',
            timeOutEnd: _afternoonTimeOutEnd != null ? _timeToDbString(_afternoonTimeOutEnd!) : '00:00:00',
            scopeType: scopeType,
            scopeId: scopeId!,
            isMandatory: _isMandatory,
            academicTermId: activeTerm.id,
            createdByUserId: user.id,
          ));
        }
        if (_eveningEnabled) {
          eventsToCreate.add(EventModel(
            name: '${_nameController.text} (Evening)',
            eventDate: _selectedDate!,
            shortDescription: _shortDescriptionController.text,
            fullDescription: _fullDescriptionController.text,
            location: _locationController.text,
            imageUrl: imageUrl,
            timeInStart: _timeToDbString(_eveningTimeInStart!),
            timeInEnd: _timeToDbString(_eveningTimeInEnd!),
            timeOutStart: _eveningTimeOutStart != null ? _timeToDbString(_eveningTimeOutStart!) : '00:00:00',
            timeOutEnd: _eveningTimeOutEnd != null ? _timeToDbString(_eveningTimeOutEnd!) : '00:00:00',
            scopeType: scopeType,
            scopeId: scopeId!,
            isMandatory: _isMandatory,
            academicTermId: activeTerm.id,
            createdByUserId: user.id,
          ));
        }
      } else {
        eventsToCreate.add(EventModel(
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
        ));
      }

      for (final event in eventsToCreate) {
        await ref.read(eventRepositoryProvider).createEvent(event);
      }
      
      if (mounted) {
        ref.invalidate(workspaceEventsProvider);
        context.pop();
        final count = eventsToCreate.length;
        final message = count > 1 
            ? '$count event sessions created successfully'
            : 'Event created successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
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

  List<Widget> _buildLeftFormFields() {
    return [
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
    ];
  }

  List<Widget> _buildRightFormFields() {
    return [
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
      const SizedBox(height: AppSpacing.md),
      
      // Multiple Session Toggle Card
      Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Create Session Versions',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          subtitle: const Text('Generate separate (Morning), (Afternoon), and/or (Evening) event sessions automatically'),
          value: _createMultipleSessions,
          onChanged: (v) => setState(() => _createMultipleSessions = v),
          activeThumbColor: AppColors.primary,
        ),
      ),
      
      const SizedBox(height: AppSpacing.md),
      
      // Longevity Settings Card
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Longevity Settings',
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sets the duration (in minutes) to automatically calculate end times when picking start times.',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _timeInLongevityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Time In Longevity (mins)',
                      hintText: 'e.g., 15',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    onChanged: (v) => _recalculateAllEndTimes(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _timeOutLongevityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Time Out Longevity (mins)',
                      hintText: 'e.g., 15',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    onChanged: (v) => _recalculateAllEndTimes(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      
      const Divider(height: AppSpacing.lg),
      
      if (!_createMultipleSessions) ...[
        _buildTimeRow('Time In Window', _timeInStart, _timeInEnd, (start, end) {
          setState(() {
            if (start != null) {
              _timeInStart = start;
              final mins = int.tryParse(_timeInLongevityController.text);
              if (mins != null) {
                _timeInEnd = _calculateEndTime(start, mins);
              }
            }
            if (end != null) _timeInEnd = end;
          });
        }),
        const Divider(height: AppSpacing.lg),
        _buildTimeRow('Time Out Window', _timeOutStart, _timeOutEnd, (start, end) {
          setState(() {
            if (start != null) {
              _timeOutStart = start;
              final mins = int.tryParse(_timeOutLongevityController.text);
              if (mins != null) {
                _timeOutEnd = _calculateEndTime(start, mins);
              }
            }
            if (end != null) _timeOutEnd = end;
          });
        }),
      ] else ...[
        _buildSessionConfigCard(
          title: 'Morning',
          icon: Icons.wb_sunny_rounded,
          iconColor: AppColors.accent,
          enabled: _morningEnabled,
          onToggle: (v) => setState(() => _morningEnabled = v ?? false),
          timeInStart: _morningTimeInStart,
          timeInEnd: _morningTimeInEnd,
          timeOutStart: _morningTimeOutStart,
          timeOutEnd: _morningTimeOutEnd,
          onTimeInPicked: (start, end) {
            setState(() {
              if (start != null) {
                _morningTimeInStart = start;
                final mins = int.tryParse(_timeInLongevityController.text);
                if (mins != null) {
                  _morningTimeInEnd = _calculateEndTime(start, mins);
                }
              }
              if (end != null) _morningTimeInEnd = end;
            });
          },
          onTimeOutPicked: (start, end) {
            setState(() {
              if (start != null) {
                _morningTimeOutStart = start;
                final mins = int.tryParse(_timeOutLongevityController.text);
                if (mins != null) {
                  _morningTimeOutEnd = _calculateEndTime(start, mins);
                }
              }
              if (end != null) _morningTimeOutEnd = end;
            });
          },
        ),
        _buildSessionConfigCard(
          title: 'Afternoon',
          icon: Icons.light_mode_rounded,
          iconColor: const Color(0xFFF97316),
          enabled: _afternoonEnabled,
          onToggle: (v) => setState(() => _afternoonEnabled = v ?? false),
          timeInStart: _afternoonTimeInStart,
          timeInEnd: _afternoonTimeInEnd,
          timeOutStart: _afternoonTimeOutStart,
          timeOutEnd: _afternoonTimeOutEnd,
          onTimeInPicked: (start, end) {
            setState(() {
              if (start != null) {
                _afternoonTimeInStart = start;
                final mins = int.tryParse(_timeInLongevityController.text);
                if (mins != null) {
                  _afternoonTimeInEnd = _calculateEndTime(start, mins);
                }
              }
              if (end != null) _afternoonTimeInEnd = end;
            });
          },
          onTimeOutPicked: (start, end) {
            setState(() {
              if (start != null) {
                _afternoonTimeOutStart = start;
                final mins = int.tryParse(_timeOutLongevityController.text);
                if (mins != null) {
                  _afternoonTimeOutEnd = _calculateEndTime(start, mins);
                }
              }
              if (end != null) _afternoonTimeOutEnd = end;
            });
          },
        ),
        _buildSessionConfigCard(
          title: 'Evening',
          icon: Icons.nights_stay_rounded,
          iconColor: Colors.deepPurple,
          enabled: _eveningEnabled,
          onToggle: (v) => setState(() => _eveningEnabled = v ?? false),
          timeInStart: _eveningTimeInStart,
          timeInEnd: _eveningTimeInEnd,
          timeOutStart: _eveningTimeOutStart,
          timeOutEnd: _eveningTimeOutEnd,
          onTimeInPicked: (start, end) {
            setState(() {
              if (start != null) {
                _eveningTimeInStart = start;
                final mins = int.tryParse(_timeInLongevityController.text);
                if (mins != null) {
                  _eveningTimeInEnd = _calculateEndTime(start, mins);
                }
              }
              if (end != null) _eveningTimeInEnd = end;
            });
          },
          onTimeOutPicked: (start, end) {
            setState(() {
              if (start != null) {
                _eveningTimeOutStart = start;
                final mins = int.tryParse(_timeOutLongevityController.text);
                if (mins != null) {
                  _eveningTimeOutEnd = _calculateEndTime(start, mins);
                }
              }
              if (end != null) _eveningTimeOutEnd = end;
            });
          },
        ),
      ],
      
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
                  child: FlickrLoader(),
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

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
                child: !isMobile 
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildLeftFormFields(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildRightFormFields(),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._buildLeftFormFields(),
                          const SizedBox(height: AppSpacing.xl),
                          ..._buildRightFormFields(),
                        ],
                      ),
              ),
            ),
          ],
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

  Widget _buildSessionConfigCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool enabled,
    required ValueChanged<bool?> onToggle,
    required TimeOfDay? timeInStart,
    required TimeOfDay? timeInEnd,
    required TimeOfDay? timeOutStart,
    required TimeOfDay? timeOutEnd,
    required Function(TimeOfDay?, TimeOfDay?) onTimeInPicked,
    required Function(TimeOfDay?, TimeOfDay?) onTimeOutPicked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: enabled ? AppColors.white : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border,
          width: enabled ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: enabled ? AppColors.textDark : AppColors.textGrey,
                ),
              ),
              const Spacer(),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: AppSpacing.md),
            _buildTimeRow('Time In Window', timeInStart, timeInEnd, onTimeInPicked),
            const Divider(height: AppSpacing.lg),
            _buildTimeRow('Time Out Window', timeOutStart, timeOutEnd, onTimeOutPicked),
          ],
        ],
      ),
    );
  }

  TimeOfDay _calculateEndTime(TimeOfDay start, int longevityMinutes) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = startMinutes + longevityMinutes;
    final endHour = (endMinutes ~/ 60) % 24;
    final endMinute = endMinutes % 60;
    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  void _recalculateAllEndTimes() {
    final timeInMins = int.tryParse(_timeInLongevityController.text);
    final timeOutMins = int.tryParse(_timeOutLongevityController.text);

    setState(() {
      if (timeInMins != null) {
        if (_timeInStart != null) {
          _timeInEnd = _calculateEndTime(_timeInStart!, timeInMins);
        }
        if (_morningTimeInStart != null) {
          _morningTimeInEnd = _calculateEndTime(_morningTimeInStart!, timeInMins);
        }
        if (_afternoonTimeInStart != null) {
          _afternoonTimeInEnd = _calculateEndTime(_afternoonTimeInStart!, timeInMins);
        }
        if (_eveningTimeInStart != null) {
          _eveningTimeInEnd = _calculateEndTime(_eveningTimeInStart!, timeInMins);
        }
      }
      if (timeOutMins != null) {
        if (_timeOutStart != null) {
          _timeOutEnd = _calculateEndTime(_timeOutStart!, timeOutMins);
        }
        if (_morningTimeOutStart != null) {
          _morningTimeOutEnd = _calculateEndTime(_morningTimeOutStart!, timeOutMins);
        }
        if (_afternoonTimeOutStart != null) {
          _afternoonTimeOutEnd = _calculateEndTime(_afternoonTimeOutStart!, timeOutMins);
        }
        if (_eveningTimeOutStart != null) {
          _eveningTimeOutEnd = _calculateEndTime(_eveningTimeOutStart!, timeOutMins);
        }
      }
    });
  }
}
