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
            clearance_period_end,
            restrict_clearance_request
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
      final restrictClearanceRequest = settings?['restrict_clearance_request'] as bool? ?? false;
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
        'restrict_clearance_request': restrictClearanceRequest,
        'clearance_period_start': clearancePeriodStartStr,
        'clearance_period_end': clearancePeriodEndStr,
        'is_clearance_active': isClearanceActive,
      });
    }).toList();
  }

  Future<OrganizationModel?> getOrganizationById(String id) async {
    final response = await _client.rpc('get_workspace_by_id', params: {'p_workspace_id': id});
    if (response == null || (response as List).isEmpty) return null;
    
    final workspaceJson = response.first as Map<String, dynamic>;
    final type = workspaceJson['type'] as String? ?? 'campus-based';
    
    if (type == 'campus-based' || type == 'faculty-based' || type == 'program-based') {
      final settingsResponseList = await _client
          .from('organization_settings')
          .select('''
            requires_adviser_signature,
            requires_dean_signature,
            requires_program_head_signature,
            allow_member_to_print,
            clearance_period_start,
            clearance_period_end,
            restrict_clearance_request
          ''')
          .eq('organization_id', id)
          .limit(1);

      final settings = settingsResponseList.isEmpty ? null : settingsResponseList.first as Map<String, dynamic>;
      final requiresAdviser = settings?['requires_adviser_signature'] as bool? ?? false;
      final requiresProgramHead = settings?['requires_program_head_signature'] as bool? ?? false;
      final requiresFacultyDean = settings?['requires_dean_signature'] as bool? ?? false;
      final allowMemberCardPrinting = settings?['allow_member_to_print'] as bool? ?? true;
      final restrictClearanceRequest = settings?['restrict_clearance_request'] as bool? ?? false;
      final clearancePeriodStartStr = settings?['clearance_period_start'] as String?;
      final clearancePeriodEndStr = settings?['clearance_period_end'] as String?;
      
      final now = DateTime.now();
      bool isClearanceActive = false;
      if (clearancePeriodStartStr != null && clearancePeriodEndStr != null) {
        final start = DateTime.parse(clearancePeriodStartStr);
        final end = DateTime.parse(clearancePeriodEndStr);
        isClearanceActive = now.isAfter(start) && now.isBefore(end);
      }

      final orgResponseList = await _client
          .from('organizations')
          .select('''
            adviser_name,
            programs (
              program_head:users!program_head_id (first_name, last_name)
            ),
            faculties (
              dean:users!dean_id (first_name, last_name)
            )
          ''')
          .eq('id', id)
          .limit(1);
      
      final orgResponse = orgResponseList.isEmpty ? null : orgResponseList.first;
      final adviserName = orgResponse?['adviser_name'] as String?;
      
      String? programHeadName;
      final programData = orgResponse?['programs'];
      if (programData != null) {
        final headData = programData['program_head'];
        if (headData != null) {
          final fName = headData['first_name'] as String?;
          final lName = headData['last_name'] as String?;
          if (fName != null || lName != null) {
            programHeadName = '${fName ?? ''} ${lName ?? ''}'.trim();
          }
        }
      }

      String? deanName;
      final facultyData = orgResponse?['faculties'];
      if (facultyData != null) {
        final deanData = facultyData['dean'];
        if (deanData != null) {
          final fName = deanData['first_name'] as String?;
          final lName = deanData['last_name'] as String?;
          if (fName != null || lName != null) {
            deanName = '${fName ?? ''} ${lName ?? ''}'.trim();
          }
        }
      }

      return OrganizationModel.fromJson({
        ...workspaceJson,
        if (adviserName != null) 'adviser_name': adviserName,
        if (programHeadName != null) 'program_head_name': programHeadName,
        if (deanName != null) 'dean_name': deanName,
        'requires_adviser_signature': requiresAdviser,
        'requires_program_head_signature': requiresProgramHead,
        'requires_faculty_dean_signature': requiresFacultyDean,
        'allow_member_card_printing': allowMemberCardPrinting,
        'restrict_clearance_request': restrictClearanceRequest,
        'clearance_period_start': clearancePeriodStartStr,
        'clearance_period_end': clearancePeriodEndStr,
        'is_clearance_active': isClearanceActive,
      });
    } else if (type == 'comselec') {
      final settingsResponseList = await _client
          .from('comselec_settings')
          .select('''
            requires_chairman_signature,
            requires_commissioner_signature,
            allow_member_to_print,
            clearance_period_start,
            clearance_period_end
          ''')
          .eq('comselec_id', id)
          .limit(1);

      final settings = settingsResponseList.isEmpty ? null : settingsResponseList.first as Map<String, dynamic>;
      final requiresChairman = settings?['requires_chairman_signature'] as bool? ?? false;
      final requiresCommissioner = settings?['requires_commissioner_signature'] as bool? ?? false;
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
        ...workspaceJson,
        'requires_adviser_signature': requiresChairman,
        'requires_program_head_signature': requiresCommissioner,
        'requires_faculty_dean_signature': false,
        'allow_member_card_printing': allowMemberCardPrinting,
        'clearance_period_start': clearancePeriodStartStr,
        'clearance_period_end': clearancePeriodEndStr,
        'is_clearance_active': isClearanceActive,
      });
    } else {
      return OrganizationModel.fromJson({
        ...workspaceJson,
        'requires_adviser_signature': false,
        'requires_program_head_signature': false,
        'requires_faculty_dean_signature': false,
        'allow_member_card_printing': false,
        'is_clearance_active': false,
      });
    }
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
      } else if (key == 'restrict_clearance_request') {
        settingsData['restrict_clearance_request'] = value;
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
    final isComselecResponse = await _client
        .from('comselecs')
        .select('id')
        .eq('id', orgId)
        .limit(1);
    final isComselec = isComselecResponse.isNotEmpty;

    if (isComselec) {
      final response = await _client
          .from('comselec_members')
          .select('''
            *,
            user:users (
              *,
              program:programs!users_program_id_fkey (name),
              faculty:faculties!users_faculty_id_fkey (name)
            ),
            role:roles (name)
          ''')
          .eq('comselec_id', orgId);
      
      final Map<String, UserModel> uniqueUsers = {};
      for (var json in (response as List)) {
        final userData = json['user'];
        if (userData == null) continue;
        
        final roleData = json['role'];
        final roleName = roleData != null ? roleData['name'] : 'Voters';
        
        final programData = userData['program'];
        final facultyData = userData['faculty'];
        
        final user = UserModel.fromJson({
          ...userData,
          'role': roleName,
          'programName': programData?['name'],
          'facultyName': facultyData?['name'],
          'joined_at': json['joined_at'] ?? json['assigned_at'],
        });
        
        if (user.id != null) {
          uniqueUsers[user.id!] = user;
        }
      }
      return uniqueUsers.values.toList();
    }

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
    final isComselecResponse = await _client
        .from('comselecs')
        .select('id')
        .eq('id', orgId)
        .limit(1);
    final isComselec = isComselecResponse.isNotEmpty;

    if (isComselec) {
      final response = await _client
          .from('comselec_members')
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
          .eq('comselec_id', orgId)
          .not('role_id', 'is', null)
          .order('assigned_at', ascending: false);
      
      return (response as List).map((json) {
        final roleData = json['role'];
        final List<String> permissions = [];
        
        if (roleData != null) {
          final rolePerms = roleData['role_permissions'] as List?;
          if (rolePerms != null) {
            for (var rp in rolePerms) {
              final perm = rp['permissions'];
              if (perm is Map && perm.containsKey('action')) {
                permissions.add(perm['action'] as String);
              } else if (perm is List && perm.isNotEmpty) {
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
    String? workspaceType,
  }) async {
    if (workspaceType == 'comselec') {
      await _client.rpc(
        'assign_comselec_officer',
        params: {
          'p_comselec_id': orgId,
          'p_user_id': userId,
          'p_role_id': roleId,
          'p_term_id': termId,
          'p_assigned_by': assignedBy,
        },
      );
    } else {
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
  }

  Future<List<OrganizationModel>> getUserOrganizations(String userId) async {
    final response = await _client.rpc('get_my_workspaces');
    final List<OrganizationModel> workspaces = [];

    for (var json in (response as List)) {
      final type = json['type'] as String? ?? 'campus-based';
      final id = json['id'] as String;
      
      if (type == 'campus-based' || type == 'faculty-based' || type == 'program-based') {
        final settingsResponseList = await _client
            .from('organization_settings')
            .select('''
              requires_adviser_signature,
              requires_dean_signature,
              requires_program_head_signature,
              allow_member_to_print,
              clearance_period_start,
              clearance_period_end
            ''')
            .eq('organization_id', id)
            .limit(1);

        final settings = settingsResponseList.isEmpty ? null : settingsResponseList.first as Map<String, dynamic>;
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

        final orgResponseList = await _client
            .from('organizations')
            .select('adviser_name')
            .eq('id', id)
            .limit(1);
        final orgResponse = orgResponseList.isEmpty ? null : orgResponseList.first;
        final adviserName = orgResponse?['adviser_name'] as String?;

        workspaces.add(OrganizationModel.fromJson({
          ...json,
          if (adviserName != null) 'adviser_name': adviserName,
          'requires_adviser_signature': requiresAdviser,
          'requires_program_head_signature': requiresProgramHead,
          'requires_faculty_dean_signature': requiresFacultyDean,
          'allow_member_card_printing': allowMemberCardPrinting,
          'clearance_period_start': clearancePeriodStartStr,
          'clearance_period_end': clearancePeriodEndStr,
          'is_clearance_active': isClearanceActive,
        }));
      } else if (type == 'comselec') {
        final settingsResponseList = await _client
            .from('comselec_settings')
            .select('''
              requires_chairman_signature,
              requires_commissioner_signature,
              allow_member_to_print,
              clearance_period_start,
              clearance_period_end
            ''')
            .eq('comselec_id', id)
            .limit(1);

        final settings = settingsResponseList.isEmpty ? null : settingsResponseList.first as Map<String, dynamic>;
        final requiresChairman = settings?['requires_chairman_signature'] as bool? ?? false;
        final requiresCommissioner = settings?['requires_commissioner_signature'] as bool? ?? false;
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

        workspaces.add(OrganizationModel.fromJson({
          ...json,
          'requires_adviser_signature': requiresChairman,
          'requires_program_head_signature': requiresCommissioner,
          'requires_faculty_dean_signature': false,
          'allow_member_card_printing': allowMemberCardPrinting,
          'clearance_period_start': clearancePeriodStartStr,
          'clearance_period_end': clearancePeriodEndStr,
          'is_clearance_active': isClearanceActive,
        }));
      } else {
        workspaces.add(OrganizationModel.fromJson({
          ...json,
          'requires_adviser_signature': false,
          'requires_program_head_signature': false,
          'requires_faculty_dean_signature': false,
          'allow_member_card_printing': false,
          'is_clearance_active': false,
        }));
      }
    }
    
    return workspaces;
  }

  Future<OrganizationMembershipModel?> getUserMembershipInOrg(String userId, String orgId) async {
    final responseList = await _client
        .from('organization_members')
        .select('''
          *,
          role:roles (
            *,
            role_permissions (
              permissions (action)
            )
          )
        ''')
        .eq('user_id', userId)
        .eq('organization_id', orgId)
        .limit(1);
        
    if (responseList.isEmpty) return null;
    final response = responseList.first;
    
    final roleData = response['role'];
    final List<String> permissions = [];
    if (roleData != null) {
      final rolePerms = roleData['role_permissions'] as List?;
      if (rolePerms != null) {
        for (var rp in rolePerms) {
          final perm = rp['permissions'];
          if (perm is Map && perm.containsKey('action')) {
            permissions.add(perm['action'] as String);
          } else if (perm is List && perm.isNotEmpty) {
            final action = perm.first['action'];
            if (action != null) {
              permissions.add(action as String);
            }
          }
        }
      }
    }
    
    return OrganizationMembershipModel.fromJson({
      ...response,
      'role_name': roleData?['name'],
      'hierarchy_level': roleData?['hierarchy_level'],
      'permissions': permissions,
    });
  }

  Future<List<OrganizationSettingsHistoryModel>> getOrganizationSettingsHistory(String orgId) async {
    final response = await _client
        .from('organization_settings_history')
        .select()
        .eq('organization_id', orgId)
        .order('changed_at', ascending: false);
    
    return (response as List).map((json) => OrganizationSettingsHistoryModel.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>?> getWorkspaceRoleAndPermissions(String workspaceId, String workspaceType) async {
    final response = await _client.rpc(
      'get_workspace_role_and_permissions',
      params: {
        'p_workspace_id': workspaceId,
        'p_workspace_type': workspaceType,
      },
    );
    if (response is List && response.isNotEmpty) {
      return response.first as Map<String, dynamic>;
    }
    return null;
  }
}

