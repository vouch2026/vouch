import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/campuses/providers/campus_provider.dart';
import '../../features/faculties/providers/faculty_provider.dart';
import '../../features/programs/providers/program_provider.dart';
import '../../features/schools/providers/school_provider.dart';
import '../../features/schools/providers/school_scope_provider.dart';

/// Result of a scope pick: broad visibility scope + full hierarchy trail.
/// Callers use [scopeType]/[scopeId] for the event/fee row and the trail for
/// member-picker filtering and display.
class ScopeSelection {
  final String scopeType;
  final String scopeId;
  final String? schoolId;
  final String? campusId;
  final String? facultyId;
  final String? programId;

  const ScopeSelection({
    required this.scopeType,
    required this.scopeId,
    this.schoolId,
    this.campusId,
    this.facultyId,
    this.programId,
  });
}

/// Cascade picker School -> Campus -> Faculty -> Program for event/fee creation.
///
/// The deepest selected level wins (Program > Faculty > Campus > School).
/// Ancestors fixed by the creator's org are prefilled and locked:
/// - campus/faculty/program-based orgs lock their own level and above;
/// - school-based orgs (USC) can target anything, defaulting to their school.
///
/// Set [onChanged] to receive live selections; the parent keeps the latest
/// value for submit. [orgSchoolId] is the raw school_id of a school-based org
/// (OrganizationModel carries no schoolId field yet).
class ScopeSelector extends ConsumerStatefulWidget {
  final String orgType;
  final String? orgSchoolId;
  final String? orgCampusId;
  final String? orgFacultyId;
  final String? orgProgramId;
  final ValueChanged<ScopeSelection?> onChanged;

  const ScopeSelector({
    super.key,
    required this.orgType,
    this.orgSchoolId,
    this.orgCampusId,
    this.orgFacultyId,
    this.orgProgramId,
    required this.onChanged,
  });

  @override
  ConsumerState<ScopeSelector> createState() => _ScopeSelectorState();
}

class _ScopeSelectorState extends ConsumerState<ScopeSelector> {
  String? _schoolId;
  String? _campusId;
  String? _facultyId;
  String? _programId;
  bool _initialized = false;

