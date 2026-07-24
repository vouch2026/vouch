import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/attendance_provider.dart';
import '../models/qr_scan_ui_model.dart';
import '../widgets/qr_recent_scan_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/file_saver_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../events/models/event_model.dart';
import '../../events/providers/event_provider.dart';
import 'dart:typed_data';
import 'package:excel/excel.dart' as excel_lib;

class AttendanceHistoryPage extends ConsumerStatefulWidget {
  final String eventId;
  final String eventName;
  final String? scannedByUserId;
  final EventModel? event;

  const AttendanceHistoryPage({
    super.key,
    required this.eventId,
    required this.eventName,
    this.scannedByUserId,
    this.event,
  });

  @override
  ConsumerState<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends ConsumerState<AttendanceHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<QrScanUIModel> _allScans = [];
  List<QrScanUIModel> _filteredScans = [];
  List<Map<String, dynamic>> _rawScansData = [];
  EventModel? _event;
  bool _isLoading = true;
  String _selectedMode = 'All';
  String _selectedProgram = 'All';

  static const Color primaryColor = AppColors.primary;
  static const Color accentColor = AppColors.accent;

  List<String> get _availablePrograms {
    final programs = _allScans
        .map((scan) => scan.program.trim())
        .where((p) => p.isNotEmpty && p != 'N/A')
        .toSet()
        .toList()
      ..sort();
    return ['All', ...programs];
  }

