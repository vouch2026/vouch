import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    String? id,
    required String name,
    @JsonKey(name: 'event_date') required DateTime eventDate,
    @JsonKey(name: 'short_description') String? shortDescription,
    @JsonKey(name: 'full_description') String? fullDescription,
    @JsonKey(name: 'image_url') String? imageUrl,
    required String location,
    @JsonKey(name: 'time_in_start') required String timeInStart,
    @JsonKey(name: 'time_in_end') required String timeInEnd,
    @JsonKey(name: 'time_out_start') required String timeOutStart,
    @JsonKey(name: 'time_out_end') required String timeOutEnd,
    @JsonKey(name: 'scope_type') required String scopeType,
    @JsonKey(name: 'scope_id') required String scopeId,
    @JsonKey(name: 'is_mandatory') @Default(true) bool isMandatory,
    @JsonKey(name: 'academic_term_id') String? academicTermId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);
}
