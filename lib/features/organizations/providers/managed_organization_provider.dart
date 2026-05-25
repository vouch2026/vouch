import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/organization_model.dart';
import '../repositories/organization_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/config/supabase_config.dart';

final managedOrganizationProvider = FutureProvider.autoDispose<OrganizationModel?>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null || userProfile.id == null) return null;

  final client = SupabaseConfig.client;
  
  // Find the organization where this user is an active officer
  final response = await client
      .from('organization_members')
      .select('organizations (*)')
      .eq('user_id', userProfile.id!)
      .not('role_id', 'is', null)
      .eq('status', 'active')
      .maybeSingle();

  if (response == null || response['organizations'] == null) return null;

  return OrganizationModel.fromJson(response['organizations']);
});
