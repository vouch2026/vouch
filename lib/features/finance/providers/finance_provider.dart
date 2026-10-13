import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fee_model.dart';
import '../models/payment_receiver_model.dart';
import '../models/student_payment_model.dart';
import '../repositories/finance_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/connectivity_provider.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(SupabaseConfig.client);
});

final workspaceFeesProvider = FutureProvider<List<FeeModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;

  if (org == null) return [];

  // School-based orgs (e.g. USC) resolve to scope_type `School`.
  final scope = await ref.watch(organizationScopeProvider(org).future);
  final scopeType = scope.scopeType;
  final scopeId = scope.scopeId;

  if (scopeId == null) return [];

  // AY|SEM history: default active, selectable via the sidebar. Past = view-only.
  final viewingTerm = await ref.watch(viewingTermProvider.future);
  final termId = viewingTerm?.id;

  final box = Hive.box('dashboard');
  final cacheKey = 'workspace_fees_${org.id}_${termId ?? 'all'}';
  final cached = box.get(cacheKey);

  // Fast path: if connectivity provider knows we are offline, load cached instantly
  final connectivity = ref.read(connectivityProvider).value;
  if (connectivity == false) {
    if (cached != null) {
      final cachedList = List<dynamic>.from(cached as List);
      return cachedList.map((json) {
        final jsonMap = Map<String, dynamic>.from(json as Map);
        return FeeModel.fromJson(jsonMap);
      }).toList();
    }
    return [];
  }

  try {
    final fees = await ref
        .watch(financeRepositoryProvider)
        .getFeesByScope(scopeType, scopeId, academicTermId: termId);
    final feesJson = fees.map((f) => f.toJson()).toList();
    await box.put(cacheKey, feesJson);
    return fees;
  } catch (e) {
    if (cached != null) {
      final cachedList = List<dynamic>.from(cached as List);
      return cachedList.map((json) {
        final jsonMap = Map<String, dynamic>.from(json as Map);
        return FeeModel.fromJson(jsonMap);
      }).toList();
    }
    rethrow;
  }
});

final paymentReceiversProvider = FutureProvider<List<PaymentReceiverModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;

  if (org == null) return [];

  final scope = await ref.watch(organizationScopeProvider(org).future);
  if (scope.scopeId == null) return [];

  return ref.watch(financeRepositoryProvider).getPaymentReceivers(scope.scopeType, scope.scopeId!);
});

final workspaceStudentPaymentsProvider = FutureProvider<List<StudentPaymentModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;

  if (org == null) return [];

  final scope = await ref.watch(organizationScopeProvider(org).future);
  if (scope.scopeId == null) return [];

  return ref.watch(financeRepositoryProvider).getStudentPaymentsByScope(scope.scopeType, scope.scopeId!);
});

final userStudentPaymentsProvider = FutureProvider.family<List<StudentPaymentModel>, String>((ref, studentId) async {
  return ref.watch(financeRepositoryProvider).getStudentPayments(studentId);
});

/// Explicitly obligated user ids for a fee.
/// Empty list = legacy behavior (everyone in scope obligated) OR table missing.
final feeTargetsProvider =
    FutureProvider.family<List<String>, String>((ref, feeId) async {
  return ref.watch(financeRepositoryProvider).getFeeTargets(feeId);
});

/// Fee ids the current user is explicitly obligated for (targeted).
final myObligatedFeeIdsProvider = FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(userProfileProvider).value;
  if (user == null || user.id == null) return {};
  return ref.watch(financeRepositoryProvider).getObligatedFeeIds(user.id!);
});
