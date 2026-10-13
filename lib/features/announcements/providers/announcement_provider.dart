import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/announcement_model.dart';
import '../repositories/announcement_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../../core/providers/connectivity_provider.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(SupabaseConfig.client);
});

final workspaceAnnouncementsProvider = FutureProvider<List<AnnouncementModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  
  if (org == null) return [];

  // School-based orgs (e.g. USC) resolve to scope_type `School`.
  final scope = await ref.watch(organizationScopeProvider(org).future);
  if (scope.scopeId == null) return [];
  final scopeType = scope.scopeType;
  final scopeId = scope.scopeId!;

  // AY|SEM history: default active, selectable via the sidebar. Past = view-only.
  final viewingTerm = await ref.watch(viewingTermProvider.future);
  final termId = viewingTerm?.id;

  final box = Hive.box('dashboard');
  final cacheKey = 'announcements_${scopeId}_${termId ?? 'all'}';
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
    final announcements = await ref.watch(announcementRepositoryProvider).getAnnouncementsByScope(scopeType, scopeId, academicTermId: termId);
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

