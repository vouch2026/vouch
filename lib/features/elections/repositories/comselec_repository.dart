import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comselec_model.dart';

class ComselecRepository {
  final SupabaseClient _client;

  ComselecRepository(this._client);

  Future<List<ComselecModel>> getComselecs() async {
    final response = await _client
        .from('comselecs')
        .select('''
          *,
          campuses(name),
          schools(name),
          comselec_settings (
            requires_chairman_signature,
            requires_commissioner_signature,
            allow_member_to_print,
            clearance_period_start,
            clearance_period_end
          ),
          member_count:comselec_members(count)
        ''')
        .order('name');
    
    return (response as List).map((json) {
      final countData = json['member_count'] as List?;
      final count = (countData != null && countData.isNotEmpty) 
          ? countData.first['count'] as int 
          : 0;
      
      final campusData = json['campuses'] as Map<String, dynamic>?;
      final campusName = campusData?['name'] as String?;

      final schoolData = json['schools'] as Map<String, dynamic>?;
      final schoolName = schoolData?['name'] as String?;
      
      final settingsData = json['comselec_settings'];
      final settings = settingsData is List 
          ? (settingsData.isNotEmpty ? settingsData.first as Map<String, dynamic> : null)
          : settingsData as Map<String, dynamic>?;
      
      final requiresChairman = settings?['requires_chairman_signature'] as bool? ?? false;
      final requiresCommissioner = settings?['requires_commissioner_signature'] as bool? ?? false;
      final allowMemberCardPrinting = settings?['allow_member_to_print'] as bool? ?? true;
      final clearancePeriodStartStr = settings?['clearance_period_start'] as String?;
      final clearancePeriodEndStr = settings?['clearance_period_end'] as String?;
      
      final now = DateTime.now();
      bool isClearanceActive = false;
      if (clearancePeriodStartStr != null && clearancePeriodEndStr != null) {
        final start = DateTime.parse(clearancePeriodStartStr);
        final end = DateTime.parse(clearancePeriodEndStr);
        isClearanceActive = now.isAfter(start) && now.isBefore(end);
      }

      return ComselecModel.fromJson({
        ...json,
        'memberCount': count,
        'campusName': campusName,
        'schoolName': schoolName,
        'requires_chairman_signature': requiresChairman,
        'requires_commissioner_signature': requiresCommissioner,
        'allow_member_card_printing': allowMemberCardPrinting,
        'clearance_period_start': clearancePeriodStartStr,
        'clearance_period_end': clearancePeriodEndStr,
        'is_clearance_active': isClearanceActive,
      });
    }).toList();
  }

  Future<ComselecModel?> getComselecById(String id) async {
    final response = await _client
        .from('comselecs')
        .select('''
          *,
          campuses(name),
          schools(name),
          comselec_settings (
            requires_chairman_signature,
            requires_commissioner_signature,
            allow_member_to_print,
            clearance_period_start,
            clearance_period_end
          )
        ''')
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;

    final campusData = response['campuses'] as Map<String, dynamic>?;
    final campusName = campusData?['name'] as String?;

    final schoolData = response['schools'] as Map<String, dynamic>?;
    final schoolName = schoolData?['name'] as String?;

    final settingsData = response['comselec_settings'];
    final settings = settingsData is List 
        ? (settingsData.isNotEmpty ? settingsData.first as Map<String, dynamic> : null)
        : settingsData as Map<String, dynamic>?;
    
    final requiresChairman = settings?['requires_chairman_signature'] as bool? ?? false;
    final requiresCommissioner = settings?['requires_commissioner_signature'] as bool? ?? false;
    final allowMemberCardPrinting = settings?['allow_member_to_print'] as bool? ?? true;
    final clearancePeriodStartStr = settings?['clearance_period_start'] as String?;
    final clearancePeriodEndStr = settings?['clearance_period_end'] as String?;
    
    final now = DateTime.now();
    bool isClearanceActive = false;
    if (clearancePeriodStartStr != null && clearancePeriodEndStr != null) {
      final start = DateTime.parse(clearancePeriodStartStr);
      final end = DateTime.parse(clearancePeriodEndStr);
      isClearanceActive = now.isAfter(start) && now.isBefore(end);
    }

    return ComselecModel.fromJson({
      ...response,
      'campusName': campusName,
      'schoolName': schoolName,
      'requires_chairman_signature': requiresChairman,
      'requires_commissioner_signature': requiresCommissioner,
      'allow_member_card_printing': allowMemberCardPrinting,
      'clearance_period_start': clearancePeriodStartStr,
      'clearance_period_end': clearancePeriodEndStr,
      'is_clearance_active': isClearanceActive,
    });
  }

  Future<String> createComselec({
    required String name,
    required String code,
    required String description,
    String type = 'campus-based',
    String? schoolId,
    String? campusId,
    String? logoUrl,
    String? bannerUrl,
  }) async {
    final Map<String, dynamic> params = {
      'p_name': name,
      'p_code': code,
      'p_description': description,
      'p_type': type,
      'p_campus_id': campusId,
      'p_logo_url': logoUrl,
      'p_banner_url': bannerUrl,
    };
    if (schoolId != null) {
      params['p_school_id'] = schoolId;
    }

    final response = await _client.rpc(
      'create_comselec_with_members',
      params: params,
    );
    return response as String;
  }

