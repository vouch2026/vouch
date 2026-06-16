import 'package:freezed_annotation/freezed_annotation.dart';

part 'campus_model.freezed.dart';
part 'campus_model.g.dart';

@freezed
abstract class CampusModel with _$CampusModel {
  const factory CampusModel({
    required String id,
    required String name,
    required String location,
    String? description,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @Default('active') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _CampusModel;

  factory CampusModel.fromJson(Map<String, dynamic> json) => _$CampusModelFromJson(json);
}
