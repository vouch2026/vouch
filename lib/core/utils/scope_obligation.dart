/// Bulk scope-level obligation picks shared by events and fees.
///
/// Obligation contract (20261014 legacy rule, extended by 20261020 scope
/// targets and 20261021 exceptions + year narrowing):
/// - no rows in user/scope/exception tables = legacy, everyone obligated;
/// - otherwise obligated = (listed user OR member of a picked unit at a
///   matching year) AND NOT explicitly excepted. Exclusions never break
///   legacy on their own.
///
/// Scope values reuse the parent-row convention: 'Institutional' matches the
/// user's campus, 'Faculty' the faculty, 'Program' the program.

/// A whole-unit obligation pick: an entire campus / faculty / program,
/// optionally narrowed to one year level (null = all years).
class ScopeTarget {
  final String scopeType;
  final String scopeId;
  final int? yearLevel;

  const ScopeTarget({
    required this.scopeType,
    required this.scopeId,
    this.yearLevel,
  });

  factory ScopeTarget.fromJson(Map<String, dynamic> json) {
    final year = json['year_level'];
    return ScopeTarget(
      scopeType: json['scope_type'] as String,
      scopeId: json['scope_id'] as String,
      yearLevel: year == null ? null : (year as num).toInt(),
    );
  }

  Map<String, dynamic> toInsertJson(String parentKey, String parentId) {
    return {
      parentKey: parentId,
      'scope_type': scopeType,
      'scope_id': scopeId,
      if (yearLevel != null) 'year_level': yearLevel,
    };
  }

  /// Human label given optional resolved unit names.
  String labelOf({
    String? campusName,
    String? facultyName,
    String? programName,
  }) {
    String base;
    switch (scopeType) {
      case 'Institutional':
        base = 'All of ${campusName ?? 'campus'}';
      case 'Faculty':
        base = 'All of ${facultyName ?? 'faculty'}';
      case 'Program':
        base = 'All of ${programName ?? 'program'}';
      default:
        base = 'All of unit';
    }
    if (yearLevel != null && yearLevel! > 0) {
      base += ' • ${_yearSuffix(yearLevel!)}';
    }
    return base;
  }

  static String _yearSuffix(int year) {
    final suffix = (year >= 11 && year <= 13)
        ? 'th'
        : switch (year % 10) {
            1 => 'st',
            2 => 'nd',
            3 => 'rd',
            _ => 'th',
          };
    return '$year$suffix yr';
  }

  bool matchesUnit({
    String? campusId,
    String? facultyId,
    String? programId,
    int? year,
  }) {
    if (yearLevel != null && yearLevel! > 0 && year != yearLevel) {
      return false;
    }
    switch (scopeType) {
      case 'Institutional':
        return campusId != null && campusId == scopeId;
      case 'Faculty':
        return facultyId != null && facultyId == scopeId;
      case 'Program':
        return programId != null && programId == scopeId;
      default:
        return false;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScopeTarget &&
          runtimeType == other.runtimeType &&
          scopeType == other.scopeType &&
          scopeId == other.scopeId &&
          yearLevel == other.yearLevel;

  @override
  int get hashCode => Object.hash(scopeType, scopeId, yearLevel);
}

/// Combined obligation rule for one event/fee.
/// A null rule (absent from bulk maps) also means legacy.
class ObligationRule {
  /// Explicitly listed user ids, null when the parent has no user rows.
  final Set<String>? userIds;

  /// Whole-unit picks (empty when the parent has no scope rows).
  final List<ScopeTarget> scopes;

  /// Explicitly excepted user ids (empty when no exception rows).
  final Set<String> excludedUserIds;

  const ObligationRule({
    this.userIds,
    this.scopes = const [],
    this.excludedUserIds = const {},
  });

  const ObligationRule.legacy() : this();

  bool get isLegacy => userIds == null && scopes.isEmpty;

  bool covers({
    String? userId,
    String? campusId,
    String? facultyId,
    String? programId,
    int? yearLevel,
  }) {
    if (isLegacy) return true;
    if (userId != null && excludedUserIds.contains(userId)) return false;
    if (userId != null && (userIds?.contains(userId) ?? false)) {
      return true;
    }
    for (final s in scopes) {
      if (s.matchesUnit(
        campusId: campusId,
        facultyId: facultyId,
        programId: programId,
        year: yearLevel,
      )) {
        return true;
      }
    }
    return false;
  }
}

/// Standalone check for call sites holding raw target data.
bool isObligated({
  String? userId,
  String? campusId,
  String? facultyId,
  String? programId,
  int? yearLevel,
  Set<String>? individualIds,
  List<ScopeTarget> scopeTargets = const [],
  Set<String> excludedIds = const {},
  required bool hasAnyTargetRows,
}) {
  if (!hasAnyTargetRows) return true;
  return ObligationRule(
    userIds: individualIds,
    scopes: scopeTargets,
    excludedUserIds: excludedIds,
  ).covers(
    userId: userId,
    campusId: campusId,
    facultyId: facultyId,
    programId: programId,
    yearLevel: yearLevel,
  );
}
