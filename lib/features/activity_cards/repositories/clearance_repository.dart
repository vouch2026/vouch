import 'package:supabase_flutter/supabase_flutter.dart';

class ClearanceRepository {
  final SupabaseClient _client;

  ClearanceRepository(this._client);

  /// Checks if the student is eligible to request clearance for a specific scope.
  /// Enforces the hierarchy: Program -> Faculty -> Campus.
  Future<bool> isEligibleForClearance(String studentId, String scopeId, String scopeType, String termId) async {
    if (scopeType == 'Program') {
      return true; // Program is the base level
    }

    if (scopeType == 'Faculty') {
      // 1. Check if student has a Program clearance cleared for this term
      final clearanceResponse = await _client
          .from('activity_card_clearance_requests')
          .select('status')
          .eq('student_id', studentId)
          .eq('scope_type', 'Program')
          .eq('academic_term_id', termId)
          .eq('status', 'Cleared')
          .limit(1)
          .maybeSingle();
      
      if (clearanceResponse != null) return true;

      // 2. Check if student is an officer of any program-based organization for this term
      // Officers are exempt from needing a clearance card for their own level
      final officerResponse = await _client
          .from('organization_members')
          .select('id, roles!inner(hierarchy_level), organizations!inner(type)')
          .eq('user_id', studentId)
          .eq('academic_term_id', termId)
          .eq('organizations.type', 'program-based')
          .gt('roles.hierarchy_level', 5)
          .limit(1)
          .maybeSingle();

      return officerResponse != null;
    }

    if (scopeType == 'Institutional') {
      // 1. Check if student has a Faculty clearance cleared for this term
      final clearanceResponse = await _client
          .from('activity_card_clearance_requests')
          .select('status')
          .eq('student_id', studentId)
          .eq('scope_type', 'Faculty')
          .eq('academic_term_id', termId)
          .eq('status', 'Cleared')
          .limit(1)
          .maybeSingle();
      
      if (clearanceResponse != null) return true;

      // 2. Check if student is an officer of any faculty-based organization for this term
      final officerResponse = await _client
          .from('organization_members')
          .select('id, roles!inner(hierarchy_level), organizations!inner(type)')
          .eq('user_id', studentId)
          .eq('academic_term_id', termId)
          .eq('organizations.type', 'faculty-based')
          .gt('roles.hierarchy_level', 5)
          .limit(1)
          .maybeSingle();

      return officerResponse != null;
    }

    return false;
  }

  /// Submits a clearance request for a student.
  Future<void> requestClearance({
    required String studentId,
    required String organizationId,
    required String scopeId,
    required String scopeType,
    required String termId,
  }) async {
    final isEligible = await isEligibleForClearance(studentId, scopeId, scopeType, termId);
    if (!isEligible) {
      throw Exception('You must clear the lower hierarchy organization first.');
    }

    // Check if a request already exists
    final existingRequest = await _client
        .from('activity_card_clearance_requests')
        .select('id, status')
        .eq('student_id', studentId)
        .eq('organization_id', organizationId)
        .eq('academic_term_id', termId)
        .maybeSingle();

    if (existingRequest != null) {
      if (existingRequest['status'] == 'Pending' || existingRequest['status'] == 'Cleared') {
        throw Exception('A clearance request already exists for this organization.');
      }
      // If Rejected, we delete the old one to reset the signature workflow
      await _client.from('activity_card_clearance_requests').delete().eq('id', existingRequest['id']);
    }

    // Create the request
    final response = await _client.from('activity_card_clearance_requests').insert({
      'student_id': studentId,
      'organization_id': organizationId,
      'scope_id': scopeId,
      'scope_type': scopeType,
      'academic_term_id': termId,
      'status': 'Pending',
    }).select().single();

    final requestId = response['id'];

    // Identify required signatures based on roles and settings
    final orgResponse = await _client
        .from('organizations')
        .select('requires_adviser_signature')
        .eq('id', organizationId)
        .single();
    
    final bool requiresAdviser = orgResponse?['requires_adviser_signature'] ?? false;

    final rolesResponse = await _client.from('roles').select('id, name');
    final roles = rolesResponse as List;

    String getRoleId(String name) => roles.firstWhere((r) => r['name'] == name)['id'];

    List<Map<String, dynamic>> signatures = [
      {'clearance_request_id': requestId, 'required_role_id': getRoleId('Secretary'), 'required_scope_id': scopeId, 'status': 'Pending'},
      {'clearance_request_id': requestId, 'required_role_id': getRoleId('Treasurer'), 'required_scope_id': scopeId, 'status': 'Pending'},
    ];

    if (requiresAdviser) {
      signatures.add({'clearance_request_id': requestId, 'required_role_id': getRoleId('Instructor'), 'required_scope_id': scopeId, 'status': 'Pending'}); // Assuming Instructor role acts as Adviser
    }

    // Governor/President is always last
    String governorRole = scopeType == 'Institutional' ? 'Governor' : 'President';
    signatures.add({'clearance_request_id': requestId, 'required_role_id': getRoleId(governorRole), 'required_scope_id': scopeId, 'status': 'Pending'});

    await _client.from('activity_card_clearance_signatures').insert(signatures);
  }

