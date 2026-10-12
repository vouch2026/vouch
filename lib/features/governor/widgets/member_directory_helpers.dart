import 'dart:typed_data';

import 'package:excel/excel.dart' as excel_lib;
import 'package:flutter/material.dart';

import '../../../core/utils/file_saver_helper.dart';
import '../../auth/models/user_model.dart';
import '../../users/widgets/advanced_user_filter_panel.dart';

/// Shared client-side search / filter / sort / export logic for the
/// workspace Members and Officers directory screens.
///
/// Filter keys used across both screens:
/// - `yearLevel` -> int
/// - `program`   -> String (programName or programCode)
/// - `faculty`   -> String (facultyName or facultyCode)
/// - `status`    -> String (lowercase, e.g. 'active')
/// - `role`      -> String (lowercase role, officers screen only)
class MemberDirectoryHelpers {
  const MemberDirectoryHelpers._();

  static String programKeyOf(UserModel m) =>
      (m.programName?.trim().isNotEmpty == true)
          ? m.programName!.trim()
          : (m.programCode?.trim().isNotEmpty == true
              ? m.programCode!.trim()
              : 'N/A');

  static String facultyKeyOf(UserModel m) =>
      (m.facultyName?.trim().isNotEmpty == true)
          ? m.facultyName!.trim()
          : (m.facultyCode?.trim().isNotEmpty == true
              ? m.facultyCode!.trim()
              : 'N/A');

  static String yearLabel(int year) {
    final suffix = (year >= 11 && year <= 13)
        ? 'th'
        : switch (year % 10) {
            1 => 'st',
            2 => 'nd',
            3 => 'rd',
            _ => 'th',
          };
    return '$year$suffix Year';
  }

  static String capitalize(String value) {
    final v = value.trim();
    if (v.isEmpty) return v;
    return v[0].toUpperCase() + v.substring(1).toLowerCase();
  }

  /// Dynamic filter options derived from the visible rows so the UI never
  /// offers e.g. BSIT when the org has no BSIT members.
  static List<FilterOption> buildMemberFilterOptions(
      List<UserModel> baseMembers) {
    final years = <int>{};
    final programs = <String>{};
    final faculties = <String>{};
    final statuses = <String>{};

    for (final m in baseMembers) {
      if (m.yearLevel != null && m.yearLevel! > 0) years.add(m.yearLevel!);
      final p = programKeyOf(m);
      if (p != 'N/A') programs.add(p);
      final f = facultyKeyOf(m);
      if (f != 'N/A') faculties.add(f);
      statuses.add(m.status.trim().toLowerCase());
    }

    final sortedYears = years.toList()..sort();
    final sortedPrograms = programs.toList()..sort();
    final sortedFaculties = faculties.toList()..sort();
    final sortedStatuses = statuses.toList()..sort();

    return [
      if (sortedYears.isNotEmpty)
        FilterOption(
          label: 'Year Level',
          key: 'yearLevel',
          options: [
            for (final y in sortedYears)
              FilterValue(label: yearLabel(y), value: y),
          ],
        ),
      if (sortedPrograms.isNotEmpty)
        FilterOption(
          label: 'Program',
          key: 'program',
          options: [
            for (final p in sortedPrograms) FilterValue(label: p, value: p),
          ],
        ),
      if (sortedFaculties.isNotEmpty)
        FilterOption(
          label: 'Faculty',
          key: 'faculty',
          options: [
            for (final f in sortedFaculties) FilterValue(label: f, value: f),
          ],
        ),
      if (sortedStatuses.isNotEmpty)
        FilterOption(
          label: 'Status',
          key: 'status',
          options: [
            for (final s in sortedStatuses)
              FilterValue(label: capitalize(s), value: s),
          ],
        ),
    ];
  }

  /// Officers screen adds a dynamic Role filter on top of the member filters.
  static List<FilterOption> buildOfficerFilterOptions(
      List<UserModel> baseOfficers) {
    final options = buildMemberFilterOptions(baseOfficers);
    final roles = <String, String>{}; // lower -> display
    for (final m in baseOfficers) {
      final lower = m.role.trim().toLowerCase();
      if (lower.isEmpty) continue;
      roles.putIfAbsent(lower, () => m.roleDisplay);
    }
    if (roles.isEmpty) return options;
    final sortedKeys = roles.keys.toList()..sort();
    return [
      ...options,
      FilterOption(
        label: 'Role',
        key: 'role',
        options: [
          for (final k in sortedKeys)
            FilterValue(label: roles[k]!, value: k),
        ],
      ),
    ];
  }

  static bool matchesDirectoryFilters(
    UserModel m,
    String query,
    Map<String, dynamic> filters,
  ) {
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final haystacks = [
        m.fullName.toLowerCase(),
        m.email.toLowerCase(),
        m.schoolId.toLowerCase(),
        (m.programName ?? '').toLowerCase(),
        (m.programCode ?? '').toLowerCase(),
      ];
      if (!haystacks.any((h) => h.contains(q))) return false;
    }

    final yearFilter = filters['yearLevel'];
    if (yearFilter != null) {
      final asInt = yearFilter is int
          ? yearFilter
          : int.tryParse(yearFilter.toString());
      if (asInt == null || m.yearLevel != asInt) return false;
    }

