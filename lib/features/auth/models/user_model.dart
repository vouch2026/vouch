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
    String? idFrontUrl,
    String? idBackUrl,
    @Default([]) List<String> organizationIds,
    /// Role of the user. See [UserRole] for possible values.
    /// Default roles include: super_admin, student, etc.
    @Default('student') String role,
    /// Status of the account. See [UserStatus] for possible values.
    /// Default statuses include: pending, approved, etc.
    @Default('pending') String status,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
