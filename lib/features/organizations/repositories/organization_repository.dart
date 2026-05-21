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

  Future<String> createOrganization({
    required String name,
    required String code,
    required String description,
    required String type,
    String? campusId,
    String? facultyId,
    List<String> programIds = const [],
    String? logoUrl,
    String? bannerUrl,
  }) async {
    final response = await _client.rpc(
      'create_organization_with_members',
      params: {
        'p_name': name,
        'p_code': code,
        'p_description': description,
        'p_type': type,
        'p_campus_id': campusId,
        'p_faculty_id': facultyId,
        'p_program_ids': programIds,
        'p_logo_url': logoUrl,
        'p_banner_url': bannerUrl,
      },
    );
    return response as String;
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
