import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement_model.dart';
import '../repositories/announcement_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(SupabaseConfig.client);
});

final workspaceAnnouncementsProvider = FutureProvider<List<AnnouncementModel>>((ref) async {
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
  
  return ref.watch(announcementRepositoryProvider).getAnnouncementsByScope(scopeType, scopeId);
});
