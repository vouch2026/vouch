import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fee_model.dart';
import '../models/payment_receiver_model.dart';
import '../models/student_payment_model.dart';
import '../repositories/finance_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../organizations/providers/workspace_provider.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(SupabaseConfig.client);
});

final workspaceFeesProvider = FutureProvider<List<FeeModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  
  if (org == null) return [];
  
  final scopeType = org.type == 'campus-based' 
      ? 'Institutional' 
      : (org.type == 'faculty-based' ? 'Faculty' : 'Program');
  
  final scopeId = org.type == 'campus-based' 
      ? org.campusId 
      : (org.type == 'faculty-based' ? org.facultyId : org.programId);

  if (scopeId == null) return [];
  
  return ref.watch(financeRepositoryProvider).getFeesByScope(scopeType, scopeId);
});

final paymentReceiversProvider = FutureProvider<List<PaymentReceiverModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  
  if (org == null) return [];
  
  final scopeType = org.type == 'campus-based' 
      ? 'Institutional' 
      : (org.type == 'faculty-based' ? 'Faculty' : 'Program');
  
  final scopeId = org.type == 'campus-based' 
      ? org.campusId 
      : (org.type == 'faculty-based' ? org.facultyId : org.programId);

  if (scopeId == null) return [];
  
  return ref.watch(financeRepositoryProvider).getPaymentReceivers(scopeType, scopeId);
});

final workspaceStudentPaymentsProvider = FutureProvider<List<StudentPaymentModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  
  if (org == null) return [];
  
  final scopeType = org.type == 'campus-based' 
      ? 'Institutional' 
      : (org.type == 'faculty-based' ? 'Faculty' : 'Program');
  
  final scopeId = org.type == 'campus-based' 
      ? org.campusId 
      : (org.type == 'faculty-based' ? org.facultyId : org.programId);

  if (scopeId == null) return [];
  
  return ref.watch(financeRepositoryProvider).getStudentPaymentsByScope(scopeType, scopeId);
});
