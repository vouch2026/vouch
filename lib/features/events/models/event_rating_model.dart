class EventRatingModel {
  final String eventId;
  final String userId;
  final int rating;
  final String? comment;

  const EventRatingModel({
    required this.eventId,
    required this.userId,
    required this.rating,
    this.comment,
  });
}
