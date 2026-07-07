import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fee_model.dart';
import '../models/payment_receiver_model.dart';
import '../models/student_payment_model.dart';

class FinanceRepository {
  final SupabaseClient _client;

  FinanceRepository(this._client);

  Future<List<FeeModel>> getFeesByScope(String scopeType, String scopeId) async {
    final response = await _client
        .from('fees')
        .select()
        .eq('scope_type', scopeType)
        .eq('scope_id', scopeId)
        .order('due_date', ascending: true);
    
    return (response as List).map((json) => FeeModel.fromJson(json)).toList();
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
}
