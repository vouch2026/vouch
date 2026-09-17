class SchoolModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? logoUrl;
  final String status;
  final DateTime? createdAt;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.logoUrl,
    this.status = 'active',
    this.createdAt,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String? ?? 'SCHOOL',
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'logo_url': logoUrl,
      'status': status,
    };
  }
}