  /// Signs a clearance slot.
  Future<void> signClearance({
    required String signatureId,
    required String userId,
    required String studentId,
    required String termId,
    String? remarks,
  }) async {
    // 1. Get signature details to check the role and scope
    final sigResponse = await _client
        .from('activity_card_clearance_signatures')
        .select('*, roles(name)')
        .eq('id', signatureId)
        .single();
    
    final roleData = sigResponse['roles'];
    final roleName = roleData is List ? roleData.first['name'] : roleData['name'];
    final scopeId = sigResponse['required_scope_id'];
    final requestId = sigResponse['clearance_request_id'];

    // 2. Enforce hierarchy for high-level officers
    if (roleName == 'Governor' || roleName == 'President') {
      // Find the organization for this scope to determine its type
      final orgResponse = await _client
          .from('organizations')
          .select('type')
          .or('program_id.eq.$scopeId,faculty_id.eq.$scopeId,campus_id.eq.$scopeId')
          .limit(1)
          .maybeSingle();
      
      final String? orgType = orgResponse?['type'];
      bool isEligible = true;

      if (orgType == 'faculty-based') {
        isEligible = await isEligibleForClearance(studentId, scopeId, 'Faculty', termId);
      } else if (orgType == 'campus-based') {
        isEligible = await isEligibleForClearance(studentId, scopeId, 'Institutional', termId);
      }

      if (!isEligible) {
        throw Exception('Student must clear the lower hierarchy organization first.');
      }
    }

    // 3. Update the signature
    await _client.from('activity_card_clearance_signatures').update({
      'status': 'Signed',
      'signed_by_user_id': userId,
      'signed_at': DateTime.now().toIso8601String(),
      'remarks': remarks,
    }).eq('id', signatureId);

    // 4. Check if fully signed
    final allSignatures = await _client
        .from('activity_card_clearance_signatures')
        .select('status')
        .eq('clearance_request_id', requestId);
    
    final isFullySigned = (allSignatures as List).every((s) => s['status'] == 'Signed');

    if (isFullySigned) {
      await _client.from('activity_card_clearance_requests').update({
        'status': 'Cleared',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', requestId);
    }
  }

  /// Rejects a clearance slot.
  Future<void> rejectClearance({
    required String signatureId,
    required String userId,
    required String remarks,
  }) async {
    await _client.from('activity_card_clearance_signatures').update({
      'status': 'Rejected',
      'signed_by_user_id': userId,
      'signed_at': DateTime.now().toIso8601String(),
      'remarks': remarks,
    }).eq('id', signatureId);

    // Get the request ID
    final signatureResponse = await _client
        .from('activity_card_clearance_signatures')
        .select('clearance_request_id')
        .eq('id', signatureId)
        .single();
    
    final requestId = signatureResponse['clearance_request_id'];

    // Mark the entire request as Rejected
    await _client.from('activity_card_clearance_requests').update({
      'status': 'Rejected',
    }).eq('id', requestId);
  }
}