  Future<void> updateComselec(String id, Map<String, dynamic> data) async {
    final comKeys = ['name', 'code', 'description', 'logo_url', 'banner_url', 'status', 'campus_id'];
    
    final Map<String, dynamic> comData = {};
    final Map<String, dynamic> settingsData = {};

    for (var entry in data.entries) {
      if (comKeys.contains(entry.key)) {
        comData[entry.key] = entry.value;
      } else {
        if (entry.key == 'requires_chairman_signature') {
          settingsData['requires_chairman_signature'] = entry.value;
        } else if (entry.key == 'requires_commissioner_signature') {
          settingsData['requires_commissioner_signature'] = entry.value;
        } else if (entry.key == 'allow_member_card_printing') {
          settingsData['allow_member_to_print'] = entry.value;
        } else if (entry.key == 'clearance_period_start') {
          settingsData['clearance_period_start'] = entry.value;
        } else if (entry.key == 'clearance_period_end') {
          settingsData['clearance_period_end'] = entry.value;
        }
      }
    }

    if (comData.isNotEmpty) {
      await _client.from('comselecs').update(comData).eq('id', id);
    }

    if (settingsData.isNotEmpty) {
      await _client.from('comselec_settings').update(settingsData).eq('comselec_id', id);
    }
  }

  Future<void> deleteComselec(String id) async {
    await _client.from('comselecs').delete().eq('id', id);
  }

  // --- Election & Position Management ---

  Future<List<Map<String, dynamic>>> getElections({
    String? scopeType,
    String? campusId,
    String? facultyId,
    String? programId,
    String? status,
  }) async {
    var query = _client.from('elections').select('''
      *,
      campuses(name),
      faculties(name),
      programs(name)
    ''');

    if (scopeType != null) query = query.eq('scope_type', scopeType);
    if (campusId != null) query = query.eq('campus_id', campusId);
    if (facultyId != null) query = query.eq('faculty_id', facultyId);
    if (programId != null) query = query.eq('program_id', programId);
    if (status != null) query = query.eq('status', status);

    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<Map<String, dynamic>> createElection(Map<String, dynamic> data) async {
    final response = await _client.from('elections').insert(data).select().single();
    return response as Map<String, dynamic>;
  }

  Future<void> updateElectionStatus(String electionId, String status) async {
    await _client.from('elections').update({'status': status}).eq('id', electionId);
  }

  Future<List<Map<String, dynamic>>> getPositions(String electionId) async {
    final response = await _client
        .from('election_positions')
        .select()
        .eq('election_id', electionId)
        .order('display_order');
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<Map<String, dynamic>> createPosition(Map<String, dynamic> data) async {
    final response = await _client.from('election_positions').insert(data).select().single();
    return response as Map<String, dynamic>;
  }

  // --- Candidates & Applications ---

  Future<List<Map<String, dynamic>>> getCandidateApplications(String electionId) async {
    final response = await _client
        .from('candidate_applications')
        .select('''
          *,
          users(full_name, student_number),
          election_positions(name)
        ''')
        .eq('election_id', electionId)
        .order('submitted_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> submitCandidateApplication(Map<String, dynamic> data) async {
    await _client.from('candidate_applications').insert(data);
  }

  Future<void> reviewCandidateApplication({
    required String applicationId,
    required String status, // APPROVED, REJECTED, RETURNED_FOR_CORRECTION
    required String reviewerId,
    String? reviewNotes,
    String? rejectionReason,
  }) async {
    await _client.from('candidate_applications').update({
      'status': status,
      'review_notes': reviewNotes,
      'rejection_reason': rejectionReason,
      'reviewed_by': reviewerId,
      'reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', applicationId);
  }

  Future<List<Map<String, dynamic>>> getApprovedCandidates(String electionId) async {
    final response = await _client
        .from('election_candidates')
        .select('''
          *,
          election_positions(name, voting_type, seat_count)
        ''')
        .eq('election_id', electionId)
        .order('ballot_order');
    return List<Map<String, dynamic>>.from(response as List);
  }

  // --- Voter Eligibility ---

  Future<List<Map<String, dynamic>>> getVoterEligibility(String electionId) async {
    final response = await _client
        .from('election_voter_eligibility')
        .select('''
          *,
          users(full_name, student_number)
        ''')
        .eq('election_id', electionId);
    return List<Map<String, dynamic>>.from(response as List);
  }

  // --- Voting Engine RPC ---

  Future<Map<String, dynamic>> submitOnlineBallot({
    required String electionId,
    required List<Map<String, dynamic>> selections,
  }) async {
    final response = await _client.rpc(
      'submit_online_ballot',
      params: {
        'p_election_id': electionId,
        'p_selections': selections,
      },
    );
    final list = response as List;
    if (list.isNotEmpty) {
      return Map<String, dynamic>.from(list.first as Map);
    }
    return {'success': false, 'message': 'No response from server.'};
  }

  // --- Incidents ---

  Future<List<Map<String, dynamic>>> getIncidents(String electionId) async {
    final response = await _client
        .from('election_incidents')
        .select()
        .eq('election_id', electionId)
        .order('reported_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> reportIncident(Map<String, dynamic> data) async {
    await _client.from('election_incidents').insert(data);
  }
}
