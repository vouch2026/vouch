import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/user_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/utils/role_mapper.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../auth/providers/auth_provider.dart';

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final client = SupabaseConfig.client;
  
  // Fetch users with joins for campus, faculty, program, and roles
  final response = await client
      .from('users')
      .select('''
        *,
        campuses:campus_id(name),
        faculties:faculty_id(name, code),
        programs:program_id(name, code),
        user_roles:user_roles!user_roles_user_id_fkey(roles(name, hierarchy_level))
      ''');
  
  final users = (response as List).map((data) {
    final userData = Map<String, dynamic>.from(data);
    
    // Flatten campus, faculty and program names/codes
    if (userData['campuses'] != null) {
      userData['campusName'] = userData['campuses']['name'];
    }
    if (userData['faculties'] != null) {
      userData['facultyName'] = userData['faculties']['name'];
      userData['facultyCode'] = userData['faculties']['code'];
    }
    if (userData['programs'] != null) {
      userData['programName'] = userData['programs']['name'];
      userData['programCode'] = userData['programs']['code'];
    }
    
    // Handle role extraction (highest hierarchy level)
    final userRoles = userData['user_roles'] as List?;
    String role = 'student';
    if (userRoles != null && userRoles.isNotEmpty) {
      final sortedRoles = List.from(userRoles);
      sortedRoles.sort((a, b) {
        final rolesA = a['roles'] as Map?;
        final rolesB = b['roles'] as Map?;
        if (rolesA == null || rolesB == null) return 0;
        final levelA = (rolesA['hierarchy_level'] as num?)?.toInt() ?? 0;
        final levelB = (rolesB['hierarchy_level'] as num?)?.toInt() ?? 0;
        return levelB.compareTo(levelA);
      });
      
      final topRole = sortedRoles.first['roles'] as Map?;
      if (topRole != null) {
        role = RoleMapper.mapDbRoleToAppFormat(topRole['name'] as String);
      }
    }
    userData['role'] = role;
    
    return UserModel.fromJson(userData);
  }).where((user) => user.role != 'super_admin').toList();
  
  final activeRole = ref.watch(workspaceProvider).activeRole;
  final userProfile = ref.watch(userProfileProvider).value;
  
  if (activeRole != null && userProfile != null) {
    final roleKey = RoleMapper.mapDbRoleToAppFormat(activeRole.roleName);
    if (roleKey == 'program_head') {
      final programId = userProfile.programId;
      if (programId == null) return [];
      return users.where((u) => u.programId == programId && u.role == 'student').toList();
    } else if (roleKey == 'dean') {
      final facultyId = userProfile.facultyId;
      if (facultyId == null) return [];
      return users.where((u) => u.facultyId == facultyId && u.role == 'student').toList();
    }
  }
  
  return users;
});
