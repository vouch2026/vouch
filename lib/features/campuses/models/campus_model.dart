class CampusModel {
  final String id;
  final String name;
  final String location;
  final String? description;
  final String? schoolId;
  final String? logoUrl;
  final String? bannerUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CampusModel({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    this.schoolId,
    this.logoUrl,
    this.bannerUrl,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  CampusModel copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? schoolId,
    String? logoUrl,
    String? bannerUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CampusModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      schoolId: schoolId ?? this.schoolId,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CampusModel.fromJson(Map<String, dynamic> json) {
    return CampusModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String? ?? '',
      description: json['description'] as String?,
      schoolId: json['school_id'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'school_id': schoolId,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'status': status,
    };
  }
}
