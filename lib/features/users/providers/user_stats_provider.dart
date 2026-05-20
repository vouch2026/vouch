import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats_model.dart';
import '../../../core/config/supabase_config.dart';

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final client = SupabaseConfig.client;
  
  try {
    // Let's use a simpler approach for the prototype: query the users and their roles
    final usersWithRoles = await client.from('users').select('id, account_status, user_roles(roles(name))');
    
    int students = 0;
    int activeStudents = 0;
    int suspendedStudents = 0;
    int faculty = 0;
    int deans = 0;
    int programHeads = 0;
    int governance = 0;
    
    for (var user in (usersWithRoles as List)) {
      final roles = (user['user_roles'] as List?)?.map((ur) => (ur['roles'] as Map)['name'] as String).toList() ?? [];
      final status = user['account_status'] as String? ?? 'active';
      
      if (roles.contains('Students')) {
        students++;
        if (status == 'active') activeStudents++;
        if (status == 'suspended') suspendedStudents++;
      }
      
      if (roles.contains('Faculty Dean') || roles.contains('Program Head') || roles.contains('Adviser')) {
        faculty++;
        if (roles.contains('Faculty Dean')) deans++;
        if (roles.contains('Program Head')) programHeads++;
      }
      
      if (roles.any((r) => r.contains('Governor') || r.contains('Secretary') || r.contains('Treasurer'))) {
        governance++;
      }
    }
    
    return UserStatsModel(
      totalStudents: students,
      activeStudents: activeStudents,
      suspendedStudents: suspendedStudents,
      totalInstructors: faculty,
      deansCount: deans,
      programHeadsCount: programHeads,
      totalOfficers: governance,
      activeGovernanceAccounts: governance, // Simplified
      studentTrend: 0.0,
      instructorTrend: 0.0,
      governanceTrend: 0.0,
    );
  } catch (e) {
    // Fallback to empty data if there's an error
    return const UserStatsModel(
      totalStudents: 0,
      totalInstructors: 0,
      totalOfficers: 0,
    );
  }
});
