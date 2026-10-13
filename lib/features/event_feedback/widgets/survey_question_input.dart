import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/survey_question_model.dart';
import '../models/survey_question_type.dart';
import 'star_rating_input.dart';

/// Mutable answer draft for one survey question, owned by the parent form.
class SurveyAnswerValue {
  final String? text;
  final String? option;
  final bool? boolValue;
  final int? rating;

  const SurveyAnswerValue({this.text, this.option, this.boolValue, this.rating});

  SurveyAnswerValue copyWith({
    String? text,
    String? option,
    bool? boolValue,
    int? rating,
  }) {
    return SurveyAnswerValue(
      text: text ?? this.text,
      option: option ?? this.option,
      boolValue: boolValue ?? this.boolValue,
      rating: rating ?? this.rating,
    );
  }

  bool get isAnswered {
    return (text != null && text!.trim().isNotEmpty) ||
        (option != null && option!.isNotEmpty) ||
        boolValue != null ||
        (rating != null && rating! > 0);
  }
}

/// Renders the input for one [SurveyQuestionModel] based on its type.
class SurveyQuestionInput extends StatelessWidget {
  final SurveyQuestionModel question;
  final SurveyAnswerValue value;
  final ValueChanged<SurveyAnswerValue> onChanged;
  final int index;

  const SurveyQuestionInput({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '${index + 1}. ${question.questionText}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (question.isRequired)
              Text(
                ' *',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        switch (question.questionType) {
          SurveyQuestionType.star => StarRatingInput(
              rating: value.rating ?? 0,
              onChanged: (star) => onChanged(value.copyWith(rating: star)),
            ),
          SurveyQuestionType.text => TextFormField(
              initialValue: value.text,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type your answer here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
              onChanged: (text) => onChanged(
                SurveyAnswerValue(
                  text: text,
                  option: value.option,
                  boolValue: value.boolValue,
                  rating: value.rating,
                ),
              ),
            ),
          SurveyQuestionType.singleChoice => RadioGroup<String>(
              groupValue: value.option,
              onChanged: (selected) {
                if (selected == null) return;
                onChanged(value.copyWith(option: selected));
              },
              child: Column(
                children: question.options.map((option) {
                  return RadioListTile<String>(
                    value: option,
                    title: Text(option, style: AppTextStyles.bodyMedium),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }).toList(),
              ),
            ),
          SurveyQuestionType.yesNo => RadioGroup<bool>(
              groupValue: value.boolValue,
              onChanged: (selected) {
                if (selected == null) return;
                onChanged(value.copyWith(boolValue: selected));
              },
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      value: true,
                      title: const Text('Yes'),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      value: false,
                      title: const Text('No'),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          _ => Text(
              'Unsupported question type: ${question.questionType}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
            ),
        },
      ],
    );
  }
}
