import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/event_model.dart';
import '../models/event_rating_model.dart';
import '../providers/event_provider.dart';

class EventRatingModal extends ConsumerStatefulWidget {
  final EventModel event;

  const EventRatingModal({super.key, required this.event});

  @override
  ConsumerState<EventRatingModal> createState() => _EventRatingModalState();
}

class _EventRatingModalState extends ConsumerState<EventRatingModal> {
  int _overallRating = 5;
  final _commentController = TextEditingController();
  final Map<String, int> _questionRatings = {};
  List<EventRatingQuestion> _questions = [];
  bool _isLoadingQuestions = true;
  bool _isSubmitting = false;

  final List<String> _emojiLabels = ['😡 Poor', '😕 Fair', '😐 Average', '🙂 Good', '😍 Excellent'];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final repo = ref.read(eventRepositoryProvider);
    final qList = await repo.getEventRatingQuestions(widget.event.id ?? '');
    setState(() {
      _questions = qList;
      for (var q in _questions) {
        if (q.id != null) {
          _questionRatings[q.id!] = 5;
        }
      }
      _isLoadingQuestions = false;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null || user.id == null || widget.event.id == null) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(eventRepositoryProvider);
      final comment = _commentController.text.trim();

      if (_questions.isEmpty) {
        await repo.submitEventRatingResponse(EventRatingResponse(
          eventId: widget.event.id!,
          studentId: user.id!,
          ratingValue: _overallRating,
          comment: comment.isEmpty ? null : comment,
        ));
      } else {
        for (var q in _questions) {
          if (q.id == null) continue;
          final ratingVal = _questionRatings[q.id!] ?? _overallRating;
          await repo.submitEventRatingResponse(EventRatingResponse(
            eventId: widget.event.id!,
            studentId: user.id!,
            questionId: q.id!,
            ratingValue: ratingVal,
            comment: comment.isEmpty ? null : comment,
          ));
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you! Your feedback has been submitted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rating: $e')),
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
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Evaluate Event',
                      style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                widget.event.name,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_isLoadingQuestions) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (_questions.isEmpty) ...[
                Text('Overall Event Rating', style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starVal = index + 1;
                    return IconButton(
                      iconSize: 36,
                      icon: Icon(
                        starVal <= _overallRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => _overallRating = starVal),
                    );
                  }),
                ),
              ] else ...[
                ..._questions.map((q) {
                  final currentVal = _questionRatings[q.id] ?? 5;
                  final isEmoji = q.questionType == 'emoji';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.questionText,
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        if (isEmoji) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(5, (idx) {
                              final val = idx + 1;
                              final isSelected = currentVal == val;
                              return ChoiceChip(
                                label: Text(_emojiLabels[idx]),
                                selected: isSelected,
                                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : Colors.black87,
                                ),
                                onSelected: (_) {
                                  setState(() => _questionRatings[q.id!] = val);
                                },
                              );
                            }),
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starVal = index + 1;
                              return IconButton(
                                iconSize: 32,
                                icon: Icon(
                                  starVal <= currentVal ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  setState(() => _questionRatings[q.id!] = starVal);
                                },
                              );
                            }),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: AppSpacing.md),
              Text('Additional Comments (Optional)', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts about this event...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submitRating,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Submit Evaluation', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
