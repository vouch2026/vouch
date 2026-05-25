import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.g.dart';
part 'user_model.freezed.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    String? id, // public.users.id
    @JsonKey(name: 'auth_id') required String authId,
    required String email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'student_id_number') required String schoolId,
    @JsonKey(name: 'faculty_id') String? facultyId,
    @JsonKey(name: 'program_id') String? programId,
    @JsonKey(name: 'campus_id') String? campusId,
    @JsonKey(name: 'year') int? yearLevel,
    @JsonKey(name: 'profile_photo_url') String? avatarUrl,
    @JsonKey(name: 'id_front_url') String? idFrontUrl,
    @JsonKey(name: 'id_back_url') String? idBackUrl,
    @Default([]) @JsonKey(name: 'organization_ids') List<String> organizationIds,
    /// Derived or primary role
    @Default('student') String role,
    @Default('active') @JsonKey(name: 'account_status') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    
    // Join fields (not in users table but useful for UI)
    String? facultyName,
    String? programName,
  }) = _UserModel;

  const UserModel._();

  String get fullName => firstName != null || lastName != null 
    ? '${firstName ?? ''} ${lastName ?? ''}'.trim() 
    : 'Unknown User';

  String get roleDisplay {
    if (role == 'super_admin') return 'Super Admin';
    if (role == 'student') return 'Student';
    
    return role.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
