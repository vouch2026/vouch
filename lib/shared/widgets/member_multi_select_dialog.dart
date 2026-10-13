import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/scope_obligation.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/campuses/providers/campus_provider.dart';
import '../../features/faculties/providers/faculty_provider.dart';
import '../../features/programs/providers/program_provider.dart';
import '../../features/schools/providers/school_provider.dart';
import '../../features/schools/providers/school_scope_provider.dart';
import '../../features/users/providers/users_provider.dart';

/// Combined obligation pick returned on Confirm: whole-unit scope picks
/// (live rules — future joiners included) plus explicitly excepted members.
/// Empty (no units) = legacy, all in scope obligated; exceptions alone never
/// break legacy. [memberCount] is the obligated total at Confirm time, for
/// display only (callers must not persist it as membership data).
class ScopedMemberSelection {
  final List<ScopeTarget> scopeTargets;
  final Set<String> excludedIds;
  final int memberCount;

  const ScopedMemberSelection({
    this.scopeTargets = const [],
    this.excludedIds = const {},
    this.memberCount = 0,
  });
}

/// Obligated-scope picker: whole units (Campus / Faculty / Program,
/// optionally year-narrowed) plus per-member exceptions.
///
/// Visibility is always the organization itself (handled by callers via the
/// org-derived scope); this dialog only decides OBLIGATION. No per-user
/// inclusion list: picks are live rules, so late joiners are covered.
class MemberMultiSelectDialog extends ConsumerStatefulWidget {
  final String orgType;
  final String? orgId;
  final String? orgSchoolId;
  final String? orgCampusId;
  final String? orgFacultyId;
  final String? orgProgramId;
  final List<ScopeTarget> initialScopeTargets;
  final Set<String> initialExcludedIds;
  final String title;
  final String obligationLabel;

  const MemberMultiSelectDialog({
    super.key,
    this.orgType = 'program-based',
    this.orgId,
    this.orgSchoolId,
    this.orgCampusId,
    this.orgFacultyId,
    this.orgProgramId,
    this.initialScopeTargets = const [],
    this.initialExcludedIds = const {},
    this.title = 'Select Members',
    this.obligationLabel = 'obligated',
  });

  @override
  ConsumerState<MemberMultiSelectDialog> createState() =>
      _MemberMultiSelectDialogState();
}

