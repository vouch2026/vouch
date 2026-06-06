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
      // Check if student has a Program clearance cleared for this term
      // We find the program_id associated with this student and faculty
      final studentResponse = await _client
          .from('users')
          .select('program_id')
          .eq('id', studentId)
          .single();
      
      final programId = studentResponse['program_id'];
      if (programId == null) return true; // No program assigned, maybe irregular

      final clearanceResponse = await _client
          .from('activity_card_clearance_requests')
          .select('status')
          .eq('student_id', studentId)
          .eq('scope_id', programId)
          .eq('academic_term_id', termId)
          .maybeSingle();
      
      return clearanceResponse != null && clearanceResponse['status'] == 'Cleared';
    }

    if (scopeType == 'Institutional') {
      // Check if student has a Faculty clearance cleared for this term
      final studentResponse = await _client
          .from('users')
          .select('faculty_id')
          .eq('id', studentId)
          .single();
      
      final facultyId = studentResponse['faculty_id'];
      if (facultyId == null) return true;

      final clearanceResponse = await _client
          .from('activity_card_clearance_requests')
          .select('status')
          .eq('student_id', studentId)
          .eq('scope_id', facultyId)
          .eq('academic_term_id', termId)
          .maybeSingle();
      
      return clearanceResponse != null && clearanceResponse['status'] == 'Cleared';
    }

    return false;
  }

  /// Submits a clearance request for a student.
  Future<void> requestClearance({
    required String studentId,
    required String scopeId,
    required String scopeType,
    required String termId,
  }) async {
    final isEligible = await isEligibleForClearance(studentId, scopeId, scopeType, termId);
    if (!isEligible) {
      throw Exception('You must clear the lower hierarchy organization first.');
    }

    // Create the request
    final response = await _client.from('activity_card_clearance_requests').insert({
      'student_id': studentId,
      'scope_id': scopeId,
      'scope_type': scopeType,
      'academic_term_id': termId,
      'status': 'Pending',
    }).select().single();

    final requestId = response['id'];

    // Identify required signatures based on roles and settings
    // This part would typically be handled by a database function or more complex logic
    // For now, we'll manually add Secretary, Treasurer, and Governor slots.
    // We also check if Adviser is required.
    
    final orgResponse = await _client
        .from('organizations')
        .select('requires_adviser_signature')
        .or('program_id.eq.$scopeId,faculty_id.eq.$scopeId,campus_id.eq.$scopeId')
        .limit(1)
        .maybeSingle();
    
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
        .select('*, role:roles(name)')
        .eq('id', signatureId)
        .single();
    
    final roleName = sigResponse['role']['name'];
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
