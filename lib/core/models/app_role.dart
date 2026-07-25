class AppRole {
  final String roleName;
  final int hierarchyLevel;
  final String scopeType;
  final List<String> permissions;

  AppRole({
    required this.roleName,
    required this.hierarchyLevel,
    required this.scopeType,
    required this.permissions,
  });

  factory AppRole.fromJson(Map<String, dynamic> json) {
    return AppRole(
      roleName: json['role_name'] as String,
      hierarchyLevel: json['hierarchy_level'] as int,
      scopeType: json['scope_type'] as String,
      permissions: List<String>.from(json['permissions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_name': roleName,
      'hierarchy_level': hierarchyLevel,
      'scope_type': scopeType,
      'permissions': permissions,
    };
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((p) => this.permissions.contains(p));
  }
}
