class ComselecModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String status;
  final String? campusId;
  final String? campusName;
  final int memberCount;
  final bool requiresChairmanSignature;
  final bool requiresCommissionerSignature;
  final bool allowMemberCardPrinting;
  final DateTime? clearancePeriodStart;
  final DateTime? clearancePeriodEnd;
  final bool isClearanceActive;
  final DateTime? createdAt;

  const ComselecModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.status,
    this.campusId,
    this.campusName,
    this.memberCount = 0,
    this.requiresChairmanSignature = false,
    this.requiresCommissionerSignature = false,
    this.allowMemberCardPrinting = true,
    this.clearancePeriodStart,
    this.clearancePeriodEnd,
    this.isClearanceActive = false,
    this.createdAt,
  });

  factory ComselecModel.fromJson(Map<String, dynamic> json) {
    return ComselecModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      status: json['status'] as String? ?? 'active',
      campusId: json['campus_id'] as String?,
      campusName: json['campusName'] as String?,
      memberCount: json['memberCount'] as int? ?? 0,
      requiresChairmanSignature: json['requires_chairman_signature'] as bool? ?? false,
      requiresCommissionerSignature: json['requires_commissioner_signature'] as bool? ?? false,
      allowMemberCardPrinting: json['allow_member_card_printing'] as bool? ?? true,
      clearancePeriodStart: json['clearance_period_start'] != null
          ? DateTime.parse(json['clearance_period_start'] as String)
          : null,
      clearancePeriodEnd: json['clearance_period_end'] != null
          ? DateTime.parse(json['clearance_period_end'] as String)
          : null,
      isClearanceActive: json['is_clearance_active'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'status': status,
      'campus_id': campusId,
      'campusName': campusName,
      'memberCount': memberCount,
      'requires_chairman_signature': requiresChairmanSignature,
      'requires_commissioner_signature': requiresCommissionerSignature,
      'allow_member_card_printing': allowMemberCardPrinting,
      'clearance_period_start': clearancePeriodStart?.toIso8601String(),
      'clearance_period_end': clearancePeriodEnd?.toIso8601String(),
      'is_clearance_active': isClearanceActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
