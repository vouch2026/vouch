import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/storage_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/providers/connectivity_provider.dart';

import '../../academic_structure/providers/academic_context_provider.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(SupabaseConfig.client);
});

final workspaceEventsProvider = FutureProvider<List<EventModel>>((ref) async {
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
  
  final box = Hive.box('events');
  final cacheKey = 'workspace_events_${org.id}_${selectedTerm?.id ?? 'active'}';
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
        .getEventsByScope(scopeType, scopeId, termId: selectedTerm?.id)
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
  final box = Hive.box('events');
  const cacheKey = 'all_events';
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
        .getAllEvents()
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
