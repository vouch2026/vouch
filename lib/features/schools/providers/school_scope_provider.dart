import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/models/user_model.dart';
import '../../users/providers/users_provider.dart';

/// campusId -> schoolId mapping from raw campus rows.
/// Typed CampusModel carries no schoolId yet, so scope UIs use this map to
/// filter campuses by school. Empty map on old DBs (no column) = no filtering.
final campusSchoolMapProvider =
    FutureProvider<Map<String, String>>((ref) async {
  try {
    final response = await SupabaseConfig.client
        .from('campuses')
        .select('id, school_id');
    final map = <String, String>{};
    for (final row in (response as List)) {
      final m = Map<String, dynamic>.from(row as Map);
      final id = m['id'] as String?;
      final schoolId = m['school_id'] as String?;
      if (id != null && schoolId != null) map[id] = schoolId;
    }
    return map;
  } catch (_) {
    return {};
  }
});

/// Users visible in a scope, for the member multi-select picker.
/// - School scope: all users whose campus maps to the school (falls back to
///   ALL users when no campus-school mapping exists, e.g. old DB / single
///   school DORSU where every campus belongs to it).
/// - Institutional: users with campusId == scopeId (faculty-derived included,
///   matching allUsersProvider's derivation).
/// - Faculty/Program: direct id match.
final usersInScopeProvider = FutureProvider.family<List<UserModel>,
    ({String scopeType, String scopeId})>((ref, scope) async {
  final users = await ref.watch(allUsersProvider.future);
  switch (scope.scopeType) {
    case 'School':
      final map = await ref.watch(campusSchoolMapProvider.future);
      if (map.isEmpty) return users;
      return users
          .where((u) =>
              u.campusId != null && map[u.campusId] == scope.scopeId)
          .toList();
    case 'Institutional':
      return users.where((u) => u.campusId == scope.scopeId).toList();
    case 'Faculty':
      return users.where((u) => u.facultyId == scope.scopeId).toList();
    case 'Program':
      return users.where((u) => u.programId == scope.scopeId).toList();
    default:
      return users;
  }
});
