import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';

class PaymentReceiverDetails {
  final String id;
  final String name;
  final String gcashNumber;
  final String position;
  final String provider;
  final bool isActive;

  const PaymentReceiverDetails({
    required this.id,
    required this.name,
    required this.gcashNumber,
    required this.position,
    this.provider = 'GCash',
    required this.isActive,
  });

  factory PaymentReceiverDetails.fromMap(Map<String, dynamic> data) {
    return PaymentReceiverDetails(
      id: _readString(data['receiver_id']),
      name: _readString(data['receiver_name']),
      gcashNumber: _readString(data['receiver_gcash']),
      position: _readString(data['receiver_position']),
      provider: _readString(data['provider']).isEmpty 
          ? 'GCash' 
          : _readString(data['provider']),
      isActive: _readBool(data['is_active']),
    );
  }

  static String formatGcashNumber(String rawValue) {
    final digits = rawValue.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 11) {
      return rawValue.trim();
    }

    return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 't';
  }
}

class PaymentReceiverService {
  PaymentReceiverService._();

  static final PaymentReceiverService instance = PaymentReceiverService._();

  static const String tableName = 'payment_receiver';
  static const String defaultReceiverId = 'main_receiver';

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<PaymentReceiverDetails>> fetchActiveReceivers() async {
    final response = await _client
        .from(tableName)
        .select(
          'receiver_id, receiver_name, receiver_gcash, receiver_position, provider, is_active',
        )
        .eq('is_active', true)
        .order('receiver_id', ascending: true);

    if (response.isEmpty) {
      return [];
    }

    return (response as List)
        .map((data) => PaymentReceiverDetails.fromMap(data))
        .toList();
  }

  Future<PaymentReceiverDetails?> fetchActiveReceiver() async {
    final receivers = await fetchActiveReceivers();
    return receivers.isNotEmpty ? receivers.first : null;
  }

  Future<PaymentReceiverDetails?> fetchReceiverById(String id) async {
    final response = await _client
        .from(tableName)
        .select(
          'receiver_id, receiver_name, receiver_gcash, receiver_position, provider, is_active',
        )
        .eq('receiver_id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return PaymentReceiverDetails.fromMap(response);
  }

  Future<PaymentReceiverDetails> upsertReceiver({
    required String name,
    required String gcashNumber,
    required String position,
    String provider = 'GCash',
    String? receiverId, // If provided and different from new provider ID, the old one will be deleted
    bool isActive = true,
  }) async {
    final adminId = await _resolveCurrentAdminId();
    // Make provider IDs unique per admin so different admins can create the same provider name safely.
    final normalizedProviderId = provider.trim().toLowerCase().replaceAll('.', '_');
    final normalizedReceiverId = 'provider_${normalizedProviderId}_$adminId';

    // 1. Perform the upsert for the new/updated provider ID.
    final response = await _client
        .from(tableName)
        .upsert({
          'admin_id': adminId,
          'receiver_id': normalizedReceiverId,
          'receiver_name': name.trim(),
          'receiver_gcash': gcashNumber.trim(),
          'receiver_position': position.trim(),
          'provider': provider.trim(),
          'is_active': isActive,
        }, onConflict: 'receiver_id')
        .select(
          'receiver_id, receiver_name, receiver_gcash, receiver_position, provider, is_active, admin_id',
        )
        .single();

    // 2. If we are editing an existing record and the ID changed (due to provider change),
    // delete the old record to prevent duplicates.
    if (receiverId != null && receiverId != normalizedReceiverId) {
      try {
        await deleteReceiver(receiverId);
      } catch (e) {
        // Log or handle deletion error if necessary, but we've successfully upserted the new one
        debugPrint('Note: Could not delete old receiver record $receiverId: $e');
      }
    }

    return PaymentReceiverDetails.fromMap(response);
  }

  Future<int> _resolveCurrentAdminId() async {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      throw StateError('No authenticated admin found.');
    }

    final admin = await _client
        .from('admins')
        .select('id')
        .ilike('email', email)
        .maybeSingle();

    final adminId = admin?['id'];
    if (adminId is int) {
      return adminId;
    }

    if (adminId is String) {
      final parsed = int.tryParse(adminId);
      if (parsed != null) {
        return parsed;
      }
    }

    throw StateError('Admin account not found.');
  }

  Future<void> deleteReceiver(String id) async {
    await _client.from(tableName).delete().eq('receiver_id', id);
  }
}
