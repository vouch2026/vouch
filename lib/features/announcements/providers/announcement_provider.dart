import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/announcement_model.dart';
import '../repositories/announcement_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../../core/providers/connectivity_provider.dart';

import '../../academic_structure/providers/academic_context_provider.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(SupabaseConfig.client);
});

final workspaceAnnouncementsProvider = FutureProvider<List<AnnouncementModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  final selectedTerm = ref.watch(selectedAcademicTermProvider);
  
  if (org == null) return [];
  
  final isInstitutional = org.type == 'campus-based' || org.type == 'institutional';
  final isFaculty = org.type == 'faculty-based' || org.type == 'faculty';
  
  final scopeType = isInstitutional 
      ? 'Institutional' 
      : (isFaculty ? 'Faculty' : 'Program');
  
  final scopeId = isInstitutional 
      ? org.campusId 
      : (isFaculty ? org.facultyId : org.programId);

  if (scopeId == null) return [];

  final box = Hive.box('dashboard');
  final cacheKey = 'announcements_${scopeId}_${selectedTerm?.id ?? 'active'}';
  final cached = box.get(cacheKey);

  final connectivity = ref.read(connectivityProvider).value;
  if (connectivity == false) {
    if (cached != null) {
      final cachedList = List<dynamic>.from(cached as List);
      return cachedList.map((json) {
        final jsonMap = Map<String, dynamic>.from(json as Map);
        return AnnouncementModel.fromJson(jsonMap);
      }).toList();
    }
    return [];
  }

  try {
    final announcements = await ref.watch(announcementRepositoryProvider).getAnnouncementsByScope(scopeType, scopeId, termId: selectedTerm?.id);
    final jsonList = announcements.map((a) => a.toJson()).toList();
    await box.put(cacheKey, jsonList);
    return announcements;
  } catch (e) {
    if (cached != null) {
      final cachedList = List<dynamic>.from(cached as List);
      return cachedList.map((json) {
        final jsonMap = Map<String, dynamic>.from(json as Map);
        return AnnouncementModel.fromJson(jsonMap);
      }).toList();
    }
    rethrow;
  }
});

