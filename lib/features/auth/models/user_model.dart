import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.g.dart';
part 'user_model.freezed.dart';

@freezed
abstract class UserModel with _$UserModel {
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
    @Default([]) @JsonKey(name: 'organization_ids') List<String> organizationIds,
    /// Derived or primary role
    @Default('student') String role,
    @JsonKey(name: 'account_status') @Default('active') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'joined_at') DateTime? joinedAt,
    
    // Join fields (not in users table but useful for UI)
    String? facultyName,
    String? programName,
    String? campusName,
    String? facultyCode,
    String? programCode,
    @JsonKey(name: 'expired_at') DateTime? expiredAt,
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

  String get yearLevelDisplay {
    if (yearLevel == null || yearLevel == 0) return 'N/A';
    
    final n = yearLevel!;
    if (n >= 11 && n <= 13) {
      return '${n}th';
    }
    
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
