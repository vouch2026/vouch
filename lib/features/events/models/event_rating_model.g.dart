// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventRatingModelImpl _$$EventRatingModelImplFromJson(
  Map<String, dynamic> json,
) => _$EventRatingModelImpl(
  id: json['id'] as String?,
  eventId: json['event_id'] as String,
  userId: json['user_id'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$EventRatingModelImplToJson(
  _$EventRatingModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'event_id': instance.eventId,
  'user_id': instance.userId,
  'rating': instance.rating,
  'comment': instance.comment,
  'created_at': instance.createdAt?.toIso8601String(),
};
