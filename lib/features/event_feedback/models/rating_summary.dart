import 'survey_response_model.dart';

/// Aggregated rating for one event, computed client-side from responses.
class RatingSummary {
  final String eventId;
  final double average;
  final int count;
  /// star (1-5) -> response count
  final Map<int, int> breakdown;

  const RatingSummary({
    required this.eventId,
    required this.average,
    required this.count,
    required this.breakdown,
  });

  factory RatingSummary.empty(String eventId) => RatingSummary(
        eventId: eventId,
        average: 0,
        count: 0,
        breakdown: const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );

  factory RatingSummary.fromResponses(
      String eventId, List<SurveyResponseModel> responses) {
    if (responses.isEmpty) return RatingSummary.empty(eventId);
    final breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    var sum = 0;
    for (final r in responses) {
      final rating = r.overallRating.clamp(1, 5);
      breakdown[rating] = (breakdown[rating] ?? 0) + 1;
      sum += rating;
    }
    return RatingSummary(
      eventId: eventId,
      average: sum / responses.length,
      count: responses.length,
      breakdown: breakdown,
    );
  }

  /// star (1-5) -> percentage 0-100
  int percentFor(int star) {
    if (count == 0) return 0;
    return (((breakdown[star] ?? 0) / count) * 100).round();
  }
}
