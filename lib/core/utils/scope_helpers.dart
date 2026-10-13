import '../../features/organizations/models/organization_model.dart';

/// Single source of truth for org-type -> event/fee/announcement scope mapping.
///
/// Types:
/// - `school-based`  -> scope_type `School`, id = schoolId (e.g. USC spans all
///   campuses of a school).
/// - `campus-based` / `institutional` -> scope_type `Institutional`, campusId.
/// - `faculty-based` / `faculty`      -> scope_type `Faculty`, facultyId.
/// - everything else (program-based, comselec, ...) -> `Program`, programId.
///
/// `comselec` orgs carry a campusId in this codebase, so they resolve to
/// `Institutional` via the campus branch below only when explicitly passed as
/// campus-based; otherwise they fall to Program only if programId is set.
/// Callers must handle a null scopeId (misconfigured org) by returning [].
String resolveScopeType(OrganizationModel org) {
  if (org.type == 'school-based' || org.type == 'school') return 'School';
  final isInstitutional =
      org.type == 'campus-based' || org.type == 'institutional';
  final isFaculty = org.type == 'faculty-based' || org.type == 'faculty';
  if (isInstitutional) return 'Institutional';
  if (isFaculty) return 'Faculty';
  return 'Program';
}

/// Scope id matching [resolveScopeType]. Returns null when the org does not
/// carry the id required for its type (caller should treat as "no scope").
String? resolveScopeId(OrganizationModel org) {
  final scopeType = resolveScopeType(org);
  switch (scopeType) {
    case 'School':
      // OrganizationModel is freezed without schoolId yet; read raw extra via
      // campus fallback chain is handled by callers that have the raw row.
      // For typed orgs, schoolId arrives via [resolveScopeIdRaw].
      return null;
    case 'Institutional':
      return org.campusId;
    case 'Faculty':
      return org.facultyId;
    case 'Program':
      return org.programId;
    default:
      return null;
  }
}

/// Raw-map variant for rows that include `school_id` (org queries that select
/// the new column, school-based orgs, USC).
String? resolveScopeIdRaw(Map<String, dynamic> orgRow) {
  final type = (orgRow['type'] as String?) ?? 'campus-based';
  if (type == 'school-based' || type == 'school') {
    return orgRow['school_id'] as String?;
  }
  if (type == 'campus-based' || type == 'institutional') {
    return orgRow['campus_id'] as String?;
  }
  if (type == 'faculty-based' || type == 'faculty') {
    return orgRow['faculty_id'] as String?;
  }
  return orgRow['program_id'] as String?;
}

/// Typed-org scope resolution including school-based orgs whose schoolId is
/// supplied separately (until OrganizationModel gains a schoolId field).
({String scopeType, String? scopeId}) resolveScope(
  OrganizationModel org, {
  String? schoolId,
}) {
  final scopeType = resolveScopeType(org);
  if (scopeType == 'School') return (scopeType: scopeType, scopeId: schoolId);
  return (scopeType: scopeType, scopeId: resolveScopeId(org));
}
