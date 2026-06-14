import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/event_model.dart';
import '../models/event_rating_model.dart';
import '../providers/event_provider.dart';
import '../../auth/providers/auth_provider.dart';

class StudentRateEventCard extends ConsumerStatefulWidget {
  final EventModel event;

  const StudentRateEventCard({super.key, required this.event});

  @override
  ConsumerState<StudentRateEventCard> createState() => _StudentRateEventCardState();
}

class _StudentRateEventCardState extends ConsumerState<StudentRateEventCard> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isHovered = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(userProfileProvider).value;
      if (user == null || user.id == null) return;

      final rating = EventRatingModel(
        eventId: widget.event.id!,
        userId: user.id!,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      await ref.read(eventRepositoryProvider).submitRating(rating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );
        ref.invalidate(userEventRatingProvider(widget.event.id!));
        ref.invalidate(eventRatingsProvider(widget.event.id!));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rating: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRatingAsync = ref.watch(userEventRatingProvider(widget.event.id!));
    final allRatingsAsync = ref.watch(eventRatingsProvider(widget.event.id!));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered 
                ? AppColors.primary.withValues(alpha: 0.3) 
                : AppColors.primary.withValues(alpha: 0.1),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.06),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.name,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat.yMMMMd().format(widget.event.eventDate),
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                allRatingsAsync.when(
                  data: (ratings) {
                    final avg = ratings.isEmpty ? 0.0 : ratings.map((r) => r.rating).reduce((a, b) => a + b) / ratings.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              avg.toStringAsFixed(1),
                              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text('${ratings.length} reviews', style: AppTextStyles.labelSmall.copyWith(color: Colors.grey)),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            userRatingAsync.when(
              data: (userRating) {
                if (userRating != null) {
                  return _buildSubmittedState(userRating);
                }
                return _buildRatingForm();
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildRatingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How was your experience?',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final rating = index + 1;
            return IconButton(
              onPressed: () => setState(() => _selectedRating = rating),
              icon: Icon(
                _selectedRating >= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: _selectedRating >= rating ? Colors.amber : Colors.grey[400],
                size: 32,
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _commentController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Share your thoughts (optional)',
            hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submitRating,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                  )
                : Text(
                    'Submit Feedback',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittedState(EventRatingModel rating) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                'You already rated this event',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: index < rating.rating ? Colors.amber : Colors.grey[300],
                size: 16,
              );
            }),
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              rating.comment!,
              style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
