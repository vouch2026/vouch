import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';

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
