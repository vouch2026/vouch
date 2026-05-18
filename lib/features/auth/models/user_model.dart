import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.g.dart';
part 'user_model.freezed.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @JsonKey(name: 'auth_id') required String id,
    required String email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'student_id_number') String? schoolId,
    @JsonKey(name: 'faculty_id') String? faculty,
    @JsonKey(name: 'program_id') String? program,
    @JsonKey(name: 'year') int? yearLevel,
    @JsonKey(name: 'profile_photo_url') String? avatarUrl,
    @JsonKey(name: 'id_front_url') String? idFrontUrl,
    @JsonKey(name: 'id_back_url') String? idBackUrl,
    @Default([]) @JsonKey(name: 'organization_ids') List<String> organizationIds,
    /// Role of the user. See [UserRole] for possible values.
    /// Default roles include: super_admin, student, etc.
    @Default('student') String role,
    /// Status of the account. See [UserStatus] for possible values.
    /// Default statuses include: pending, approved, etc.
    @Default('active') @JsonKey(name: 'account_status') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _UserModel;

  const UserModel._();

  String get fullName => '$firstName $lastName'.trim();

  String get roleDisplay {
    if (role == 'super_admin') return 'Super Admin';
    if (role == 'student') return 'Student';
    
    // Convert snake_case to Title Case (e.g., comselec_chairman -> Comselec Chairman)
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
