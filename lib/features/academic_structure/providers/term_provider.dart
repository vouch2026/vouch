import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../models/academic_term_model.dart';
import '../repositories/term_repository.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../auth/providers/auth_provider.dart';

final termRepositoryProvider = Provider<TermRepository>((ref) {
  return TermRepository(SupabaseConfig.client);
});

final academicTermsProvider = FutureProvider<List<AcademicTermModel>>((ref) async {
  return ref.watch(termRepositoryProvider).getTerms();
});

final activeTermProvider = FutureProvider<AcademicTermModel?>((ref) async {
  final box = Hive.box('settings');
  const cacheKey = 'active_academic_term';
  final cached = box.get(cacheKey);

  // Fast path: if connectivity provider knows we are offline, load cached instantly
  final connectivity = ref.read(connectivityProvider).value;
  if (connectivity == false) {
    if (cached != null) {
      final jsonMap = Map<String, dynamic>.from(cached as Map);
      return AcademicTermModel.fromJson(jsonMap);
    }
    return null;
  }

  try {
    final client = SupabaseConfig.client;
    var response = await client
        .from('academic_terms')
        .select()
        .eq('is_active', true)
        .limit(1)
        .maybeSingle()
        .timeout(const Duration(seconds: 5));
    
    // Fallback: If no term is explicitly marked is_active = true, fetch the latest term
    if (response == null) {
      response = await client
          .from('academic_terms')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));
    }

    if (response == null) {
      await box.delete(cacheKey);
      return null;
    }
    
    final term = AcademicTermModel.fromJson(response);
    await box.put(cacheKey, term.toJson());
    return term;
  } catch (e) {
    if (cached != null) {
      final jsonMap = Map<String, dynamic>.from(cached as Map);
      return AcademicTermModel.fromJson(jsonMap);
    }
    return null;
  }
});

/// User-selected term for history viewing. `null` = follow active term.
/// Persisted in Hive (`selected_academic_term_id`) so drawer reopen / restart
/// keeps context. Defaults to null (active) on first launch.
final selectedTermIdProvider = StateProvider<String?>((ref) {
  try {
    return Hive.box('settings').get('selected_academic_term_id') as String?;
  } catch (_) {
    return null;
  }
});

/// Persist a term selection (or clear it to follow active).
Future<void> persistSelectedTerm(String? termId) async {
  try {
    final box = Hive.box('settings');
    if (termId == null) {
      await box.delete('selected_academic_term_id');
    } else {
      await box.put('selected_academic_term_id', termId);
    }
  } catch (_) {
    // Hive not ready — selection still applies in-memory for this session.
  }
}

/// Terms the current user may browse in the School Year picker.
/// Super admins see everything. Everyone else sees only terms that did not
/// fully end before they registered (users.created_at). Terms without an
/// end_date (legacy rows) stay visible to all. Fail-open when offline or
/// when the profile cannot be resolved, preserving current offline behavior.
final availableTermsProvider =
    FutureProvider<List<AcademicTermModel>>((ref) async {
  final terms = await ref.watch(academicTermsProvider.future);
  late final DateTime? registeredAt;
  late final bool isSuperAdmin;
  try {
    final profile = await ref.watch(userProfileProvider.future);
    if (profile == null) return terms;
    isSuperAdmin = profile.role == 'super_admin';
    registeredAt = profile.createdAt;
  } catch (_) {
    return terms;
  }
  final regAt = registeredAt;
  if (isSuperAdmin || regAt == null) return terms;
  return terms.where((t) {
    final end = t.endDate;
    if (end == null) return true;
    return !end.isBefore(regAt);
  }).toList();
});

/// The term the UI should display data for: explicit selection if it still
/// exists AND is visible to the current user, otherwise the active term.
/// All module providers must watch this instead of [activeTermProvider]
/// directly. A stale Hive selection pointing at a hidden/deleted term is
/// clamped back to active.
final viewingTermProvider = FutureProvider<AcademicTermModel?>((ref) async {
  final selectedId = ref.watch(selectedTermIdProvider);
  if (selectedId != null) {
    try {
      final terms = await ref.watch(availableTermsProvider.future);
      for (final t in terms) {
        if (t.id == selectedId) return t;
      }
      // Selected term no longer exists (deleted) or is hidden from this
      // user (registered after it ended) — fall through to active.
    } catch (_) {
      // Offline / error — fall through to active (which has Hive fallback).
    }
  }
  return ref.watch(activeTermProvider.future);
});

/// True when the user is viewing a past (non-active) term.
/// Content pages use this to enforce view-only mode.
final isViewingPastProvider = FutureProvider<bool>((ref) async {
  final viewing = await ref.watch(viewingTermProvider.future);
  final active = await ref.watch(activeTermProvider.future);
  if (viewing == null || active == null) return false;
  return viewing.id != active.id;
});
