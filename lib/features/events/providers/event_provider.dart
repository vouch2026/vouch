import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/utils/scope_obligation.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/storage_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/providers/connectivity_provider.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(SupabaseConfig.client);
});

final workspaceEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  
  if (org == null) return [];

  // School-based orgs (e.g. USC) resolve to scope_type `School`.
  final scope = await ref.watch(organizationScopeProvider(org).future);
  final scopeType = scope.scopeType;
  final scopeId = scope.scopeId;

  if (scopeId == null) return [];

  // AY|SEM history: default active, selectable via the sidebar. Past = view-only.
  final viewingTerm = await ref.watch(viewingTermProvider.future);
  final termId = viewingTerm?.id;

  final box = Hive.box('events');
  final cacheKey = 'workspace_events_${org.id}_${termId ?? 'all'}';
  final cached = box.get(cacheKey);

  // Fast path: if connectivity provider knows we are offline, load cached instantly
  final connectivity = ref.read(connectivityProvider).value;
  if (connectivity == false) {
    if (cached != null) {
      final cachedList = List<dynamic>.from(cached as List);
      return cachedList.map((json) {
        final jsonMap = Map<String, dynamic>.from(json as Map);
        return EventModel.fromJson(jsonMap);
      }).toList();
    }
    return [];
  }

  try {
    final events = await ref
        .watch(eventRepositoryProvider)
        .getEventsByScope(scopeType, scopeId, academicTermId: termId)
        .timeout(const Duration(seconds: 2));
    final eventsJson = events.map((e) => e.toJson()).toList();
    await box.put(cacheKey, eventsJson);
    for (final e in events) {
      if (e.id != null) {
        await box.put('event_${e.id}', e.toJson());
      }
    }
    return events;
  } catch (e) {
    if (cached != null) {
      final cachedList = List<dynamic>.from(cached as List);
      return cachedList.map((json) {
        final jsonMap = Map<String, dynamic>.from(json as Map);
        return EventModel.fromJson(jsonMap);
      }).toList();
    }
    rethrow;
  }
});

final allEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final viewingTerm = await ref.watch(viewingTermProvider.future);
  final termId = viewingTerm?.id;

  final box = Hive.box('events');
  final cacheKey = 'all_events_${termId ?? 'all'}';
  final cached = box.get(cacheKey);

  // Fast path: if connectivity provider knows we are offline, load cached instantly
  final connectivity = ref.read(connectivityProvider).value;
  if (connectivity == false) {
    if (cached != null) {
      final cachedList = List<dynamic>.from(cached as List);
      return cachedList.map((json) {
        final jsonMap = Map<String, dynamic>.from(json as Map);
        return EventModel.fromJson(jsonMap);
      }).toList();
    }
    return [];
  }

  try {
    final events = await ref
        .watch(eventRepositoryProvider)
        .getAllEvents(academicTermId: termId)
        .timeout(const Duration(seconds: 2));
    final eventsJson = events.map((e) => e.toJson()).toList();
    await box.put(cacheKey, eventsJson);
    return events;
  } catch (e) {
    if (cached != null) {
      final cachedList = List<dynamic>.from(cached as List);
      return cachedList.map((json) {
        final jsonMap = Map<String, dynamic>.from(json as Map);
        return EventModel.fromJson(jsonMap);
      }).toList();
    }
    rethrow;
  }
});

/// Explicitly obligated user ids for an event.
/// Empty list = legacy behavior (everyone in scope obligated) OR table missing.
final eventTargetsProvider =
    FutureProvider.family<List<String>, String>((ref, eventId) async {
  return ref.watch(eventRepositoryProvider).getEventTargets(eventId);
});

/// Combined obligation rule for one event (individuals + scope picks).
/// Legacy when neither table has rows.
final eventObligationProvider =
    FutureProvider.family<ObligationRule, String>((ref, eventId) async {
  return ref.watch(eventRepositoryProvider).getEventObligation(eventId);
});

/// Event ids the current user is obligated for: explicitly listed or via a
/// targeted scope unit they belong to.
/// Empty set = no targeted events (legacy untargeted events still obligate
/// everyone in scope — resolved by callers checking target-list emptiness).
final myObligatedEventIdsProvider = FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(userProfileProvider).value;
  if (user == null || user.id == null) return {};
  return ref.watch(eventRepositoryProvider).getObligatedEventIds(
        user.id!,
        campusId: user.campusId,
        facultyId: user.facultyId,
        programId: user.programId,
        yearLevel: user.yearLevel,
      );
});

final eventProvider = FutureProvider.family<EventModel?, String>((ref, id) async {
  final box = Hive.box('events');
  final cacheKey = 'event_$id';
  try {
    final event = await ref.watch(eventRepositoryProvider).getEventById(id);
    if (event != null) {
      await box.put(cacheKey, event.toJson());
    }
    return event;
  } catch (e) {
    final cached = box.get(cacheKey);
    if (cached != null) {
      final jsonMap = Map<String, dynamic>.from(cached as Map);
      return EventModel.fromJson(jsonMap);
    }
    rethrow;
  }
});

final eventHighlightsProvider = FutureProvider.family<int, String>((ref, eventId) async {
  final user = ref.watch(userProfileProvider).value;
  if (user == null || user.id == null) return 0;
  
  final bucket = dotenv.get('SUPABASE_HIGHLIGHTS_BUCKET', fallback: 'highlight-pictures');
  final folder = 'highlights/$eventId'; // Adjusted path to match upload
  
  try {
    final files = await ref.read(storageServiceProvider).listFiles(
      bucket: bucket,
      folder: folder,
    );
    
    // Filter files by userId in name if possible, or just return count for the folder 
    // actually uploadEventHighlight uses highlight_${eventId}_${userId}_${timestamp}
    final userFiles = files.where((f) => f.name.contains(user.id!)).toList();
    return userFiles.length;
  } catch (_) {
    return 0;
  }
});
