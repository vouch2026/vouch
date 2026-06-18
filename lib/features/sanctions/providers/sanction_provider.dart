import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../models/sanction_model.dart';
import '../models/compliance_member_model.dart';
import '../repositories/sanction_repository.dart';
import '../../auth/providers/auth_provider.dart';

final sanctionRepositoryProvider = Provider<SanctionRepository>((ref) {
  return SanctionRepository(SupabaseConfig.client);
});

final workspaceSanctionsProvider = FutureProvider<List<SanctionModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final term = ref.watch(activeTermProvider).value;
  final org = workspace.selectedOrganization;

  if (org == null || term == null) return [];

  final repository = ref.watch(sanctionRepositoryProvider);
  return repository.getWorkspaceSanctions(org.id, term.id);
});

final mySanctionsProvider = FutureProvider<List<SanctionModel>>((ref) async {
  final userProfile = await ref.watch(userProfileProvider.future);
  final term = await ref.watch(activeTermProvider.future);

  if (userProfile == null || userProfile.id == null || term == null) {
    debugPrint('mySanctionsProvider: Missing dependencies. profile: ${userProfile?.id}, term: ${term?.id}');
    return [];
  }

  debugPrint('mySanctionsProvider: Fetching all sanctions for student ${userProfile.id}, term ${term.id}');

  final repository = ref.watch(sanctionRepositoryProvider);
  // Fetching all sanctions for the student in the current term, regardless of workspace
  return repository.getMySanctions(userProfile.id!, termId: term.id);
});

final workspaceComplianceProvider = FutureProvider<List<ComplianceMemberModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final term = ref.watch(activeTermProvider).value;
  final org = workspace.selectedOrganization;

  if (org == null || term == null) return [];

  String? scopeId = org.campusId;
  String scopeType = 'Institutional';
  if (org.type == 'faculty-based') {
    scopeId = org.facultyId;
    scopeType = 'Faculty';
  } else if (org.type == 'program-based') {
    scopeId = org.programId;
    scopeType = 'Program';
  }

  if (scopeId == null) return [];

  final repository = ref.watch(sanctionRepositoryProvider);
  return repository.getOrganizationCompliance(
    orgId: org.id,
    termId: term.id,
    scopeId: scopeId,
    scopeType: scopeType,
  );
});

final studentSanctionsAttendanceProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, studentId) async {
  final workspace = ref.watch(workspaceProvider);
  final term = ref.watch(activeTermProvider).value;
  final org = workspace.selectedOrganization;

  if (org == null || term == null) return [];

  String? scopeId = org.campusId;
  String scopeType = 'Institutional';
  if (org.type == 'faculty-based') {
    scopeId = org.facultyId;
    scopeType = 'Faculty';
  } else if (org.type == 'program-based') {
    scopeId = org.programId;
    scopeType = 'Program';
  }

  if (scopeId == null) return [];

  final repository = ref.watch(sanctionRepositoryProvider);
  return repository.getStudentAttendanceForSanctions(
    studentId: studentId,
    termId: term.id,
    scopeId: scopeId,
    scopeType: scopeType,
  );
});

final studentSanctionRecordProvider = FutureProvider.family<SanctionModel?, String>((ref, studentId) async {
  final workspace = ref.watch(workspaceProvider);
  final term = ref.watch(activeTermProvider).value;
  final org = workspace.selectedOrganization;

  if (org == null || term == null) return null;

  final repository = ref.watch(sanctionRepositoryProvider);
  return repository.getStudentSanctionRecord(
    studentId: studentId,
    termId: term.id,
    scopeId: org.id,
  );
});

final sanctionRulesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final term = ref.watch(activeTermProvider).value;
  final org = workspace.selectedOrganization;

  if (org == null || term == null) return [];

  final client = SupabaseConfig.client;
  final response = await client
      .from('sanction_rules')
      .select()
      .eq('scope_id', org.id)
      .eq('academic_term_id', term.id)
      .order('min_absence', ascending: true);

  return List<Map<String, dynamic>>.from(response);
});

final workspaceMandatoryEventsCountProvider = FutureProvider<int>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final term = ref.watch(activeTermProvider).value;
  final org = workspace.selectedOrganization;

  if (org == null || term == null) return 0;

  String? scopeId = org.campusId;
  String scopeType = 'Institutional';
  if (org.type == 'faculty-based') {
    scopeId = org.facultyId;
    scopeType = 'Faculty';
  } else if (org.type == 'program-based') {
    scopeId = org.programId;
    scopeType = 'Program';
  }

  if (scopeId == null) return 0;

  final client = SupabaseConfig.client;
  final response = await client
      .from('events')
      .select('id')
      .eq('scope_id', scopeId)
      .eq('scope_type', scopeType)
      .eq('academic_term_id', term.id)
      .eq('is_mandatory', true);

  return (response as List).length;
});