  @override
  void initState() {
    super.initState();
    _loadScans();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScans() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(attendanceRepositoryProvider);
      final rawScans = await repository.getRecentScansForEvent(
        widget.eventId,
        scannedByUserId: widget.scannedByUserId,
      );
      _rawScansData = rawScans;
      
      EventModel? event = widget.event;
      if (event == null) {
        event = await ref.read(eventProvider(widget.eventId).future);
      }
      _event = event;
      
      final List<Map<String, dynamic>> extractedScans = [];
      for (final data in rawScans) {
        final student = data['student'] as Map<String, dynamic>?;
        final firstName = student?['first_name'] ?? 'Unknown';
        final lastName = student?['last_name'] ?? 'Student';
        final studentId = student?['student_id_number'] ?? '-';
        final program = (student?['program'] as Map<String, dynamic>?)?['name'] ?? 'N/A';

        final timeInRaw = data['actual_time_in'];
        final timeOutRaw = data['actual_time_out'];

        if (timeInRaw != null) {
          extractedScans.add({
            'name': '$firstName $lastName',
            'studentId': studentId,
            'program': program,
            'dateTime': DateTime.parse(timeInRaw).toLocal(),
            'type': 'Time In',
          });
        }
        if (timeOutRaw != null) {
          extractedScans.add({
            'name': '$firstName $lastName',
            'studentId': studentId,
            'program': program,
            'dateTime': DateTime.parse(timeOutRaw).toLocal(),
            'type': 'Time Out',
          });
        }
      }

      // Sort extractedScans by dateTime descending (newest first)
      extractedScans.sort((a, b) => (b['dateTime'] as DateTime).compareTo(a['dateTime'] as DateTime));

      final scans = extractedScans.map((scanData) {
        return QrScanUIModel(
          name: scanData['name'] as String,
          studentId: scanData['studentId'] as String,
          program: scanData['program'] as String,
          time: DateFormat('h:mm a').format(scanData['dateTime'] as DateTime),
          status: 'success',
          type: scanData['type'] as String,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _allScans = scans;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load scans: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredScans = _allScans.where((scan) {
        final matchesQuery = scan.name.toLowerCase().contains(query) ||
            scan.studentId.toLowerCase().contains(query) ||
            scan.program.toLowerCase().contains(query);
        
        final matchesMode = _selectedMode == 'All' || scan.type == _selectedMode;
        
        final matchesProgram = _selectedProgram == 'All' || scan.program == _selectedProgram;

        return matchesQuery && matchesMode && matchesProgram;
      }).toList();
    });
  }

  Widget _buildCustomAppBar() {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;

    final double topMargin = isMobile ? 8.0 : (isTablet ? 12.0 : 16.0);
    final double bottomMargin = isMobile ? 4.0 : (isTablet ? 6.0 : 8.0);
    final double horizontalMargin = isMobile ? 8.0 : (isTablet ? 12.0 : 16.0);
    final double borderRadius = isMobile ? 12.0 : 16.0;

    return Container(
      margin: EdgeInsets.only(
        top: topMargin,
        left: horizontalMargin,
        right: horizontalMargin,
        bottom: bottomMargin,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: isMobile ? 52.0 : 60.0,
        leading: Center(
          child: Padding(
            padding: EdgeInsets.only(left: isMobile ? 6.0 : 10.0),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Container(
                width: isMobile ? 34 : 38,
                height: isMobile ? 34 : 38,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                  size: isMobile ? 18 : 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        titleSpacing: isMobile ? 4.0 : 8.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.scannedByUserId != null ? 'My Scanned Students' : 'Scan History',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 15 : (isTablet ? 16 : 18),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.eventName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        actions: const [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom AppBar (matches other screens)
              _buildCustomAppBar(),
              
              const SizedBox(height: 8),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Search student name or ID...',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.35), fontSize: 13),
                          prefixIcon: const Icon(LucideIcons.search, size: 19, color: primaryColor),
                          suffixIcon: _searchController.text.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(LucideIcons.xCircle, size: 18, color: Colors.black26),
                                onPressed: () {
                                  _searchController.clear();
                                  _applyFilters();
                                },
                              )
                            : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: primaryColor.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: primaryColor.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: primaryColor, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Filters Section
                  _buildFilterSection(),

                  const SizedBox(height: 16),
                  _buildTableControls(context, isMobile),
                  const SizedBox(height: 12),

                  // Scan List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadScans,
                      color: primaryColor,
                      child: _isLoading
                          ? const Center(child: FlickrLoader())
                          : _filteredScans.isEmpty
                              ? _buildEmptyState()
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (constraints.maxWidth < 800) {
                                      return ListView.builder(
                                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, 24),
                                        itemCount: _filteredScans.length,
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return QrRecentScanCard(scan: _filteredScans[index]);
                                        },
                                      );
                                    }
                                    return SingleChildScrollView(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(bottom: 24),
                                      child: _buildScanTable(context, _filteredScans),
                                    );
                                  },
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All Scans',
            isSelected: _selectedMode == 'All',
            onTap: () => setState(() {
              _selectedMode = 'All';
              _applyFilters();
            }),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Time In',
            isSelected: _selectedMode == 'Time In',
            onTap: () => setState(() {
              _selectedMode = 'Time In';
              _applyFilters();
            }),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Time Out',
            isSelected: _selectedMode == 'Time Out',
            onTap: () => setState(() {
              _selectedMode = 'Time Out';
              _applyFilters();
            }),
          ),
          const SizedBox(width: 8),
          
          // Program Dropdown Filter
          PopupMenuButton<String>(
            onSelected: (String program) {
              setState(() {
                _selectedProgram = program;
                _applyFilters();
              });
            },
            offset: const Offset(0, 45),
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: primaryColor.withOpacity(0.05)),
            ),
            itemBuilder: (BuildContext context) {
              return _availablePrograms.map((String program) {
                final isItemSelected = _selectedProgram == program;
                return PopupMenuItem<String>(
                  value: program,
                  height: 42,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          program == 'All' ? 'All Programs' : program,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isItemSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isItemSelected ? primaryColor : Colors.black87,
                          ),
                        ),
                      ),
                      if (isItemSelected)
                        const Icon(LucideIcons.checkCircle, size: 16, color: primaryColor),
                    ],
                  ),
                );
              }).toList();
            },
            child: _buildFilterChip(
              label: _selectedProgram == 'All' ? 'Program' : _selectedProgram,
              isSelected: _selectedProgram != 'All',
              trailingIcon: LucideIcons.chevronDown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
    bool isOutline = false,
    IconData? trailingIcon,
  }) {
    final chipContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? primaryColor 
            : (isOutline ? Colors.transparent : primaryColor.withOpacity(0.06)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? primaryColor 
              : (isOutline ? primaryColor.withOpacity(0.2) : Colors.transparent),
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : (isOutline ? primaryColor.withOpacity(0.7) : primaryColor),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            Icon(
              trailingIcon,
              size: 14,
              color: isSelected ? Colors.white : primaryColor.withOpacity(0.7),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chipContent,
      );
    }
    
    return chipContent;
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchController.text.isEmpty && _selectedMode == 'All' && _selectedProgram == 'All'
                    ? LucideIcons.clipboard
                    : LucideIcons.search,
                size: 60,
                color: primaryColor.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchController.text.isEmpty && _selectedMode == 'All' && _selectedProgram == 'All'
                  ? 'No scans recorded yet'
                  : 'No matching records found',
              style: GoogleFonts.poppins(
                color: Colors.black.withOpacity(0.5),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.poppins(
                color: Colors.black.withOpacity(0.35),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!(_searchController.text.isEmpty && _selectedMode == 'All' && _selectedProgram == 'All'))
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedMode = 'All';
                      _selectedProgram = 'All';
                      _applyFilters();
                    });
                  },
                  child: const Text(
                    'Clear all filters',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanTable(BuildContext context, List<QrScanUIModel> data) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceVariant.withValues(alpha: 0.3)),
            columns: const [
              DataColumn(label: Text('Student ID')),
              DataColumn(label: Text('Full Name')),
              DataColumn(label: Text('Program')),
              DataColumn(label: Text('Time')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Status')),
            ],
            rows: data.map((scan) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(scan.studentId, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  DataCell(
                    Text(scan.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  DataCell(
                    Text(scan.program, style: AppTextStyles.bodySmall),
                  ),
                  DataCell(
                    Text(scan.time, style: AppTextStyles.bodySmall),
                  ),
                  DataCell(
                    _TypeBadge(type: scan.type),
                  ),
                  DataCell(
                    _StatusBadge(status: scan.status),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadExcelReport() async {
    try {
      EventModel? event = _event;
      if (event == null) {
        event = await ref.read(eventProvider(widget.eventId).future);
      }
      if (event == null) throw Exception("Event details not found");

      final currentUser = ref.read(userProfileProvider).value;
      final scannerName = currentUser?.fullName ?? 'Unknown';
      final scannerId = currentUser?.schoolId ?? '-';
      final eventStatus = event.isPastTimeout ? 'Completed' : 'Active';

      final excel = excel_lib.Excel.createExcel();
      final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[defaultSheet];

      // Headers (Metadata)
      sheet.appendRow([
        excel_lib.TextCellValue('Name of Event'),
        excel_lib.TextCellValue(event.name),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Location'),
        excel_lib.TextCellValue(event.location),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Time in'),
        excel_lib.TextCellValue('${_formatTimeString(event.timeInStart)} - ${_formatTimeString(event.timeInEnd)}'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Time out'),
        excel_lib.TextCellValue('${_formatTimeString(event.timeOutStart)} - ${_formatTimeString(event.timeOutEnd)}'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Scanned By'),
        excel_lib.TextCellValue('$scannerName : $scannerId'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Status'),
        excel_lib.TextCellValue(eventStatus),
      ]);
      sheet.appendRow([]); // space row

      // Table Column Headers
      sheet.appendRow([
        excel_lib.TextCellValue('Id no.'),
        excel_lib.TextCellValue('Name'),
        excel_lib.TextCellValue('Faculty'),
        excel_lib.TextCellValue('program'),
        excel_lib.TextCellValue('Time in'),
        excel_lib.TextCellValue('Time out'),
      ]);

      // Data Rows
      for (final data in _rawScansData) {
        final student = data['student'] as Map<String, dynamic>?;
        final firstName = student?['first_name'] ?? 'Unknown';
        final lastName = student?['last_name'] ?? 'Student';
        final studentId = student?['student_id_number'] ?? '-';
        
        final programData = student?['program'] as Map<String, dynamic>?;
        final programName = programData?['name'] ?? 'N/A';
        final facultyData = programData?['faculty'] as Map<String, dynamic>?;
        final facultyName = facultyData?['name'] ?? 'N/A';
        
        final timeInRaw = data['actual_time_in'];
        final timeOutRaw = data['actual_time_out'];

        final formattedTimeIn = timeInRaw != null
            ? DateFormat('h:mm a').format(DateTime.parse(timeInRaw).toLocal())
            : '-';
        final formattedTimeOut = timeOutRaw != null
            ? DateFormat('h:mm a').format(DateTime.parse(timeOutRaw).toLocal())
            : '-';

        sheet.appendRow([
          excel_lib.TextCellValue(studentId),
          excel_lib.TextCellValue('$firstName $lastName'),
          excel_lib.TextCellValue(facultyName),
          excel_lib.TextCellValue(programName),
          excel_lib.TextCellValue(formattedTimeIn),
          excel_lib.TextCellValue(formattedTimeOut),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception("Failed to encode excel");

      final String fileName = "${event.name.replaceAll(RegExp(r'[^\w\s\-]'), '_')}_My_Scans_Report.xlsx";
      
      final isSuccess = await FileSaverUtil.saveFile(Uint8List.fromList(bytes), fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSuccess ? 'Scan report downloaded successfully!' : 'Failed to download report.'),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2026, 1, 1, hour, minute);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return timeStr;
    }
  }

  Widget _buildTableControls(BuildContext context, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total Count Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              '${_filteredScans.length} Total',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          
          // Download Excel Button
          if (_allScans.isNotEmpty)
            FilledButton.icon(
              onPressed: _downloadExcelReport,
              icon: const Icon(LucideIcons.download, size: 16),
              label: Text(
                isMobile ? 'Export' : 'Download Excel',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'success':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'error':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case 'Time In':
        color = Colors.blue;
        break;
      case 'Time Out':
        color = Colors.purple;
        break;
      default:
        color = Colors.indigo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
