import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_filter_model.freezed.dart';

@freezed
class UserFilterModel with _$UserFilterModel {
  const factory UserFilterModel({
    String? searchQuery,
    String? campusId,
    String? facultyId,
    String? programId,
    String? status,
    int? yearLevel,
    String? position,
    String? role,
    DateTime? startDate,
    DateTime? endDate,
    @Default('name') String sortBy,
    @Default(true) bool ascending,
  }) = _UserFilterModel;
}
