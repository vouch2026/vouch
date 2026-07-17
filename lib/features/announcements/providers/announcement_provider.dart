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
  
  final isInstitutional = org.type == 'campus-based' || org.type == 'institutional';
  final isFaculty = org.type == 'faculty-based' || org.type == 'faculty';
  
  final scopeType = isInstitutional 
      ? 'Institutional' 
      : (isFaculty ? 'Faculty' : 'Program');
  
  final scopeId = isInstitutional 
      ? org.campusId 
      : (isFaculty ? org.facultyId : org.programId);

  if (scopeId == null) return [];
  
  return ref.watch(announcementRepositoryProvider).getAnnouncementsByScope(scopeType, scopeId);
});
