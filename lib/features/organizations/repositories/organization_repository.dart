import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/organization_model.dart';

class OrganizationRepository {
  final SupabaseClient _client;

  OrganizationRepository(this._client);

  Future<List<OrganizationModel>> getOrganizations() async {
    final response = await _client
        .from('organizations')
        .select()
        .order('name');
    
    return (response as List)
        .map((json) => OrganizationModel.fromJson(json))
        .toList();
  }

  Future<OrganizationModel?> getOrganizationById(String id) async {
    final response = await _client
        .from('organizations')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return OrganizationModel.fromJson(response);
  }

  Future<List<OrganizationModel>> getUserOrganizations(String userId) async {
    final response = await _client
        .from('organization_members')
        .select('organizations (*)')
        .eq('user_id', userId);
    
    return (response as List)
        .map((json) => OrganizationModel.fromJson(json['organizations']))
        .toList();
  }
}
