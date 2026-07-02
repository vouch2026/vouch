import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/organization_model.dart';
import '../models/organization_membership_model.dart';
import '../models/organization_settings_history_model.dart';
import '../../auth/models/user_model.dart';

class OrganizationRepository {
  final SupabaseClient _client;

  OrganizationRepository(this._client);

  Future<List<OrganizationModel>> getOrganizations() async {
    final response = await _client
        .from('organizations')
        .select('''
          *,
          organization_settings (
            requires_adviser_signature,
            requires_dean_signature,
            requires_program_head_signature,
            allow_member_to_print,
            clearance_period_start,
            clearance_period_end
          ),
          member_count:organization_members(count)
        ''')
        .order('name');
    
    return (response as List).map((json) {
      final countData = json['member_count'] as List?;
      final count = (countData != null && countData.isNotEmpty) 
          ? countData.first['count'] as int 
          : 0;
      
      final settingsData = json['organization_settings'];
      final settings = settingsData is List 
          ? (settingsData.isNotEmpty ? settingsData.first as Map<String, dynamic> : null)
          : settingsData as Map<String, dynamic>?;
      
      final requiresAdviser = settings?['requires_adviser_signature'] as bool? ?? false;
      final requiresProgramHead = settings?['requires_program_head_signature'] as bool? ?? false;
      final requiresFacultyDean = settings?['requires_dean_signature'] as bool? ?? false;
      final allowMemberCardPrinting = settings?['allow_member_to_print'] as bool? ?? true;
      final clearancePeriodStartStr = settings?['clearance_period_start'] as String?;
      final clearancePeriodEndStr = settings?['clearance_period_end'] as String?;
      
      final now = DateTime.now();
      bool isClearanceActive = false;
      if (clearancePeriodStartStr != null && clearancePeriodEndStr != null) {
        final start = DateTime.parse(clearancePeriodStartStr);
        final end = DateTime.parse(clearancePeriodEndStr);
        isClearanceActive = now.isAfter(start) && now.isBefore(end);
      }

      return OrganizationModel.fromJson({
        ...json,
        'memberCount': count,
        'requires_adviser_signature': requiresAdviser,
        'requires_program_head_signature': requiresProgramHead,
        'requires_faculty_dean_signature': requiresFacultyDean,
        'allow_member_card_printing': allowMemberCardPrinting,
        'clearance_period_start': clearancePeriodStartStr,
        'clearance_period_end': clearancePeriodEndStr,
        'is_clearance_active': isClearanceActive,
      });
    }).toList();
  }

