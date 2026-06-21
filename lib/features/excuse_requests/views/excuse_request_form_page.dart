import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loaders/flickr_loader.dart';
import '../../events/models/event_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../providers/excuse_provider.dart';

class ExcuseRequestFormPage extends ConsumerStatefulWidget {
  final EventModel event;

  const ExcuseRequestFormPage({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<ExcuseRequestFormPage> createState() => _ExcuseRequestFormPageState();
}

class _ExcuseRequestFormPageState extends ConsumerState<ExcuseRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedReasonType;
  XFile? _selectedFile;
  Uint8List? _selectedFileBytes;
  bool _isAcceptedTerms = false;
  bool _isSubmitting = false;

  final List<String> _reasonTypes = [
    'Medical Reason',
    'Family Emergency',
    'Official University Activity',
    'Academic Requirement',
    'Religious Activity',
    'Personal Emergency',
    'Others',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedFile = pickedFile;
          _selectedFileBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick document: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a supporting document as evidence.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (!_isAcceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please certify that the information you provided is true.'), backgroundColor: Colors.red),
      );
      return;
    }

    final user = ref.read(userProfileProvider).value;
    final term = ref.read(activeTermProvider).value;

    if (user == null || term == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile or academic term not loaded. Please try again.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final String reasonConcat = '[$_selectedReasonType] ${_reasonController.text.trim()}';

      await ref.read(excuseRepositoryProvider).submitExcuseRequest(
        studentId: user.id!,
        eventId: widget.event.id!,
        reason: reasonConcat,
        file: _selectedFile!,
        scopeType: widget.event.scopeType,
        scopeId: widget.event.scopeId,
        termId: term.id,
      );

      if (mounted) {
        // Refresh student excuse requests provider
        ref.invalidate(studentExcusesProvider(user.id!));
        ref.invalidate(studentEventExcuseProvider(widget.event.id!));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excuse request submitted successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit excuse request: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Excuse Request'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlickrLoader(),
                  const SizedBox(height: AppSpacing.md),
                  Text('Uploading evidence and submitting excuse...', style: AppTextStyles.bodyMedium),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Card Detail Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EVENT DETAILS',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(widget.event.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2.0),
                          Text(
                            'Location: ${widget.event.location}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Dropdown for Reason Type
                    Text('Reason Type *', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      value: _selectedReasonType,
                      decoration: InputDecoration(
                        hintText: 'Select reason category',
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      items: _reasonTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type, style: AppTextStyles.bodyMedium),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedReasonType = value);
                      },
                      validator: (value) => value == null ? 'Reason type is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Reason Details
                    Text('Reason Justification *', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Provide details on why you were absent from this event...',
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide explanation details';
                        }
                        if (value.trim().length < 10) {
                          return 'Explanation should be at least 10 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Evidence Upload Card
                    Text('Supporting Document / Evidence *', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.xs),
                    InkWell(
                      onTap: _pickDocument,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: _selectedFileBytes != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.memory(
                                      _selectedFileBytes!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.change_circle_outlined, color: Colors.white, size: 32),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          'Tap to change selection',
                                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          p.basename(_selectedFile!.path),
                                          style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_outlined, color: AppColors.primary.withOpacity(0.7), size: 48),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text('Upload Medical Certificate / Official Letter', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  const SizedBox(height: 2.0),
                                  Text('Supports JPG, JPEG, PNG formats (Max 5MB)', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Declaration Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isAcceptedTerms,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() => _isAcceptedTerms = val ?? false);
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'I certify that all details and supporting evidence uploaded here are authentic, true, and correct. I understand that submitting fake documents will invalidate this request and may result in disciplinary actions.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textDark, height: 1.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Bottom Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _submitRequest,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Submit Excuse Request',
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
    );
  }
}
