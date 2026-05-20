import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/user_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/utils/role_mapper.dart';

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final client = SupabaseConfig.client;
  
  // Fetch users with joins for faculty, program, and roles
  final response = await client
      .from('users')
      .select('''
        *,
        faculties:faculty_id(name),
        programs:program_id(name),
        user_roles:user_roles!user_roles_user_id_fkey(roles(name, hierarchy_level))
      ''');
  
  final users = (response as List).map((data) {
    final userData = Map<String, dynamic>.from(data);
    
    // Flatten faculty and program names
    if (userData['faculties'] != null) {
      userData['facultyName'] = userData['faculties']['name'];
    }
    if (userData['programs'] != null) {
      userData['programName'] = userData['programs']['name'];
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
  }).toList();
  
  return users;
});
