import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/organization_model.dart';
import '../models/organization_membership_model.dart';
import '../../auth/models/user_model.dart';

class OrganizationRepository {
  final SupabaseClient _client;

  OrganizationRepository(this._client);

  Future<List<OrganizationModel>> getOrganizations() async {
    final response = await _client
        .from('organizations')
        .select('''
          *,
          member_count:organization_members(count)
        ''')
        .order('name');
    
    return (response as List).map((json) {
      final countData = json['member_count'] as List?;
      final count = (countData != null && countData.isNotEmpty) 
          ? countData.first['count'] as int 
          : 0;
      
      return OrganizationModel.fromJson({
        ...json,
        'memberCount': count,
      });
    }).toList();
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

  Future<void> deleteOrganization(String id) async {
    final response = await _client
        .from('organizations')
        .delete()
        .eq('id', id)
        .select();
    
    if (response == null || (response as List).isEmpty) {
      throw Exception('Organization not found or you don\'t have permission to delete it');
    }
  }

  Future<List<UserModel>> getOrganizationMembers(String orgId) async {
    final response = await _client
        .from('organization_members')
        .select('''
          *,
          user:users (
            *,
            program:programs!users_program_id_fkey (name),
            faculty:faculties!users_faculty_id_fkey (name)
          ),
          role:roles (name)
        ''')
        .eq('organization_id', orgId);
    
    final Map<String, UserModel> uniqueUsers = {};
    for (var json in (response as List)) {
      final userData = json['user'];
      if (userData == null) continue;
      
      final roleData = json['role'];
      final roleName = roleData != null ? roleData['name'] : 'Member';
      
      final programData = userData['program'];
      final facultyData = userData['faculty'];
      
      final user = UserModel.fromJson({
        ...userData,
        'role': roleName,
        'programName': programData?['name'],
        'facultyName': facultyData?['name'],
        'joined_at': json['joined_at'],
      });
      
      if (user.id != null) {
        uniqueUsers[user.id!] = user;
      }
    }
    
    return uniqueUsers.values.toList();
  }

  Future<List<OrganizationMembershipModel>> getOrganizationOfficers(String orgId) async {
    final response = await _client
        .from('organization_members')
        .select('''
          *,
          user:users (*),
          role:roles (*),
          term:academic_terms (*)
        ''')
        .eq('organization_id', orgId)
        .not('role_id', 'is', null)
        .order('assigned_at', ascending: false);
    
    return (response as List).map((json) {
      return OrganizationMembershipModel.fromJson({
        ...json,
        'user': json['user'],
        'term': json['term'],
        'role_name': json['role']?['name'],
        'hierarchy_level': json['role']?['hierarchy_level'],
      });
    }).toList();
  }

  Future<void> assignOfficer({
    required String userId,
    required String orgId,
    required String roleId,
    required String termId,
    required String assignedBy,
  }) async {
    await _client.rpc(
      'assign_organization_officer',
      params: {
        'p_org_id': orgId,
        'p_user_id': userId,
        'p_role_id': roleId,
        'p_term_id': termId,
        'p_assigned_by': assignedBy,
      },
    );
  }

  Future<List<OrganizationModel>> getUserOrganizations(String userId) async {
    final response = await _client
        .from('organization_members')
        .select('*, organizations(*)')
        .eq('user_id', userId);
    
    final List<OrganizationModel> organizations = [];
    
    for (var json in (response as List)) {
      if (json['organizations'] != null) {
        organizations.add(OrganizationModel.fromJson(json['organizations'] as Map<String, dynamic>));
      }
    }
    
    return organizations;
  }
}
