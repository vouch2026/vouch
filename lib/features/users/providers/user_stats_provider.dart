import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/utils/role_mapper.dart';

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final client = SupabaseConfig.client;
  
  try {
    // Fetch users with joins for user_roles
    final response = await client
        .from('users')
        .select('''
          id,
          account_status,
          user_roles:user_roles!user_roles_user_id_fkey(roles(name, hierarchy_level))
        ''');
        
    final usersList = response as List;
    
    int students = 0;
    int personnel = 0;
    int programHeads = 0;
    int deans = 0;
    int totalUsers = 0;
    
    for (var userData in usersList) {
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
      
      if (role == 'super_admin') {
        continue; // Skip super admins just like allUsersProvider
      }
      
      totalUsers++;
      
      if (role == 'student') {
        students++;
      } else if (role == 'personnel') {
        personnel++;
      } else if (role == 'program_head') {
        programHeads++;
      } else if (role == 'dean') {
        deans++;
      }
    }
    
    return UserStatsModel(
      totalUsers: totalUsers,
      totalStudents: students,
      totalInstructors: personnel,
      programHeadsCount: programHeads,
      deansCount: deans,
    );
  } catch (e) {
    // Fallback to empty data if there's an error
    return const UserStatsModel();
  }
});