    final programFilter = filters['program'];
    if (programFilter != null &&
        programFilter.toString().trim().isNotEmpty) {
      final want = programFilter.toString().trim().toLowerCase();
      final actualName = (m.programName ?? '').trim().toLowerCase();
      final actualCode = (m.programCode ?? '').trim().toLowerCase();
      if (actualName != want && actualCode != want) return false;
    }

    final facultyFilter = filters['faculty'];
    if (facultyFilter != null &&
        facultyFilter.toString().trim().isNotEmpty) {
      final want = facultyFilter.toString().trim().toLowerCase();
      final actualName = (m.facultyName ?? '').trim().toLowerCase();
      final actualCode = (m.facultyCode ?? '').trim().toLowerCase();
      if (actualName != want && actualCode != want) return false;
    }

    final statusFilter = filters['status'];
    if (statusFilter != null &&
        statusFilter.toString().trim().isNotEmpty) {
      if (m.status.trim().toLowerCase() !=
          statusFilter.toString().trim().toLowerCase()) {
        return false;
      }
    }

    final roleFilter = filters['role'];
    if (roleFilter != null && roleFilter.toString().trim().isNotEmpty) {
      if (m.role.trim().toLowerCase() !=
          roleFilter.toString().trim().toLowerCase()) {
        return false;
      }
    }

    return true;
  }

  static List<UserModel> applyDirectorySort(
      List<UserModel> rows, String sortValue) {
    final sorted = List<UserModel>.of(rows);
    switch (sortValue) {
      case 'nameDesc':
        sorted.sort((a, b) =>
            b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()));
        break;
      case 'newest':
        sorted.sort((a, b) => (b.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        break;
      case 'oldest':
        sorted.sort((a, b) => (a.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(b.joinedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        break;
      case 'yearAsc':
        sorted.sort((a, b) => (a.yearLevel ?? 999).compareTo(b.yearLevel ?? 999));
        break;
      case 'yearDesc':
        sorted.sort((a, b) => (b.yearLevel ?? -1).compareTo(a.yearLevel ?? -1));
        break;
      case 'nameAsc':
      default:
        sorted.sort((a, b) =>
            a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
    }
    return sorted;
  }

  static const List<Map<String, String>> sortOptions = [
    {'value': 'nameAsc', 'label': 'Name A–Z'},
    {'value': 'nameDesc', 'label': 'Name Z–A'},
    {'value': 'newest', 'label': 'Newest joined'},
    {'value': 'oldest', 'label': 'Oldest joined'},
    {'value': 'yearAsc', 'label': 'Year ascending'},
    {'value': 'yearDesc', 'label': 'Year descending'},
  ];

  static String describeActiveFilters(
      String query, Map<String, dynamic> filters, List<FilterOption> options) {
    final parts = <String>[];
    if (query.trim().isNotEmpty) parts.add('"${query.trim()}"');
    final labelByKey = <String, Map<String, String>>{};
    for (final opt in options) {
      labelByKey[opt.key] = {
        for (final v in opt.options) v.value.toString(): v.label,
      };
    }
    filters.forEach((key, value) {
      if (value == null) return;
      final asStr = value.toString().trim();
      if (asStr.isEmpty || asStr.toLowerCase() == 'null') return;
      final label = labelByKey[key]?[value.toString()] ?? asStr;
      parts.add(label);
    });
    return parts.join(' • ');
  }

  static Future<void> exportDirectoryExcel(
    BuildContext context,
    List<UserModel> rows,
    String filePrefix,
    String reportTitle,
  ) async {
    try {
      final excel = excel_lib.Excel.createExcel();
      final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[defaultSheet];

      sheet.appendRow([
        excel_lib.TextCellValue('Report Type'),
        excel_lib.TextCellValue(reportTitle),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Export Date'),
        excel_lib.TextCellValue(
            DateTime.now().toLocal().toString().substring(0, 19)),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Total Records'),
        excel_lib.TextCellValue('${rows.length}'),
      ]);
      sheet.appendRow([]);

      sheet.appendRow([
        excel_lib.TextCellValue('Student ID'),
        excel_lib.TextCellValue('Full Name'),
        excel_lib.TextCellValue('Email'),
        excel_lib.TextCellValue('Program'),
        excel_lib.TextCellValue('Year Level'),
        excel_lib.TextCellValue('Faculty'),
        excel_lib.TextCellValue('Role'),
        excel_lib.TextCellValue('Status'),
        excel_lib.TextCellValue('Joined Date'),
      ]);

      for (final user in rows) {
        sheet.appendRow([
          excel_lib.TextCellValue(user.schoolId),
          excel_lib.TextCellValue(user.fullName),
          excel_lib.TextCellValue(user.email),
          excel_lib.TextCellValue(user.programName ?? user.programCode ?? 'N/A'),
          excel_lib.TextCellValue(user.yearLevelDisplay),
          excel_lib.TextCellValue(user.facultyName ?? user.facultyCode ?? 'N/A'),
          excel_lib.TextCellValue(user.roleDisplay),
          excel_lib.TextCellValue(user.status.toUpperCase()),
          excel_lib.TextCellValue(
              user.joinedAt != null ? user.joinedAt!.toLocal().toString().substring(0, 10) : 'N/A'),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception('Failed to encode excel');
      final fileName =
          '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final isSuccess =
          await FileSaverUtil.saveFile(Uint8List.fromList(bytes), fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSuccess
                ? 'Report downloaded successfully!'
                : 'Failed to download report.'),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
