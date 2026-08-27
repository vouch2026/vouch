import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fee_model.dart';
import '../models/payment_receiver_model.dart';
import '../models/student_payment_model.dart';
import '../repositories/finance_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../../core/providers/connectivity_provider.dart';

import '../../academic_structure/providers/academic_context_provider.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(SupabaseConfig.client);
});

final workspaceFeesProvider = FutureProvider<List<FeeModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  final selectedTerm = ref.watch(selectedAcademicTermProvider);
  
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

  final box = Hive.box('dashboard');
  final cacheKey = 'workspace_fees_${org.id}_${selectedTerm?.id ?? 'active'}';
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
        .getFeesByScope(scopeType, scopeId, termId: selectedTerm?.id);
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
  
  final isInstitutional = org.type == 'campus-based' || org.type == 'institutional';
  final isFaculty = org.type == 'faculty-based' || org.type == 'faculty';
  
  final scopeType = isInstitutional 
      ? 'Institutional' 
      : (isFaculty ? 'Faculty' : 'Program');
  
  final scopeId = isInstitutional 
      ? org.campusId 
      : (isFaculty ? org.facultyId : org.programId);

  if (scopeId == null) return [];
  
  return ref.watch(financeRepositoryProvider).getPaymentReceivers(scopeType, scopeId);
});

final workspaceStudentPaymentsProvider = FutureProvider<List<StudentPaymentModel>>((ref) async {
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
  
  return ref.watch(financeRepositoryProvider).getStudentPaymentsByScope(scopeType, scopeId);
});

final userStudentPaymentsProvider = FutureProvider.family<List<StudentPaymentModel>, String>((ref, studentId) async {
  return ref.watch(financeRepositoryProvider).getStudentPayments(studentId);
});
