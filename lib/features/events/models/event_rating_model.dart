import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_rating_model.freezed.dart';
part 'event_rating_model.g.dart';

@freezed
class EventRatingModel with _$EventRatingModel {
  const factory EventRatingModel({
    String? id,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'user_id') required String userId,
    required int rating,
    String? comment,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _EventRatingModel;

  factory EventRatingModel.fromJson(Map<String, dynamic> json) => _$EventRatingModelFromJson(json);
}
