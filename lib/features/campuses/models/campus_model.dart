import 'package:freezed_annotation/freezed_annotation.dart';

part 'campus_model.freezed.dart';
part 'campus_model.g.dart';

@freezed
class CampusModel with _$CampusModel {
  const factory CampusModel({
    required String id,
    required String name,
    required String location,
    String? description,
    String? logoUrl,
    @Default('active') String status,
    DateTime? createdAt,
  }) = _CampusModel;

  factory CampusModel.fromJson(Map<String, dynamic> json) => _$CampusModelFromJson(json);
}
