import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/storage_service.dart';
import '../../sanctions/repositories/sanction_repository.dart';
import '../models/excuse_request_model.dart';

class ExcuseRepository {
  final SupabaseClient _client;
  final StorageService _storageService;
  final SanctionRepository _sanctionRepository;

  ExcuseRepository(this._client, this._storageService, this._sanctionRepository);

  Future<void> submitExcuseRequest({
    required String studentId,
    required String eventId,
    required String reason,
    required XFile file,
    required String scopeType,
    required String scopeId,
    required String termId,
  }) async {
    final documentUrl = await _storageService.uploadExcuseDocument(
      file: file,
      studentId: studentId,
      eventId: eventId,
    );

    await _client.from('excuse_requests').upsert({
      'student_id': studentId,
      'event_id': eventId,
      'reason': reason,
      'supporting_document_url': documentUrl,
      'status': 'Pending',
      'scope_type': scopeType,
      'scope_id': scopeId,
      'academic_term_id': termId,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'student_id, event_id');
  }

  Future<List<ExcuseRequestModel>> getStudentExcuses(String studentId, String termId) async {
    final response = await _client
        .from('excuse_requests')
        .select('''
          *,
          event:events!event_id (name),
          reviewed_by:users!reviewed_by_user_id (first_name, last_name)
        ''')
        .eq('student_id', studentId)
        .eq('academic_term_id', termId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final event = json['event'];
      final reviewedBy = json['reviewed_by'];
      return ExcuseRequestModel.fromJson({
        ...json,
        'event_name': event?['name'] ?? 'Unknown Event',
        'reviewed_by_name': reviewedBy != null ? '${reviewedBy['first_name']} ${reviewedBy['last_name']}' : null,
      });
    }).toList();
  }

  Future<List<ExcuseRequestModel>> getWorkspaceExcuses(String scopeId, String termId) async {
    final response = await _client
        .from('excuse_requests')
        .select('''
          *,
          student:users!student_id (first_name, last_name, student_id_number),
          event:events!event_id (name),
          reviewed_by:users!reviewed_by_user_id (first_name, last_name)
        ''')
        .eq('scope_id', scopeId)
        .eq('academic_term_id', termId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final student = json['student'];
      final event = json['event'];
      final reviewedBy = json['reviewed_by'];
      return ExcuseRequestModel.fromJson({
        ...json,
        'student_name': student != null ? '${student['first_name']} ${student['last_name']}' : 'Unknown Student',
        'student_id_number': student?['student_id_number'] ?? 'N/A',
        'event_name': event?['name'] ?? 'Unknown Event',
        'reviewed_by_name': reviewedBy != null ? '${reviewedBy['first_name']} ${reviewedBy['last_name']}' : null,
      });
    }).toList();
  }

  Future<void> reviewExcuseRequest({
    required String excuseId,
    required String status, // 'Approved' or 'Rejected'
    String? rejectionReason,
    required String officerId,
    required String scopeId,
    required String scopeType,
    required String termId,
  }) async {
    final now = DateTime.now().toIso8601String();

    // 1. Update excuse request status
    final excuseData = await _client.from('excuse_requests').update({
      'status': status,
      'rejection_reason': status == 'Rejected' ? rejectionReason : null,
      'reviewed_by_user_id': officerId,
      'reviewed_at': now,
      'updated_at': now,
    }).eq('id', excuseId).select('student_id, event_id').single();

    final studentId = excuseData['student_id'] as String;
    final eventId = excuseData['event_id'] as String;

    // 2. Insert/Update student attendance
    if (status == 'Approved') {
      final existingAttendance = await _client
          .from('student_attendance')
          .select()
          .eq('student_id', studentId)
          .eq('event_id', eventId)
          .maybeSingle();

      if (existingAttendance == null) {
        await _client.from('student_attendance').insert({
          'student_id': studentId,
          'event_id': eventId,
          'status': 'Excused',
          'scanned_by_user_id': officerId,
          'override_reason': 'Excuse request approved',
          'updated_at': now,
        });
      } else {
        await _client.from('student_attendance').update({
          'status': 'Excused',
          'scanned_by_user_id': officerId,
          'override_reason': 'Excuse request approved',
          'updated_at': now,
        }).eq('id', existingAttendance['id']);
      }
    } else {
      // status == 'Rejected'
      final existingAttendance = await _client
          .from('student_attendance')
          .select()
          .eq('student_id', studentId)
          .eq('event_id', eventId)
          .maybeSingle();

      if (existingAttendance == null) {
        await _client.from('student_attendance').insert({
          'student_id': studentId,
          'event_id': eventId,
          'status': 'Absent',
          'scanned_by_user_id': officerId,
          'override_reason': 'Excuse request rejected: ${rejectionReason ?? 'No reason provided'}',
          'updated_at': now,
        });
      } else {
        // If it's incomplete (Partial) or already absent, leave the status as is, but log the override reason/review
        await _client.from('student_attendance').update({
          'override_reason': 'Excuse request rejected: ${rejectionReason ?? 'No reason provided'}',
          'updated_at': now,
        }).eq('id', existingAttendance['id']);
      }
    }

    // 3. Recalculate sanctions for the term/scope
    await _sanctionRepository.generateSanctionsForTerm(termId, scopeId, scopeType);
  }
}
