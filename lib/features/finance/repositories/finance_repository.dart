import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/scope_obligation.dart';
import '../models/fee_model.dart';
import '../models/payment_receiver_model.dart';
import '../models/student_payment_model.dart';

class FinanceRepository {
  final SupabaseClient _client;

  FinanceRepository(this._client);

  Future<List<FeeModel>> getFeesByScope(
    String scopeType,
    String scopeId, {
    String? academicTermId,
  }) async {
    var query = _client
        .from('fees')
        .select()
        .eq('scope_type', scopeType)
        .eq('scope_id', scopeId);
    if (academicTermId != null) {
      query = query.eq('academic_term_id', academicTermId);
    }
    final response = await query.order('due_date', ascending: true);

    return (response as List).map((json) => FeeModel.fromJson(json)).toList();
  }

  // --- Obligation targets -------------------------------------------------
  // Visibility = parent scope (everyone in scope sees the fee).
  // Obligation = row in fee_targets (only selected members must pay and it
  // counts toward activity-card clearance). Fees with zero target rows keep
  // legacy behavior: all in scope are obligated.

  /// User ids obligated for [feeId]. Empty = legacy (all in scope).
  /// Returns [] (not error) when the table doesn't exist yet (old DB).
  Future<List<String>> getFeeTargets(String feeId) async {
    try {
      final response = await _client
          .from('fee_targets')
          .select('user_id')
          .eq('fee_id', feeId);
      return (response as List)
          .map((row) => (row as Map)['user_id'] as String)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// feeId -> set of obligated userIds for a batch of fees.
  /// Fees with no rows are ABSENT from the map (legacy: all obligated).
  /// Returns {} when the table doesn't exist yet (old DB) — same effect.
  Future<Map<String, Set<String>>> getFeeTargetsMap(
      List<String> feeIds) async {
    if (feeIds.isEmpty) return {};
    try {
      final response = await _client
          .from('fee_targets')
          .select('fee_id, user_id')
          .filter('fee_id', 'in', feeIds);
      final map = <String, Set<String>>{};
      for (final row in (response as List)) {
        final m = Map<String, dynamic>.from(row as Map);
        final fid = m['fee_id'] as String?;
        final uid = m['user_id'] as String?;
        if (fid == null || uid == null) continue;
        map.putIfAbsent(fid, () => <String>{}).add(uid);
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  /// Replace the full target set for [feeId] (delete + bulk insert).
  /// Pass an empty list to clear back to legacy "all in scope" behavior.
  /// Optional [scopeTargets] replaces whole-unit picks the same way.
  Future<void> setFeeTargets(
    String feeId,
    List<String> userIds, {
    List<ScopeTarget> scopeTargets = const [],
  }) async {
    try {
      await _client.from('fee_targets').delete().eq('fee_id', feeId);
      if (userIds.isNotEmpty) {
        final rows = userIds
            .toSet()
            .map((uid) => {'fee_id': feeId, 'user_id': uid})
            .toList();
        await _client.from('fee_targets').insert(rows);
      }
    } catch (_) {
      // Table missing on old DBs — fee itself is already created; ignore.
    }
    await setFeeScopeTargets(feeId, scopeTargets);
  }

  /// Whole-unit picks for [feeId]. Empty = none (legacy unless user rows
  /// exist). Returns [] (not error) when the table doesn't exist (old DB).
  /// Falls back to dateless rows on DBs predating the year_level column.
  Future<List<ScopeTarget>> getFeeScopeTargets(String feeId) async {
    List<ScopeTarget> parse(Object response) {
      return (response as List)
          .map((row) => ScopeTarget.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    }

    try {
      final response = await _client
          .from('fee_scope_targets')
          .select('scope_type, scope_id, year_level')
          .eq('fee_id', feeId);
      return parse(response);
    } catch (_) {}
    try {
      final response = await _client
          .from('fee_scope_targets')
          .select('scope_type, scope_id')
          .eq('fee_id', feeId);
      return parse(response);
    } catch (_) {
      return [];
    }
  }

  /// Replace the whole-unit picks for [feeId] (delete + bulk insert).
  Future<void> setFeeScopeTargets(
      String feeId, List<ScopeTarget> scopes) async {
    try {
      await _client.from('fee_scope_targets').delete().eq('fee_id', feeId);
      if (scopes.isEmpty) return;
      final seen = <ScopeTarget>{};
      final rows = <Map<String, dynamic>>[];
      for (final s in scopes) {
        if (seen.add(s)) rows.add(s.toInsertJson('fee_id', feeId));
      }
      try {
        await _client.from('fee_scope_targets').insert(rows);
      } catch (_) {
        // Pre-year_level DB: retry stripped.
        await _client.from('fee_scope_targets').insert(
          rows.map((r) {
            final copy = Map<String, dynamic>.from(r);
            copy.remove('year_level');
            return copy;
          }).toList(),
        );
      }
    } catch (_) {
      // Table missing on old DBs — ignore.
    }
  }

  /// Excepted user ids for [feeId]. Empty = none. [] on old DBs.
  Future<Set<String>> getFeeTargetExceptions(String feeId) async {
    try {
      final response = await _client
          .from('fee_target_exceptions')
          .select('user_id')
          .eq('fee_id', feeId);
      return (response as List)
          .map((row) => (row as Map)['user_id'] as String)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  /// Replace the exception set for [feeId] (delete + bulk insert).
  Future<void> setFeeTargetExceptions(
      String feeId, Set<String> userIds) async {
    try {
      await _client
          .from('fee_target_exceptions')
          .delete()
          .eq('fee_id', feeId);
      if (userIds.isEmpty) return;
      await _client.from('fee_target_exceptions').insert(
            userIds.map((uid) => {'fee_id': feeId, 'user_id': uid}).toList(),
          );
    } catch (_) {
      // Table missing on old DBs — ignore.
    }
  }

  /// Combined obligation rule for one fee. Legacy when no table has rows.
  Future<ObligationRule> getFeeObligation(String feeId) async {
    final map = await getFeeObligationMap([feeId]);
    return map[feeId] ?? const ObligationRule.legacy();
  }

  /// Combined obligation rules for a batch of fees. Parents with no rows
  /// in any table are ABSENT (legacy).
  Future<Map<String, ObligationRule>> getFeeObligationMap(
      List<String> feeIds) async {
    if (feeIds.isEmpty) return {};
    final userMap = <String, Set<String>>{};
    final scopeMap = <String, List<ScopeTarget>>{};
    final exceptionMap = <String, Set<String>>{};
    try {
      final response = await _client
          .from('fee_targets')
          .select('fee_id, user_id')
          .filter('fee_id', 'in', feeIds);
      for (final row in (response as List)) {
        final m = Map<String, dynamic>.from(row as Map);
        final fid = m['fee_id'] as String?;
        final uid = m['user_id'] as String?;
        if (fid == null || uid == null) continue;
        userMap.putIfAbsent(fid, () => <String>{}).add(uid);
      }
    } catch (_) {}
    try {
      late final Object scopeResponse;
      try {
        scopeResponse = await _client
            .from('fee_scope_targets')
            .select('fee_id, scope_type, scope_id, year_level')
            .filter('fee_id', 'in', feeIds);
      } catch (_) {
        scopeResponse = await _client
            .from('fee_scope_targets')
            .select('fee_id, scope_type, scope_id')
            .filter('fee_id', 'in', feeIds);
      }
      for (final row in (scopeResponse as List)) {
        final m = Map<String, dynamic>.from(row as Map);
        final fid = m['fee_id'] as String?;
        if (fid == null) continue;
        try {
          scopeMap
              .putIfAbsent(fid, () => <ScopeTarget>[])
              .add(ScopeTarget.fromJson(m));
        } catch (_) {}
      }
    } catch (_) {}
    try {
      final response = await _client
          .from('fee_target_exceptions')
          .select('fee_id, user_id')
          .filter('fee_id', 'in', feeIds);
      for (final row in (response as List)) {
        final m = Map<String, dynamic>.from(row as Map);
        final fid = m['fee_id'] as String?;
        final uid = m['user_id'] as String?;
        if (fid == null || uid == null) continue;
        exceptionMap.putIfAbsent(fid, () => <String>{}).add(uid);
      }
    } catch (_) {}
    final ids = <String>{
      ...userMap.keys,
      ...scopeMap.keys,
      ...exceptionMap.keys,
    };
    return {
      for (final id in ids)
        id: ObligationRule(
          userIds: userMap[id],
          scopes: scopeMap[id] ?? const [],
          excludedUserIds: exceptionMap[id] ?? const {},
        ),
    };
  }

  /// Fee ids for which [userId] is obligated: explicitly listed or member
  /// of a targeted scope unit (campus/faculty/program/year narrow the
  /// match), minus explicit exceptions.
  Future<Set<String>> getObligatedFeeIds(
    String userId, {
    String? academicTermId,
    String? campusId,
    String? facultyId,
    String? programId,
    int? yearLevel,
  }) async {
    final ids = <String>{};
    try {
      var query = _client
          .from('fee_targets')
          .select('fee_id, fees!inner(academic_term_id)')
          .eq('user_id', userId);
      if (academicTermId != null) {
        query = query.eq('fees.academic_term_id', academicTermId);
      }
      final response = await query;
      ids.addAll((response as List)
          .map((row) => (row as Map)['fee_id'] as String));
    } catch (_) {}
    final scopePairs = <MapEntry<String, String>>[
      if (campusId != null) MapEntry('Institutional', campusId),
      if (facultyId != null) MapEntry('Faculty', facultyId),
      if (programId != null) MapEntry('Program', programId),
    ];
    for (final pair in scopePairs) {
      try {
        late final Object scopeResponse;
        try {
          var query = _client
              .from('fee_scope_targets')
              .select('fee_id, year_level, fees!inner(academic_term_id)')
              .eq('scope_type', pair.key)
              .eq('scope_id', pair.value);
          if (academicTermId != null) {
            query = query.eq('fees.academic_term_id', academicTermId);
          }
          scopeResponse = await query;
        } catch (_) {
          var query = _client
              .from('fee_scope_targets')
              .select('fee_id, fees!inner(academic_term_id)')
              .eq('scope_type', pair.key)
              .eq('scope_id', pair.value);
          if (academicTermId != null) {
            query = query.eq('fees.academic_term_id', academicTermId);
          }
          scopeResponse = await query;
        }
        for (final row in (scopeResponse as List)) {
          final m = Map<String, dynamic>.from(row as Map);
          final rowYear = m['year_level'];
          if (rowYear != null &&
              yearLevel != null &&
              (rowYear as num).toInt() != yearLevel) {
            continue;
          }
          ids.add((m['fee_id'] as String));
        }
      } catch (_) {}
    }
    // Exceptions win over unit membership.
    try {
      final response = await _client
          .from('fee_target_exceptions')
          .select('fee_id')
          .eq('user_id', userId);
      ids.removeAll((response as List)
          .map((row) => (row as Map)['fee_id'] as String));
    } catch (_) {}
    return ids;
  }

  Future<String> createFee(FeeModel fee) async {
    final data = fee.toJson();
    
    // Remove auto-generated fields
    if (data['id'] == null || (data['id'] as String).isEmpty) {
      data.remove('id');
    }
    if (data['created_at'] == null) {
      data.remove('created_at');
    }
    if (data['updated_at'] == null) {
      data.remove('updated_at');
    }

    final response = await _client
        .from('fees')
        .insert(data)
        .select('id')
        .single();
    
    return response['id'] as String;
  }

  Future<void> updateFee(FeeModel fee) async {
    if (fee.id == null) throw Exception('Cannot update fee without an ID');
    
    await _client
        .from('fees')
        .update(fee.toJson())
        .eq('id', fee.id!);
  }

  Future<void> deleteFee(String id) async {
    await _client
        .from('fees')
        .delete()
        .eq('id', id);
  }

  // --- Payment Receivers ---

  Future<List<PaymentReceiverModel>> getPaymentReceivers(String scopeType, String scopeId) async {
    final response = await _client
        .from('payment_receiver')
        .select()
        .eq('scope_type', scopeType)
        .eq('scope_id', scopeId)
        .order('account_name', ascending: true);
    
    return (response as List).map((json) => PaymentReceiverModel.fromJson(json)).toList();
  }

  Future<String> createPaymentReceiver(PaymentReceiverModel receiver) async {
    final data = receiver.toJson();
    if (data['id'] == null || (data['id'] as String).isEmpty) {
      data.remove('id');
    }

    final response = await _client
        .from('payment_receiver')
        .insert(data)
        .select('id')
        .single();
    
    return response['id'] as String;
  }

  Future<void> updatePaymentReceiver(PaymentReceiverModel receiver) async {
    if (receiver.id == null) throw Exception('Cannot update receiver without an ID');
    
    await _client
        .from('payment_receiver')
        .update(receiver.toJson())
        .eq('id', receiver.id!);
  }

  Future<void> deletePaymentReceiver(String id) async {
    await _client
        .from('payment_receiver')
        .delete()
        .eq('id', id);
  }

  // --- Student Payments ---

  Future<List<StudentPaymentModel>> getStudentPaymentsByScope(String scopeType, String scopeId) async {
    // We need to join with fees to filter by scope
    final response = await _client
        .from('student_payments')
        .select('''
          *,
          fee:fees!inner (
            name,
            scope_type,
            scope_id
          ),
          student:users!student_payments_student_id_fkey (
            first_name,
            last_name,
            student_id_number
          )
        ''')
        .eq('fee.scope_type', scopeType)
        .eq('fee.scope_id', scopeId)
        .order('paid_at', ascending: false);
    
    return (response as List).map<StudentPaymentModel>((json) {
      final model = StudentPaymentModel.fromJson(json);
      final student = json['student'] as Map<String, dynamic>?;
      final fee = json['fee'] as Map<String, dynamic>?;
      
      return model.copyWith(
        studentName: student != null ? '${student['first_name']} ${student['last_name']}' : 'Unknown Student',
        studentIdNumber: student != null ? student['student_id_number'] : 'Unknown ID',
        feeName: fee != null ? fee['name'] : 'Unknown Fee',
      );
    }).toList();
  }

  Future<void> updatePaymentStatus(String paymentId, String status, String? rejectionNote, String officerId) async {
    await _client
        .from('student_payments')
        .update({
          'status': status,
          'rejection_note': rejectionNote,
          'received_by_user_id': officerId,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', paymentId);
  }

  Future<void> submitStudentPayment(StudentPaymentModel payment) async {
    final data = payment.toJson();
    
    // Remove auto-generated/virtual fields
    if (data['id'] == null || (data['id'] as String).isEmpty) {
      data.remove('id');
    }
    data.remove('studentName');
    data.remove('feeName');
    
    await _client.from('student_payments').insert(data);
  }

  Future<List<StudentPaymentModel>> getStudentPayments(String studentId) async {
    final response = await _client
        .from('student_payments')
        .select('*, fee:fees(*)')
        .eq('student_id', studentId)
        .order('paid_at', ascending: false);
    
    return (response as List).map<StudentPaymentModel>((json) {
      final model = StudentPaymentModel.fromJson(json);
      final fee = json['fee'] as Map<String, dynamic>?;
      return model.copyWith(
        feeName: fee != null ? fee['name'] : 'Unknown Fee',
      );
    }).toList();
  }
}
