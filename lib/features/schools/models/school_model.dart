/// School (university) — top of School -> Campus -> Faculty -> Program.
///
/// Plain hand-written model (no codegen) so the hierarchy can ship without a
/// build_runner cycle. Mirrors the `schools` table from
/// `supabase/migrations/20261012_add_schools.sql`.
class SchoolModel {
  final String id;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final String? bannerUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SchoolModel({
    required this.id,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.bannerUrl,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      status: (json['status'] as String?) ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Payload for inserts (server generates id/timestamps).
  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'short_name': shortName,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'status': status,
    };
  }

  String get displayName =>
      shortName != null && shortName!.isNotEmpty ? shortName! : name;
}
