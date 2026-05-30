import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../models/event_rating_model.dart';
import '../repositories/event_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/storage_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(SupabaseConfig.client);
});

final workspaceEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  
  if (org == null) return [];
  
  final scopeType = org.type == 'campus-based' 
      ? 'Institutional' 
      : (org.type == 'faculty-based' ? 'Faculty' : 'Program');
  
  final scopeId = org.type == 'campus-based' 
      ? org.campusId 
      : (org.type == 'faculty-based' ? org.facultyId : org.programId);

  if (scopeId == null) return [];
  
  return ref.watch(eventRepositoryProvider).getEventsByScope(scopeType, scopeId);
});

final eventProvider = FutureProvider.family<EventModel?, String>((ref, id) async {
  return ref.watch(eventRepositoryProvider).getEventById(id);
});

final eventRatingsProvider = FutureProvider.family<List<EventRatingModel>, String>((ref, eventId) async {
  return ref.watch(eventRepositoryProvider).getRatingsForEvent(eventId);
});

final userEventRatingProvider = FutureProvider.family<EventRatingModel?, String>((ref, eventId) async {
  final user = ref.watch(userProfileProvider).value;
  if (user == null || user.id == null) return null;
  return ref.watch(eventRepositoryProvider).getUserRatingForEvent(eventId, user.id!);
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