  bool get _isSchoolOrg =>
      widget.orgType == 'school-based' || widget.orgType == 'school';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
  }

  Future<void> _prefill() async {
    if (_initialized || !mounted) return;
    _initialized = true;
    // Prefill ancestors from org; school default = org school or first school.
    String? schoolId = widget.orgSchoolId;
    if (_isSchoolOrg && schoolId == null) {
      try {
        final schools = await ref.read(schoolsProvider.future);
        if (schools.isNotEmpty) schoolId = schools.first.id;
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _schoolId = schoolId;
      _campusId = widget.orgCampusId;
      _facultyId = widget.orgFacultyId;
      _programId = widget.orgProgramId;
    });
    _emit();
  }

  void _emit() {
    // Deepest selected level wins.
    if (_programId != null) {
      widget.onChanged(ScopeSelection(
        scopeType: 'Program',
        scopeId: _programId!,
        schoolId: _schoolId,
        campusId: _campusId,
        facultyId: _facultyId,
        programId: _programId,
      ));
    } else if (_facultyId != null) {
      widget.onChanged(ScopeSelection(
        scopeType: 'Faculty',
        scopeId: _facultyId!,
        schoolId: _schoolId,
        campusId: _campusId,
        facultyId: _facultyId,
      ));
    } else if (_campusId != null) {
      widget.onChanged(ScopeSelection(
        scopeType: 'Institutional',
        scopeId: _campusId!,
        schoolId: _schoolId,
        campusId: _campusId,
      ));
    } else if (_schoolId != null && _isSchoolOrg) {
      widget.onChanged(ScopeSelection(
        scopeType: 'School',
        scopeId: _schoolId!,
        schoolId: _schoolId,
      ));
    } else {
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolsAsync = ref.watch(schoolsProvider);
    final campusesAsync = ref.watch(campusesProvider);
    final campusSchoolMapAsync = ref.watch(campusSchoolMapProvider);
    final facultiesAsync = _campusId != null
        ? ref.watch(facultiesByCampusProvider(_campusId!))
        : const AsyncValue<List<dynamic>>.data([]);
    final programsAsync = _facultyId != null
        ? ref.watch(programsByFacultyProvider(_facultyId!))
        : const AsyncValue<List<dynamic>>.data([]);

    // Ancestor locks: non-school orgs cannot move above their own level.
    final lockSchool = !_isSchoolOrg;
    final lockCampus = widget.orgCampusId != null && !_isSchoolOrg;
    final lockFaculty = widget.orgFacultyId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Target Scope',
            style: AppTextStyles.labelMedium
                .copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Everyone in scope can view it. Use member selection below to choose who is obligated.',
          style: AppTextStyles.labelSmall
              .copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: AppSpacing.sm),

        // School (locked for non-school orgs: display only when known).
        if (_isSchoolOrg)
          schoolsAsync.when(
            data: (schools) {
              if (schools.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: DropdownButtonFormField<String>(
                  value: _schoolId,
                  items: schools
                      .map((s) => DropdownMenuItem<String>(
                          value: s.id, child: Text(s.displayName)))
                      .toList(),
                  onChanged: (val) => setState(() {
                    _schoolId = val;
                    _campusId = null;
                    _facultyId = null;
                    _programId = null;
                    _emit();
                  }),
                  decoration: const InputDecoration(
                      labelText: 'School', hintText: 'Select school'),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),

        // Campus
        campusesAsync.when(
          data: (campuses) {
            var visible = campuses;
            // Filter by selected school when mapping exists.
            final map = campusSchoolMapAsync.valueOrNull ?? {};
            if (_schoolId != null && map.isNotEmpty) {
              visible = campuses
                  .where((c) => map[c.id] == _schoolId)
                  .toList();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: DropdownButtonFormField<String>(
                value: _campusId,
                items: visible
                    .map((c) => DropdownMenuItem<String>(
                        value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: lockCampus
                    ? null
                    : (val) => setState(() {
                          _campusId = val;
                          _facultyId = null;
                          _programId = null;
                          _emit();
                        }),
                decoration: InputDecoration(
                  labelText: 'Campus',
                  hintText: lockSchool
                      ? 'Fixed by your organization'
                      : 'Select campus (optional narrows scope)',
                ),
              ),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox(),
        ),

        // Faculty (optional narrowing)
        if (_campusId != null)
          facultiesAsync.when(
            data: (faculties) {
              if (faculties.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: DropdownButtonFormField<String>(
                  value: _facultyId,
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('All faculties')),
                    ...faculties.map((f) => DropdownMenuItem<String>(
                        value: f.id, child: Text(f.name))),
                  ],
                  onChanged: lockFaculty
                      ? null
                      : (val) => setState(() {
                            _facultyId = val;
                            _programId = null;
                            _emit();
                          }),
                  decoration: const InputDecoration(
                      labelText: 'Faculty (optional)'),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),

        // Program (optional narrowing)
        if (_facultyId != null)
          programsAsync.when(
            data: (programs) {
              if (programs.isEmpty) return const SizedBox();
              return DropdownButtonFormField<String>(
                value: _programId,
                items: [
                  const DropdownMenuItem<String>(
                      value: null, child: Text('All programs')),
                  ...programs.map((p) => DropdownMenuItem<String>(
                      value: p.id, child: Text(p.name))),
                ],
                onChanged: widget.orgProgramId != null
                    ? null
                    : (val) => setState(() {
                          _programId = val;
                          _emit();
                        }),
                decoration:
                    const InputDecoration(labelText: 'Program (optional)'),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
      ],
    );
  }
}
