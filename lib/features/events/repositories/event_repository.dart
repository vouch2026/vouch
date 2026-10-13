import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/scope_obligation.dart';
import '../models/event_model.dart';

class EventRepository {
  final SupabaseClient _client;

  EventRepository(this._client);

  Future<List<EventModel>> getEventsByScope(
    String scopeType,
    String scopeId, {
    String? academicTermId,
  }) async {
    var query = _client
        .from('events')
        .select()
        .eq('scope_type', scopeType)
        .eq('scope_id', scopeId);
    if (academicTermId != null) {
      query = query.eq('academic_term_id', academicTermId);
    }
    final response = await query.order('event_date', ascending: false);

    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  Future<EventModel?> getEventById(String id) async {
    final response = await _client
        .from('events')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return EventModel.fromJson(response);
  }

  Future<String> createEvent(EventModel event) async {
    final data = event.toJson();
    
    // Remove auto-generated fields if they are null/empty to allow Supabase defaults
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
        .from('events')
        .insert(data)
        .select('id')
        .single();
    
    return response['id'] as String;
  }

  Future<void> updateEvent(EventModel event) async {
    if (event.id == null) throw Exception('Cannot update event without an ID');
    
    await _client
        .from('events')
        .update(event.toJson())
        .eq('id', event.id!);
  }

  Future<void> deleteEvent(String id) async {
    await _client
        .from('events')
        .delete()
        .eq('id', id);
  }

  Future<List<EventModel>> getAllEvents({String? academicTermId}) async {
    var query = _client.from('events').select();
    if (academicTermId != null) {
      query = query.eq('academic_term_id', academicTermId);
    }
    final response = await query.order('event_date', ascending: false);

    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  // --- Obligation targets -------------------------------------------------
  // Visibility = parent scope (everyone in scope sees the event).
  // Obligation = row in event_targets (only selected members must attend and
  // it counts toward activity-card clearance). Events with zero target rows
  // keep legacy behavior: all in scope are obligated.

  /// User ids obligated for [eventId]. Empty = legacy (all in scope).
  /// Returns [] (not error) when the table doesn't exist yet (old DB).
  Future<List<String>> getEventTargets(String eventId) async {
    try {
      final response = await _client
          .from('event_targets')
          .select('user_id')
          .eq('event_id', eventId);
      return (response as List)
          .map((row) => (row as Map)['user_id'] as String)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Replace the full target set for [eventId] (delete + bulk insert).
  /// Pass an empty list to clear back to legacy "all in scope" behavior.
  /// Optional [scopeTargets] replaces whole-unit picks the same way.
  Future<void> setEventTargets(
    String eventId,
    List<String> userIds, {
    List<ScopeTarget> scopeTargets = const [],
  }) async {
    try {
      await _client.from('event_targets').delete().eq('event_id', eventId);
      if (userIds.isNotEmpty) {
        final rows = userIds
            .toSet()
            .map((uid) => {'event_id': eventId, 'user_id': uid})
            .toList();
        await _client.from('event_targets').insert(rows);
      }
    } catch (_) {
      // Table missing on old DBs — event itself is already created; ignore.
    }
    await setEventScopeTargets(eventId, scopeTargets);
  }

  /// Whole-unit picks for [eventId]. Empty = none (legacy unless user rows
  /// exist). Returns [] (not error) when the table doesn't exist (old DB).
  /// Falls back to dateless rows on DBs predating the year_level column.
  Future<List<ScopeTarget>> getEventScopeTargets(String eventId) async {
    List<ScopeTarget> parse(Object response) {
      return (response as List)
          .map((row) => ScopeTarget.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    }

    try {
      final response = await _client
          .from('event_scope_targets')
          .select('scope_type, scope_id, year_level')
          .eq('event_id', eventId);
      return parse(response);
    } catch (_) {}
    try {
      // Pre-year_level DB: column missing -> retry without it.
      final response = await _client
          .from('event_scope_targets')
          .select('scope_type, scope_id')
          .eq('event_id', eventId);
      return parse(response);
    } catch (_) {
      return [];
    }
  }

  /// Replace the whole-unit picks for [eventId] (delete + bulk insert).
  Future<void> setEventScopeTargets(
      String eventId, List<ScopeTarget> scopes) async {
    try {
      await _client
          .from('event_scope_targets')
          .delete()
          .eq('event_id', eventId);
      if (scopes.isEmpty) return;
      final seen = <ScopeTarget>{};
      final rows = <Map<String, dynamic>>[];
      for (final s in scopes) {
        if (seen.add(s)) rows.add(s.toInsertJson('event_id', eventId));
      }
      try {
        await _client.from('event_scope_targets').insert(rows);
      } catch (_) {
        // Pre-year_level DB: retry stripped.
        await _client.from('event_scope_targets').insert(
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

  /// Excepted user ids for [eventId]. Empty = none. [] on old DBs.
  Future<Set<String>> getEventTargetExceptions(String eventId) async {
    try {
      final response = await _client
          .from('event_target_exceptions')
          .select('user_id')
          .eq('event_id', eventId);
      return (response as List)
          .map((row) => (row as Map)['user_id'] as String)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  /// Replace the exception set for [eventId] (delete + bulk insert).
  Future<void> setEventTargetExceptions(
      String eventId, Set<String> userIds) async {
    try {
      await _client
          .from('event_target_exceptions')
          .delete()
          .eq('event_id', eventId);
      if (userIds.isEmpty) return;
      await _client.from('event_target_exceptions').insert(
            userIds.map((uid) => {'event_id': eventId, 'user_id': uid}).toList(),
          );
    } catch (_) {
      // Table missing on old DBs — ignore.
    }
  }

  /// Combined obligation rule for one event. Legacy when no table has rows.
  Future<ObligationRule> getEventObligation(String eventId) async {
    final map = await getEventObligationMap([eventId]);
    return map[eventId] ?? const ObligationRule.legacy();
  }

  /// Combined obligation rules for a batch of events. Parents with no rows
  /// in any table are ABSENT (legacy).
  Future<Map<String, ObligationRule>> getEventObligationMap(
      List<String> eventIds) async {
    if (eventIds.isEmpty) return {};
    final userMap = <String, Set<String>>{};
    final scopeMap = <String, List<ScopeTarget>>{};
    final exceptionMap = <String, Set<String>>{};
    try {
      final response = await _client
          .from('event_targets')
          .select('event_id, user_id')
          .filter('event_id', 'in', eventIds);
      for (final row in (response as List)) {
        final m = Map<String, dynamic>.from(row as Map);
        final eid = m['event_id'] as String?;
        final uid = m['user_id'] as String?;
        if (eid == null || uid == null) continue;
        userMap.putIfAbsent(eid, () => <String>{}).add(uid);
      }
    } catch (_) {}
    try {
      late final Object scopeResponse;
      try {
        scopeResponse = await _client
            .from('event_scope_targets')
            .select('event_id, scope_type, scope_id, year_level')
            .filter('event_id', 'in', eventIds);
      } catch (_) {
        scopeResponse = await _client
            .from('event_scope_targets')
            .select('event_id, scope_type, scope_id')
            .filter('event_id', 'in', eventIds);
      }
      for (final row in (scopeResponse as List)) {
        final m = Map<String, dynamic>.from(row as Map);
        final eid = m['event_id'] as String?;
        if (eid == null) continue;
        try {
          scopeMap
              .putIfAbsent(eid, () => <ScopeTarget>[])
              .add(ScopeTarget.fromJson(m));
        } catch (_) {}
      }
    } catch (_) {}
    try {
      final response = await _client
          .from('event_target_exceptions')
          .select('event_id, user_id')
          .filter('event_id', 'in', eventIds);
      for (final row in (response as List)) {
        final m = Map<String, dynamic>.from(row as Map);
        final eid = m['event_id'] as String?;
        final uid = m['user_id'] as String?;
        if (eid == null || uid == null) continue;
        exceptionMap.putIfAbsent(eid, () => <String>{}).add(uid);
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

  /// Event ids in [scope] for which [userId] is obligated: explicitly listed
  /// or member of a targeted scope unit (campus/faculty/program ids narrow
  /// the scope-rule match).
  Future<Set<String>> getObligatedEventIds(
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
          .from('event_targets')
          .select('event_id, events!inner(academic_term_id)')
          .eq('user_id', userId);
      if (academicTermId != null) {
        query = query.eq('events.academic_term_id', academicTermId);
      }
      final response = await query;
      ids.addAll((response as List)
          .map((row) => (row as Map)['event_id'] as String));
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
              .from('event_scope_targets')
              .select('event_id, year_level, events!inner(academic_term_id)')
              .eq('scope_type', pair.key)
              .eq('scope_id', pair.value);
          if (academicTermId != null) {
            query = query.eq('events.academic_term_id', academicTermId);
          }
          scopeResponse = await query;
        } catch (_) {
          var query = _client
              .from('event_scope_targets')
              .select('event_id, events!inner(academic_term_id)')
              .eq('scope_type', pair.key)
              .eq('scope_id', pair.value);
          if (academicTermId != null) {
            query = query.eq('events.academic_term_id', academicTermId);
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
          ids.add((m['event_id'] as String));
        }
      } catch (_) {}
    }
    // Exceptions win over unit membership (ids outside this term simply
    // aren't in the set, so unfiltered removal is safe).
    try {
      final response = await _client
          .from('event_target_exceptions')
          .select('event_id')
          .eq('user_id', userId);
      ids.removeAll((response as List)
          .map((row) => (row as Map)['event_id'] as String));
    } catch (_) {}
    return ids;
  }
}
