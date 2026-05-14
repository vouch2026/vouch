import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.g.dart';
part 'user_model.freezed.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? fullName,
    String? schoolId,
    String? faculty,
    String? program,
    int? yearLevel,
    String? avatarUrl,
    @Default([]) List<String> organizationIds,
    @Default('student') String role,
    @Default('pending') String status,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
