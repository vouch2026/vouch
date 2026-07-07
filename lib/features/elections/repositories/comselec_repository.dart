import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comselec_model.dart';

class ComselecRepository {
  final SupabaseClient _client;

  ComselecRepository(this._client);

  Future<List<ComselecModel>> getComselecs() async {
    final response = await _client
        .from('comselecs')
        .select('''
          *,
          campuses(name),
          comselec_settings (
            requires_chairman_signature,
            requires_commissioner_signature,
            allow_member_to_print,
            clearance_period_start,
            clearance_period_end
          ),
          member_count:comselec_members(count)
        ''')
        .order('name');
    
    return (response as List).map((json) {
      final countData = json['member_count'] as List?;
      final count = (countData != null && countData.isNotEmpty) 
          ? countData.first['count'] as int 
          : 0;
      
      final campusData = json['campuses'] as Map<String, dynamic>?;
      final campusName = campusData?['name'] as String?;
      
      final settingsData = json['comselec_settings'];
      final settings = settingsData is List 
          ? (settingsData.isNotEmpty ? settingsData.first as Map<String, dynamic> : null)
          : settingsData as Map<String, dynamic>?;
      
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

      return ComselecModel.fromJson({
        ...json,
        'memberCount': count,
        'campusName': campusName,
        'requires_chairman_signature': requiresChairman,
        'requires_commissioner_signature': requiresCommissioner,
        'allow_member_card_printing': allowMemberCardPrinting,
        'clearance_period_start': clearancePeriodStartStr,
        'clearance_period_end': clearancePeriodEndStr,
        'is_clearance_active': isClearanceActive,
      });
    }).toList();
  }

  Future<ComselecModel?> getComselecById(String id) async {
    final response = await _client
        .from('comselecs')
        .select('''
          *,
          campuses(name),
          comselec_settings (
            requires_chairman_signature,
            requires_commissioner_signature,
            allow_member_to_print,
            clearance_period_start,
            clearance_period_end
          )
        ''')
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;

    final campusData = response['campuses'] as Map<String, dynamic>?;
    final campusName = campusData?['name'] as String?;

    final settingsData = response['comselec_settings'];
    final settings = settingsData is List 
        ? (settingsData.isNotEmpty ? settingsData.first as Map<String, dynamic> : null)
        : settingsData as Map<String, dynamic>?;
    
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

    return ComselecModel.fromJson({
      ...response,
      'campusName': campusName,
      'requires_chairman_signature': requiresChairman,
      'requires_commissioner_signature': requiresCommissioner,
      'allow_member_card_printing': allowMemberCardPrinting,
      'clearance_period_start': clearancePeriodStartStr,
      'clearance_period_end': clearancePeriodEndStr,
      'is_clearance_active': isClearanceActive,
    });
  }

  Future<String> createComselec({
    required String name,
    required String code,
    required String description,
    String? campusId,
    String? logoUrl,
    String? bannerUrl,
  }) async {
    final response = await _client.rpc(
      'create_comselec_with_members',
      params: {
        'p_name': name,
        'p_code': code,
        'p_description': description,
        'p_campus_id': campusId,
        'p_logo_url': logoUrl,
        'p_banner_url': bannerUrl,
      },
    );
    return response as String;
  }

  Future<void> updateComselec(String id, Map<String, dynamic> data) async {
    final comKeys = ['name', 'code', 'description', 'logo_url', 'banner_url', 'status', 'campus_id'];
    
    final Map<String, dynamic> comData = {};
    final Map<String, dynamic> settingsData = {};

    for (var entry in data.entries) {
      if (comKeys.contains(entry.key)) {
        comData[entry.key] = entry.value;
      } else {
        if (entry.key == 'requires_chairman_signature') {
          settingsData['requires_chairman_signature'] = entry.value;
        } else if (entry.key == 'requires_commissioner_signature') {
          settingsData['requires_commissioner_signature'] = entry.value;
        } else if (entry.key == 'allow_member_card_printing') {
          settingsData['allow_member_to_print'] = entry.value;
        } else if (entry.key == 'clearance_period_start') {
          settingsData['clearance_period_start'] = entry.value;
        } else if (entry.key == 'clearance_period_end') {
          settingsData['clearance_period_end'] = entry.value;
        }
      }
    }

    if (comData.isNotEmpty) {
      await _client.from('comselecs').update(comData).eq('id', id);
    }

    if (settingsData.isNotEmpty) {
      await _client.from('comselec_settings').update(settingsData).eq('comselec_id', id);
    }
  }

  Future<void> deleteComselec(String id) async {
    await _client.from('comselecs').delete().eq('id', id);
  }
}
