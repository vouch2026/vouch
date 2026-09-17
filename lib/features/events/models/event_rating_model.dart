class EventRatingQuestion {
  final String? id;
  final String eventId;
  final String questionText;
  final String questionType; // 'star' or 'emoji'
  final int orderIndex;

  const EventRatingQuestion({
    this.id,
    required this.eventId,
    required this.questionText,
    required this.questionType,
    this.orderIndex = 0,
  });

  factory EventRatingQuestion.fromJson(Map<String, dynamic> json) {
    return EventRatingQuestion(
      id: json['id'] as String?,
      eventId: json['event_id'] as String,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String? ?? 'star',
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'event_id': eventId,
      'question_text': questionText,
      'question_type': questionType,
      'order_index': orderIndex,
    };
  }
}

class EventRatingResponse {
  final String? id;
  final String eventId;
  final String studentId;
  final String? questionId;
  final int ratingValue; // 1 to 5
  final String? comment;
  final DateTime? createdAt;

  const EventRatingResponse({
    this.id,
    required this.eventId,
    required this.studentId,
    this.questionId,
    required this.ratingValue,
    this.comment,
    this.createdAt,
  });

  factory EventRatingResponse.fromJson(Map<String, dynamic> json) {
    return EventRatingResponse(
      id: json['id'] as String?,
      eventId: json['event_id'] as String,
      studentId: json['student_id'] as String,
      questionId: json['question_id'] as String?,
      ratingValue: json['rating_value'] as int,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'event_id': eventId,
      'student_id': studentId,
      'question_id': questionId,
      'rating_value': ratingValue,
      'comment': comment,
    };
  }
}

class EventRatingSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // 1: count, 2: count, ... 5: count
  final List<String> comments;

  const EventRatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.comments,
  });
}
