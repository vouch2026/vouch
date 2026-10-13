/// Question type constants for event surveys.
/// Stored in `event_survey_questions.question_type`.
class SurveyQuestionType {
  static const String star = 'star';
  static const String text = 'text';
  static const String singleChoice = 'single_choice';
  static const String yesNo = 'yes_no';

  static const List<String> all = [star, text, singleChoice, yesNo];

  static String label(String type) {
    switch (type) {
      case star:
        return 'Star rating';
      case text:
        return 'Text answer';
      case singleChoice:
        return 'Multiple choice';
      case yesNo:
        return 'Yes / No';
      default:
        return type;
    }
  }
}