class _MemberMultiSelectDialogState
    extends ConsumerState<MemberMultiSelectDialog> {
  late Set<ScopeTarget> _scopeTargets;
  late Set<String> _excludedIds;
  final Map<String, String> _excludedNames = {};
  String _searchQuery = '';

  String? _schoolId;
  String? _campusId;
  String? _facultyId;
  String? _programId;
  int? _yearFilter;
  bool _initialized = false;
  bool _presetApplied = false;
  Map<String, dynamic>? _preset;

  bool get _isSchoolOrg =>
      widget.orgType == 'school-based' || widget.orgType == 'school';

  bool get _isCampusOrg =>
      widget.orgType == 'campus-based' || widget.orgType == 'institutional';

  bool get _isFacultyOrg =>
      widget.orgType == 'faculty-based' || widget.orgType == 'faculty';

  bool get _isComselec => widget.orgType == 'comselec';

  bool get _showCampusRow => _isSchoolOrg;
  bool get _showFacultyRow =>
      _isSchoolOrg || _isCampusOrg || _isFacultyOrg || _isComselec;
  bool get _showProgramRow =>
      _isSchoolOrg || _isCampusOrg || _isFacultyOrg || _isComselec;

  String get _presetKey => 'last_obligation_${widget.orgId ?? 'org'}';

  @override
  void initState() {
    super.initState();
    _scopeTargets = Set<ScopeTarget>.from(widget.initialScopeTargets);
    _excludedIds = Set<String>.from(widget.initialExcludedIds);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
  }

  Future<void> _prefill() async {
    if (_initialized || !mounted) return;
    _initialized = true;
    String? schoolId = widget.orgSchoolId;
    if (_isSchoolOrg && schoolId == null) {
      try {
        final schools = await ref.read(schoolsProvider.future);
        if (schools.isNotEmpty) schoolId = schools.first.id;
      } catch (_) {}
    }
    String? campusId = widget.orgCampusId;
    String? facultyId = widget.orgFacultyId;
    String? programId = widget.orgProgramId;
    // Restore the finder position from whole-unit picks (edit mode).
    try {
      for (final s in _scopeTargets) {
        if (s.scopeType == 'Program' && programId == null) {
          programId = s.scopeId;
          final programs = await ref.read(programsProvider.future);
          for (final p in programs) {
            if (p.id == s.scopeId) {
              facultyId ??= p.facultyId;
              break;
            }
          }
        } else if (s.scopeType == 'Faculty' && facultyId == null) {
          facultyId = s.scopeId;
        } else if (s.scopeType == 'Institutional' && campusId == null) {
          campusId = s.scopeId;
        }
      }
      if (facultyId != null && campusId == null) {
        final faculties = await ref.read(facultiesProvider.future);
        for (final f in faculties) {
          if (f.id == facultyId) {
            campusId = f.campusId;
            break;
          }
        }
      }
    } catch (_) {}
    // Resolve excepted names for display.
    try {
      if (_excludedIds.isNotEmpty) {
        final all = await ref.read(allUsersProvider.future);
        for (final u in all) {
          if (u.id != null && _excludedIds.contains(u.id)) {
            _excludedNames[u.id!] = u.fullName;
          }
        }
      }
    } catch (_) {}
    // Repeat-last preset (only offered when starting empty).
    try {
      final box = Hive.box('settings');
      final raw = box.get(_presetKey);
      if (raw is Map) _preset = Map<String, dynamic>.from(raw);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _schoolId = schoolId;
      _campusId = campusId;
      _facultyId = facultyId;
      _programId = programId;
    });
  }

  /// Org-wide scope for the exceptions search + coverage counts.
  ({String scopeType, String? scopeId}) _orgScope() {
    if (_isSchoolOrg && _schoolId != null) {
      return (scopeType: 'School', scopeId: _schoolId);
    }
    if (_isSchoolOrg) return (scopeType: 'All', scopeId: null);
    if (_isCampusOrg || (_isComselec && widget.orgCampusId != null)) {
      final id = widget.orgCampusId ?? _campusId;
      if (id != null) return (scopeType: 'Institutional', scopeId: id);
    }
    if (_isFacultyOrg && widget.orgFacultyId != null) {
      return (scopeType: 'Faculty', scopeId: widget.orgFacultyId);
    }
    if (widget.orgProgramId != null) {
      return (scopeType: 'Program', scopeId: widget.orgProgramId);
    }
    return (scopeType: 'All', scopeId: null);
  }

  void _toggleScopeTarget(ScopeTarget target) {
    setState(() {
      if (_scopeTargets.contains(target)) {
        _scopeTargets.remove(target);
      } else {
        _scopeTargets.add(target);
      }
    });
  }

  ScopeTarget _unitPick(String scopeType, String scopeId) {
    return ScopeTarget(
      scopeType: scopeType,
      scopeId: scopeId,
      yearLevel: _yearFilter,
    );
  }

  void _applyPreset() {
    final preset = _preset;
    if (preset == null) return;
    final scopes = <ScopeTarget>[];
    final rawScopes = preset['scopes'];
    if (rawScopes is List) {
      for (final r in rawScopes) {
        try {
          scopes.add(ScopeTarget.fromJson(
              Map<String, dynamic>.from(r as Map)));
        } catch (_) {}
      }
    }
    final excluded = <String>{};
    final rawExcluded = preset['excluded'];
    if (rawExcluded is Map) {
      for (final k in rawExcluded.keys) {
        excluded.add(k.toString());
        final v = rawExcluded[k];
        if (v is String && v.isNotEmpty) _excludedNames[k.toString()] = v;
      }
    } else if (rawExcluded is List) {
      for (final e in rawExcluded) {
        excluded.add(e.toString());
      }
    }
    setState(() {
      _scopeTargets = scopes.toSet();
      _excludedIds = excluded;
      _presetApplied = true;
    });
  }

  void _savePreset() {
    try {
      Hive.box('settings').put(_presetKey, {
        'scopes': [
          for (final s in _scopeTargets)
            {
              'scope_type': s.scopeType,
              'scope_id': s.scopeId,
              if (s.yearLevel != null) 'year_level': s.yearLevel,
            },
        ],
        'excluded': {
          for (final id in _excludedIds) id: _excludedNames[id] ?? '',
        },
      });
    } catch (_) {}
  }

  String _unitName(
      String id, List<dynamic> campuses, List<dynamic> faculties, List<dynamic> programs) {
    for (final list in [campuses, faculties, programs]) {
      for (final u in list) {
        try {
          if ((u as dynamic).id == id) {
            return (((u as dynamic).name ?? id) as String);
          }
        } catch (_) {}
      }
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final orgScope = _orgScope();
    final AsyncValue<List<UserModel>> orgMembersAsync =
        orgScope.scopeId == null
            ? ref.watch(allUsersProvider)
            : ref.watch(usersInScopeProvider(
                (scopeType: orgScope.scopeType, scopeId: orgScope.scopeId!)));

    final campusesAsync = ref.watch(campusesProvider);
    final campusSchoolMapAsync = ref.watch(campusSchoolMapProvider);
    final allFaculties = ref.watch(facultiesProvider).valueOrNull ?? [];
    final allPrograms = ref.watch(programsProvider).valueOrNull ?? [];
    final allCampuses = campusesAsync.valueOrNull ?? [];

    final showPreset = _preset != null &&
        !_presetApplied &&
        _scopeTargets.isEmpty &&
        _excludedIds.isEmpty;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Container(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration:
            const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            const Icon(Icons.group_add_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    'Visible to all organization members. Only picked units are ${widget.obligationLabel} — future joiners included.',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showPreset)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _applyPreset,
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text('Repeat last selection'),
                    ),
                  ),
                ),
              _buildYearFilter(),
              const SizedBox(height: AppSpacing.sm),
              _buildCascade(
                allCampuses: allCampuses,
                campusMap: campusSchoolMapAsync.valueOrNull ?? {},
              ),
              if (_scopeTargets.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final s in _scopeTargets)
                      InputChip(
                        label: Text(
                          s.labelOf(
                            campusName: _unitName(s.scopeId, allCampuses,
                                allFaculties, allPrograms),
                            facultyName: _unitName(s.scopeId, allCampuses,
                                allFaculties, allPrograms),
                            programName: _unitName(s.scopeId, allCampuses,
                                allFaculties, allPrograms),
                          ),
                          style: AppTextStyles.labelSmall
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        avatar: const Icon(Icons.groups_rounded, size: 14),
                        onDeleted: () => _toggleScopeTarget(s),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              _buildExceptions(orgMembersAsync),
              const SizedBox(height: AppSpacing.sm),
              _buildCoverage(orgMembersAsync),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _scopeTargets.isEmpty && _excludedIds.isEmpty
              ? null
              : () {
                  setState(() {
                    _scopeTargets.clear();
                    _excludedIds.clear();
                    _excludedNames.clear();
                  });
                },
          child: const Text('Clear'),
        ),
        FilledButton(
          onPressed: () {
            _savePreset();
            final members = orgMembersAsync.valueOrNull;
            Navigator.pop(
              context,
              ScopedMemberSelection(
                scopeTargets: _scopeTargets.toList(),
                excludedIds: Set<String>.from(_excludedIds),
                memberCount:
                    members == null ? 0 : _coveredCount(members),
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Builder(
            builder: (context) {
              final members = orgMembersAsync.valueOrNull;
              if (members == null) return const Text('Confirm');
              final total = _coveredCount(members);
              return Text('Confirm ($total member${total == 1 ? '' : 's'})');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearFilter() {
    return DropdownButtonFormField<int>(
      value: _yearFilter,
      items: const [
        DropdownMenuItem<int>(value: null, child: Text('All year levels')),
        DropdownMenuItem<int>(value: 1, child: Text('1st Year')),
        DropdownMenuItem<int>(value: 2, child: Text('2nd Year')),
        DropdownMenuItem<int>(value: 3, child: Text('3rd Year')),
        DropdownMenuItem<int>(value: 4, child: Text('4th Year')),
        DropdownMenuItem<int>(value: 5, child: Text('5th Year')),
      ],
      onChanged: (val) => setState(() => _yearFilter = val),
      decoration: const InputDecoration(
        labelText: 'Year level (optional)',
        hintText: 'Applies to new whole-unit picks',
      ),
    );
  }

  Widget _buildCascade({
    required List<dynamic> allCampuses,
    required Map<String, String> campusMap,
  }) {
    // No school picker: the org's school is fixed silently (_schoolId from
    // prefill), so school-based orgs start directly at Campus, campus-based
    // at Faculty, faculty-based at Program.
    String nameOf(dynamic u) {
      try {
        return (((u as dynamic).name ?? '') as String);
      } catch (_) {
        return '';
      }
    }

    String idOf(dynamic u) {
      try {
        return (((u as dynamic).id ?? '') as String);
      } catch (_) {
        return '';
      }
    }

    Widget campusDropdown() {
      var visible = allCampuses;
      if (_schoolId != null && campusMap.isNotEmpty) {
        visible = allCampuses
            .where((c) {
              try {
                return campusMap[(c as dynamic).id] == _schoolId;
              } catch (_) {
                return false;
              }
            })
            .toList();
      }
      return Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _campusId,
              items: visible
                  .map((c) => DropdownMenuItem<String>(
                      value: idOf(c), child: Text(nameOf(c))))
                  .toList(),
              onChanged: (val) => setState(() {
                _campusId = val;
                _facultyId = null;
                _programId = null;
              }),
              decoration: const InputDecoration(
                labelText: 'Campus',
                hintText: 'Select campus to narrow',
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _wholeUnitToggle(
            enabled: _campusId != null,
            active: _scopeTargets.any((s) =>
                s.scopeType == 'Institutional' && s.scopeId == _campusId),
            onTap: _campusId == null
                ? null
                : () => _toggleScopeTarget(
                    _unitPick('Institutional', _campusId!)),
          ),
        ],
      );
    }

    Widget facultyDropdown() {
      final faculties = _campusId != null
          ? (ref.watch(facultiesByCampusProvider(_campusId!)).valueOrNull ??
              [])
          : [];
      return Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _facultyId,
              items: [
                const DropdownMenuItem<String>(
                    value: null, child: Text('All faculties')),
                ...faculties.map((f) => DropdownMenuItem<String>(
                    value: idOf(f), child: Text(nameOf(f)))),
              ],
              onChanged: (val) => setState(() {
                _facultyId = val;
                _programId = null;
              }),
              decoration:
                  const InputDecoration(labelText: 'Faculty (optional)'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _wholeUnitToggle(
            enabled: _facultyId != null,
            active: _scopeTargets.any((s) =>
                s.scopeType == 'Faculty' && s.scopeId == _facultyId),
            onTap: _facultyId == null
                ? null
                : () => _toggleScopeTarget(
                    _unitPick('Faculty', _facultyId!)),
          ),
        ],
      );
    }

    Widget programDropdown() {
      final programs = _facultyId != null
          ? (ref.watch(programsByFacultyProvider(_facultyId!)).valueOrNull ??
              [])
          : [];
      return Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _programId,
              items: [
                const DropdownMenuItem<String>(
                    value: null, child: Text('All programs')),
                ...programs.map((p) => DropdownMenuItem<String>(
                    value: idOf(p), child: Text(nameOf(p)))),
              ],
              onChanged: (val) => setState(() => _programId = val),
              decoration:
                  const InputDecoration(labelText: 'Program (optional)'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _wholeUnitToggle(
            enabled: _programId != null,
            active: _scopeTargets.any((s) =>
                s.scopeType == 'Program' && s.scopeId == _programId),
            onTap: _programId == null
                ? null
                : () => _toggleScopeTarget(
                    _unitPick('Program', _programId!)),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showCampusRow) ...[
          campusDropdown(),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (_showFacultyRow && _campusId != null) ...[
          facultyDropdown(),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (_showProgramRow && _facultyId != null) ...[
          programDropdown(),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (!_showCampusRow && !_showFacultyRow && !_showProgramRow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Units limited to your program — pick it below or leave empty for all.',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Toggle button for "obligate the entire picked unit".
  Widget _wholeUnitToggle({
    required bool enabled,
    required bool active,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: active
          ? 'Whole unit obligated — tap to remove'
          : 'Obligate the entire picked unit',
      child: FilledButton.tonalIcon(
        onPressed: enabled ? onTap : null,
        icon: Icon(
          active ? Icons.groups_rounded : Icons.group_add_outlined,
          size: 18,
        ),
        label: Text(active ? 'Added' : 'Entire unit'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildExceptions(AsyncValue<List<UserModel>> orgMembersAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Exceptions${_excludedIds.isEmpty ? '' : ' (${_excludedIds.length})'}',
                style: AppTextStyles.labelMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Members picked above stay obligated except these (e.g. transferees).',
          style:
              AppTextStyles.labelSmall.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search name, ID, or email to except',
            prefixIcon: const Icon(Icons.search_rounded),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_excludedIds.isNotEmpty)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final id in _excludedIds)
                InputChip(
                  label: Text(
                    _excludedNames[id] ?? 'Member',
                    style: AppTextStyles.labelSmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  avatar: const Icon(Icons.person_off_outlined, size: 14),
                  onDeleted: () => setState(() {
                    _excludedIds.remove(id);
                    _excludedNames.remove(id);
                  }),
                ),
            ],
          ),
        orgMembersAsync.when(
          data: (users) {
            final filtered = users.where((u) {
              if (u.id == null) return false;
              if (_searchQuery.isEmpty) {
                return _excludedIds.contains(u.id);
              }
              return u.fullName.toLowerCase().contains(_searchQuery) ||
                  u.schoolId.toLowerCase().contains(_searchQuery) ||
                  u.email.toLowerCase().contains(_searchQuery);
            }).toList();
            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _searchQuery.isEmpty
                      ? 'Search above to find members to except.'
                      : 'No members match "$_searchQuery".',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.grey.shade600),
                ),
              );
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final u = filtered[i];
                  final excepted = _excludedIds.contains(u.id);
                  return CheckboxListTile(
                    value: excepted,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    secondary: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        u.fullName.isNotEmpty
                            ? u.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 12),
                      ),
                    ),
                    title: Text(u.fullName,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${u.schoolId} • ${u.email}',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textGrey),
                    ),
                    onChanged: (_) {
                      setState(() {
                        if (u.id == null) return;
                        if (excepted) {
                          _excludedIds.remove(u.id);
                          _excludedNames.remove(u.id);
                        } else {
                          _excludedIds.add(u.id!);
                          _excludedNames[u.id!] = u.fullName;
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Could not load members: $e'),
        ),
      ],
    );
  }

  /// Obligated total for the current picks against [users]. Empty picks =
  /// everyone (legacy default). Shared by the coverage line and Confirm.
  int _coveredCount(List<UserModel> users) {
    if (_scopeTargets.isEmpty) return users.length;
    return users.where((u) {
      if (u.id != null && _excludedIds.contains(u.id)) return false;
      for (final s in _scopeTargets) {
        if (s.matchesUnit(
          campusId: u.campusId,
          facultyId: u.facultyId,
          programId: u.programId,
          year: u.yearLevel,
        )) {
          return true;
        }
      }
      return false;
    }).length;
  }

  Widget _buildCoverage(AsyncValue<List<UserModel>> orgMembersAsync) {
    return orgMembersAsync.when(
      data: (users) {
        final covered = _coveredCount(users);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$covered member${covered == 1 ? '' : 's'} obligated',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_scopeTargets.isNotEmpty)
              Text(
                'New joiners in picked units are included automatically.',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
