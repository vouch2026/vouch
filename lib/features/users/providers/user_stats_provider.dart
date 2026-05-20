import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats_model.dart';
import '../../../core/config/supabase_config.dart';

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final client = SupabaseConfig.client;
  
  try {
    // Query users and their roles from Supabase
    final response = await client.from('users').select('id, account_status, user_roles(roles(name))');
    final usersList = response as List;
    
    int totalUsers = usersList.length;
    int students = 0;
    int activeStudents = 0;
    int suspendedStudents = 0;
    int faculty = 0;
    int deans = 0;
    int programHeads = 0;
    int governance = 0;
    
    for (var user in usersList) {
      final roles = (user['user_roles'] as List?)?.map((ur) {
        final rolesMap = ur['roles'] as Map?;
        return rolesMap?['name'] as String? ?? '';
      }).toList() ?? [];
      
      final status = user['account_status'] as String? ?? 'active';
      
      // 1. Students Count
      if (roles.any((r) => r.toLowerCase() == 'students' || r.toLowerCase() == 'student')) {
        students++;
        if (status == 'active') activeStudents++;
        if (status == 'suspended') suspendedStudents++;
      }
      
      // 2. Faculty & Advisers Count
      // Criteria: Dean, Program Head, Adviser
      final isFaculty = roles.any((r) {
        final lr = r.toLowerCase();
        return lr.contains('dean') || lr.contains('program head') || lr.contains('adviser');
      });
      
      if (isFaculty) {
        faculty++;
        if (roles.any((r) => r.toLowerCase().contains('dean'))) deans++;
        if (roles.any((r) => r.toLowerCase().contains('program head'))) programHeads++;
      }
      
      // 3. Governance Roles Count
      // Criteria: Governor, Vice-Governor, Secretary, Treasurer, Staff
      final isGovernance = roles.any((r) {
        final lr = r.toLowerCase();
        return lr.contains('governor') || 
               lr.contains('secretary') || 
               lr.contains('treasurer') ||
               lr.contains('staff') ||
               lr.contains('officer') ||
               lr.contains('council member');
      });
      
      if (isGovernance) {
        governance++;
      }
    }
    
    return UserStatsModel(
      totalUsers: totalUsers,
      totalStudents: students,
      activeStudents: activeStudents,
      suspendedStudents: suspendedStudents,
      totalInstructors: faculty,
      deansCount: deans,
      programHeadsCount: programHeads,
      totalOfficers: governance,
      activeGovernanceAccounts: governance, // Simplified active count
      studentTrend: 0.0,
      instructorTrend: 0.0,
      governanceTrend: 0.0,
    );
  } catch (e) {
    // Fallback to empty data if there's an error
    return const UserStatsModel();
  }
});
