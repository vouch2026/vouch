import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../events/models/event_model.dart';
import '../models/survey_model.dart';
import '../models/survey_question_model.dart';
import '../models/survey_question_type.dart';
import '../providers/event_feedback_provider.dart';

/// Officer-only page to build the post-event survey: create the survey,
/// add/reorder/delete questions, toggle required, open/close responses.
class SurveyBuilderPage extends ConsumerStatefulWidget {
  final EventModel event;

  const SurveyBuilderPage({super.key, required this.event});

  @override
  ConsumerState<SurveyBuilderPage> createState() => _SurveyBuilderPageState();
}

class _SurveyBuilderPageState extends ConsumerState<SurveyBuilderPage> {
  SurveyModel? _survey;
  List<SurveyQuestionModel> _questions = [];
  bool _loading = true;
  bool _busy = false;

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionsController = TextEditingController();
  String _newType = SurveyQuestionType.text;
  bool _newRequired = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final eventId = widget.event.id;
    if (eventId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(eventFeedbackRepositoryProvider);
      final survey = await repo.getSurveyByEvent(eventId);
      final questions = survey?.id == null
          ? <SurveyQuestionModel>[]
          : await repo.getQuestions(survey!.id!);
      if (mounted) {
        setState(() {
          _survey = survey;
          _questions = questions;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createSurvey() async {
    final eventId = widget.event.id;
    if (eventId == null) return;
    setState(() => _busy = true);
    try {
      final user = ref.read(userProfileProvider).value;
      final repo = ref.read(eventFeedbackRepositoryProvider);
      final survey = await repo.getOrCreateSurvey(
        eventId,
        createdByUserId: user?.id,
      );
      if (survey != null && mounted) {
        setState(() => _survey = survey);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Survey created. Add questions below.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleOpen(bool isOpen) async {
    if (_survey?.id == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(eventFeedbackRepositoryProvider)
          .setSurveyOpen(_survey!.id!, isOpen);
      setState(() => _survey = _survey!.copyWith(isOpen: isOpen));
      invalidateEventFeedback(ref, widget.event.id!);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addQuestion() async {
    final text = _questionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the question text.')),
      );
      return;
    }
    if (_survey?.id == null) return;
    List<String> options = [];
    if (_newType == SurveyQuestionType.singleChoice) {
      options = _optionsController.text
          .split(',')
          .map((o) => o.trim())
          .where((o) => o.isNotEmpty)
          .toList();
      if (options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Multiple choice needs at least 2 options (comma-separated).')),
        );
        return;
      }
    }
    setState(() => _busy = true);
    try {
      await ref.read(eventFeedbackRepositoryProvider).createQuestion(
            surveyId: _survey!.id!,
            questionText: text,
            questionType: _newType,
            options: options,
            isRequired: _newRequired,
            sortOrder: _questions.length,
          );
      _questionController.clear();
      _optionsController.clear();
      await _reload();
      invalidateEventFeedback(ref, widget.event.id!);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    setState(() => _busy = true);
    try {
      await ref.read(eventFeedbackRepositoryProvider).deleteQuestion(questionId);
      await _reload();
      invalidateEventFeedback(ref, widget.event.id!);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleRequired(SurveyQuestionModel question) async {
    try {
      await ref
          .read(eventFeedbackRepositoryProvider)
          .updateQuestion(question.copyWith(isRequired: !question.isRequired));
      await _reload();
      invalidateEventFeedback(ref, widget.event.id!);
    } catch (_) {}
  }

  Future<void> _moveQuestion(int index, int delta) async {
    final other = index + delta;
    if (other < 0 || other >= _questions.length) return;
    final surveyId = _survey?.id;
    if (surveyId == null) return;
    final reordered = List<SurveyQuestionModel>.from(_questions);
    final item = reordered.removeAt(index);
    reordered.insert(other, item);
    setState(() => _questions = reordered);
    await ref.read(eventFeedbackRepositoryProvider).reorderQuestions(
          surveyId,
          reordered.map((q) => q.id!).toList(),
        );
    invalidateEventFeedback(ref, widget.event.id!);
  }

  Future<void> _editQuestionText(SurveyQuestionModel question) async {
    final controller = TextEditingController(text: question.questionText);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit question'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Question text',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != question.questionText) {
      await ref
          .read(eventFeedbackRepositoryProvider)
          .updateQuestion(question.copyWith(questionText: result));
      await _reload();
      invalidateEventFeedback(ref, widget.event.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Event Survey',
      onBack: () {
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      child: _loading
          ? const Center(child: FlickrLoader())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.name,
                    style: AppTextStyles.headlineSmall
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Build the post-event survey students will answer in the Rate tab.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_survey == null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color:
                                AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.quiz_outlined,
                              size: 48, color: AppColors.primary),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No survey yet',
                            style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Students can already give a 1-5 star rating. Create a survey to add custom questions.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: _busy ? null : _createSurvey,
                              icon: const Icon(Icons.add_rounded),
                              label: Text(
                                _busy ? 'Creating...' : 'Create Survey',
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color:
                                AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _survey!.isOpen
                                      ? 'Survey open'
                                      : 'Survey closed',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _survey!.isOpen
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                Text(
                                  _survey!.isOpen
                                      ? 'Students see the questions in the Rate tab.'
                                      : 'Questions are hidden; star ratings still allowed.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _survey!.isOpen,
                            activeThumbColor: AppColors.primary,
                            onChanged: _busy ? null : _toggleOpen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Add question',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _questionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. What did you enjoy most?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.all(AppSpacing.md),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _newType,
                      decoration: InputDecoration(
                        labelText: 'Question type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: SurveyQuestionType.all
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(SurveyQuestionType.label(t)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _newType = value);
                      },
                    ),
                    if (_newType == SurveyQuestionType.singleChoice) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _optionsController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Options, comma-separated',
                          helperText:
                              'e.g. Excellent, Good, Fair, Poor',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.all(AppSpacing.md),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Checkbox(
                          value: _newRequired,
                          activeColor: AppColors.primary,
                          onChanged: (value) => setState(
                              () => _newRequired = value ?? true),
                        ),
                        const Text('Required question'),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: _busy ? null : _addQuestion,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add',
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Questions (${_questions.length})',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_questions.isEmpty)
                      Text(
                        'No questions yet. Add the first one above.',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.grey[600]),
                      ),
                    ...List.generate(_questions.length, (i) {
                      final q = _questions[i];
                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding:
                            const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary
                                  .withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${i + 1}. ${q.questionText}',
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${SurveyQuestionType.label(q.questionType)}${q.isRequired ? ' · Required' : ' · Optional'}${q.options.isNotEmpty ? ' · ${q.options.length} options' : ''}',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                            color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_upward_rounded,
                                  size: 18),
                              tooltip: 'Move up',
                              onPressed: i == 0
                                  ? null
                                  : () => _moveQuestion(i, -1),
                            ),
                            IconButton(
                              icon: const Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 18),
                              tooltip: 'Move down',
                              onPressed: i == _questions.length - 1
                                  ? null
                                  : () => _moveQuestion(i, 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18),
                              tooltip: 'Edit text',
                              onPressed: () => _editQuestionText(q),
                            ),
                            IconButton(
                              icon: Icon(
                                q.isRequired
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              tooltip: 'Toggle required',
                              onPressed: () => _toggleRequired(q),
                            ),
                            IconButton(
                              icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () => _deleteQuestion(q.id!),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ],
              ),
            ),
    );
  }
}