  Future<OrganizationModel?> getOrganizationById(String id) async {
    final response = await _client
        .from('organizations')
        .select('''
          *,
          organization_settings (
            requires_adviser_signature,
            requires_dean_signature,
            requires_program_head_signature,
            allow_member_to_print,
            clearance_period_start,
            clearance_period_end
          )
        ''')
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;

    final settingsData = response['organization_settings'];
    final settings = settingsData is List 
        ? (settingsData.isNotEmpty ? settingsData.first as Map<String, dynamic> : null)
        : settingsData as Map<String, dynamic>?;
    
    final requiresAdviser = settings?['requires_adviser_signature'] as bool? ?? false;
    final requiresProgramHead = settings?['requires_program_head_signature'] as bool? ?? false;
    final requiresFacultyDean = settings?['requires_dean_signature'] as bool? ?? false;
    final allowMemberCardPrinting = settings?['allow_member_to_print'] as bool? ?? true;
    final clearancePeriodStartStr = settings?['clearance_period_start'] as String?;
    final clearancePeriodEndStr = settings?['clearance_period_end'] as String?;
    
    final now = DateTime.now();
    bool isClearanceActive = false;
    if (clearancePeriodStartStr != null && clearancePeriodEndStr != null) {
      final start = DateTime.parse(clearancePeriodStartStr);
      final end = DateTime.parse(clearancePeriodEndStr);
      isClearanceActive = now.isAfter(start) && now.isBefore(end);
    }

    return OrganizationModel.fromJson({
      ...response,
      'requires_adviser_signature': requiresAdviser,
      'requires_program_head_signature': requiresProgramHead,
      'requires_faculty_dean_signature': requiresFacultyDean,
      'allow_member_card_printing': allowMemberCardPrinting,
      'clearance_period_start': clearancePeriodStartStr,
      'clearance_period_end': clearancePeriodEndStr,
      'is_clearance_active': isClearanceActive,
    });
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

  Future<void> updateOrganization(String id, Map<String, dynamic> data) async {
    final orgKeys = ['name', 'code', 'description', 'adviser_name', 'logo_url', 'banner_url', 'status', 'type', 'campus_id', 'faculty_id', 'program_id'];
    
    final orgData = <String, dynamic>{};
    final settingsData = <String, dynamic>{};
    
    data.forEach((key, value) {
      if (orgKeys.contains(key)) {
        orgData[key] = value;
      } else if (key == 'requires_adviser_signature') {
        settingsData['requires_adviser_signature'] = value;
      } else if (key == 'requires_program_head_signature') {
        settingsData['requires_program_head_signature'] = value;
      } else if (key == 'requires_faculty_dean_signature') {
        settingsData['requires_dean_signature'] = value;
      } else if (key == 'allow_member_card_printing') {
        settingsData['allow_member_to_print'] = value;
      } else if (key == 'clearance_period_start') {
        settingsData['clearance_period_start'] = value;
      } else if (key == 'clearance_period_end') {
        settingsData['clearance_period_end'] = value;
      }
    });

    if (orgData.isNotEmpty) {
      await _client
          .from('organizations')
          .update(orgData)
          .eq('id', id);
    }
    
    if (settingsData.isNotEmpty) {
      await _client
          .from('organization_settings')
          .upsert({
            'organization_id': id,
            ...settingsData,
          });
    }
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
          role:roles (
            *,
            role_permissions (
              permissions (action)
            )
          ),
          term:academic_terms (*)
        ''')
        .eq('organization_id', orgId)
        .not('role_id', 'is', null)
        .order('assigned_at', ascending: false);
    
    return (response as List).map((json) {
      final roleData = json['role'];
      final List<String> permissions = [];
      
      if (roleData != null) {
        // Try to handle different possible structures from Supabase
        final rolePerms = roleData['role_permissions'] as List?;
        if (rolePerms != null) {
          for (var rp in rolePerms) {
            final perm = rp['permissions'];
            if (perm is Map && perm.containsKey('action')) {
              permissions.add(perm['action'] as String);
            } else if (perm is List && perm.isNotEmpty) {
              // Handle case where it might be returned as a list
              final action = perm.first['action'];
              if (action != null) {
                permissions.add(action as String);
              }
            }
          }
        }
      }

      return OrganizationMembershipModel.fromJson({
        ...json,
        'user': json['user'],
        'term': json['term'],
        'role_name': roleData?['name'],
        'hierarchy_level': roleData?['hierarchy_level'],
        'permissions': permissions,
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
        .select('''
          *, 
          organizations (
            *,
            organization_settings (
              requires_adviser_signature,
              requires_dean_signature,
              requires_program_head_signature,
              allow_member_to_print,
              clearance_period_start,
              clearance_period_end
            )
          )
        ''')
        .eq('user_id', userId);
    
    final List<OrganizationModel> organizations = [];
    
    for (var json in (response as List)) {
      final orgJson = json['organizations'] as Map<String, dynamic>?;
      if (orgJson != null) {
        final settingsData = orgJson['organization_settings'];
        final settings = settingsData is List 
            ? (settingsData.isNotEmpty ? settingsData.first as Map<String, dynamic> : null)
            : settingsData as Map<String, dynamic>?;
        
        final requiresAdviser = settings?['requires_adviser_signature'] as bool? ?? false;
        final requiresProgramHead = settings?['requires_program_head_signature'] as bool? ?? false;
        final requiresFacultyDean = settings?['requires_dean_signature'] as bool? ?? false;
        final allowMemberCardPrinting = settings?['allow_member_to_print'] as bool? ?? true;
        final clearancePeriodStartStr = settings?['clearance_period_start'] as String?;
        final clearancePeriodEndStr = settings?['clearance_period_end'] as String?;
        
        final now = DateTime.now();
        bool isClearanceActive = false;
        if (clearancePeriodStartStr != null && clearancePeriodEndStr != null) {
          final start = DateTime.parse(clearancePeriodStartStr);
          final end = DateTime.parse(clearancePeriodEndStr);
          isClearanceActive = now.isAfter(start) && now.isBefore(end);
        }

        organizations.add(OrganizationModel.fromJson({
          ...orgJson,
          'requires_adviser_signature': requiresAdviser,
          'requires_program_head_signature': requiresProgramHead,
          'requires_faculty_dean_signature': requiresFacultyDean,
          'allow_member_card_printing': allowMemberCardPrinting,
          'clearance_period_start': clearancePeriodStartStr,
          'clearance_period_end': clearancePeriodEndStr,
          'is_clearance_active': isClearanceActive,
        }));
      }
    }
    
    return organizations;
  }

  Future<List<OrganizationSettingsHistoryModel>> getOrganizationSettingsHistory(String orgId) async {
    final response = await _client
        .from('organization_settings_history')
        .select()
        .eq('organization_id', orgId)
        .order('changed_at', ascending: false);
    
    return (response as List).map((json) => OrganizationSettingsHistoryModel.fromJson(json)).toList();
  }
}

