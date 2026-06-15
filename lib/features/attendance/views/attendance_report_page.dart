import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../events/models/event_model.dart';
import '../providers/attendance_provider.dart';
import '../models/qr_scan_ui_model.dart';
import '../widgets/qr_recent_scan_card.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'dart:typed_data';
import 'package:excel/excel.dart' as excel_lib;
import '../../../core/utils/file_saver_helper.dart';

class AttendanceReportPage extends ConsumerStatefulWidget {
  final EventModel event;

  const AttendanceReportPage({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends ConsumerState<AttendanceReportPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _rawAttendanceData = [];
  List<QrScanUIModel> _allScans = [];
  List<QrScanUIModel> _filteredScans = [];
  List<ExcelRowData> _allExcelRows = [];
  List<ExcelRowData> _filteredExcelRows = [];
  bool _isExcelView = true;
  int _totalStudentsCount = 0;
  bool _isLoading = true;
  String _selectedMode = 'All';
  String _selectedProgram = 'All';

  static const Color primaryColor = Color(0xFF003DA5);

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
    _loadReportData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReportData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(attendanceRepositoryProvider);
      
      // Load both the attendance logs and the total student count in the scope in parallel
      final results = await Future.wait([
        repository.getAllAttendanceForEvent(widget.event.id!, widget.event.scopeType, widget.event.scopeId),
        repository.getStudentsCountForScope(widget.event.scopeType, widget.event.scopeId),
      ]);

      final rawScans = results[0] as List<Map<String, dynamic>>;
      _totalStudentsCount = results[1] as int;
      
      final scans = rawScans.map((data) {
        final student = data['student'] as Map<String, dynamic>?;
        final firstName = student?['first_name'] ?? 'Unknown';
        final lastName = student?['last_name'] ?? 'Student';
        final studentId = student?['student_id_number'] ?? '-';
        final program = (student?['program'] as Map<String, dynamic>?)?['name'] ?? 'N/A';
        
        final timeIn = data['actual_time_in'];
        final timeOut = data['actual_time_out'];
        final time = timeOut ?? timeIn;
        final formattedTime = time != null 
            ? DateFormat('h:mm a').format(DateTime.parse(time).toLocal())
            : '-';
            
        return QrScanUIModel(
          name: '$firstName $lastName',
          studentId: studentId,
          program: program,
          time: formattedTime,
          status: 'success',
          type: timeOut != null ? 'Time Out' : 'Time In',
        );
      }).toList();

      final excelRows = rawScans.map((data) {
        final student = data['student'] as Map<String, dynamic>?;
        final firstName = student?['first_name'] ?? 'Unknown';
        final lastName = student?['last_name'] ?? 'Student';
        final studentId = student?['student_id_number'] ?? '-';
        
        final programData = student?['program'] as Map<String, dynamic>?;
        final programName = programData?['name'] ?? 'N/A';
        final facultyData = programData?['faculty'] as Map<String, dynamic>?;
        final facultyName = facultyData?['name'] ?? 'N/A';
        final yearLevel = student?['year']?.toString() ?? '-';
        
        final timeInRaw = data['actual_time_in'];
        final timeOutRaw = data['actual_time_out'];
        
        final formattedTimeIn = timeInRaw != null
            ? DateFormat('h:mm a').format(DateTime.parse(timeInRaw).toLocal())
            : '-';
        final formattedTimeOut = timeOutRaw != null
            ? DateFormat('h:mm a').format(DateTime.parse(timeOutRaw).toLocal())
            : '-';

        return ExcelRowData(
          studentId: studentId,
          name: '$firstName $lastName',
          faculty: facultyName,
          program: programName,
          yearLevel: yearLevel,
          timeIn: formattedTimeIn,
          timeOut: formattedTimeOut,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _rawAttendanceData = rawScans;
          _allScans = scans;
          _allExcelRows = excelRows;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load attendance report: $e')),
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

      _filteredExcelRows = _allExcelRows.where((row) {
        final matchesQuery = row.name.toLowerCase().contains(query) ||
            row.studentId.toLowerCase().contains(query) ||
            row.program.toLowerCase().contains(query) ||
            row.faculty.toLowerCase().contains(query);
        
        bool matchesMode = true;
        if (_selectedMode == 'Time In') {
          matchesMode = row.timeIn != '-';
        } else if (_selectedMode == 'Time Out') {
          matchesMode = row.timeOut != '-';
        }
        
        final matchesProgram = _selectedProgram == 'All' || row.program == _selectedProgram;

        return matchesQuery && matchesMode && matchesProgram;
      }).toList();
    });
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

  Future<void> _downloadExcelReport() async {
    try {
      final excel = excel_lib.Excel.createExcel();
      final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
      final sheet = excel[defaultSheet];

      // Headers (Metadata)
      sheet.appendRow([
        excel_lib.TextCellValue('Name of event'),
        excel_lib.TextCellValue(widget.event.name),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Date'),
        excel_lib.TextCellValue(DateFormat('yyyy-MM-dd').format(widget.event.eventDate)),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Time in'),
        excel_lib.TextCellValue('${_formatTimeString(widget.event.timeInStart)} - ${_formatTimeString(widget.event.timeInEnd)}'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Time out'),
        excel_lib.TextCellValue('${_formatTimeString(widget.event.timeOutStart)} - ${_formatTimeString(widget.event.timeOutEnd)}'),
      ]);
      sheet.appendRow([]); // space row

      // Table Column Headers
      sheet.appendRow([
        excel_lib.TextCellValue('Student ID'),
        excel_lib.TextCellValue('Student Name'),
        excel_lib.TextCellValue('Faculty'),
        excel_lib.TextCellValue('Program'),
        excel_lib.TextCellValue('Year Level'),
        excel_lib.TextCellValue('Time in'),
        excel_lib.TextCellValue('Time out'),
      ]);

      // Data Rows
      for (final data in _rawAttendanceData) {
        final student = data['student'] as Map<String, dynamic>?;
        final firstName = student?['first_name'] ?? 'Unknown';
        final lastName = student?['last_name'] ?? 'Student';
        final studentId = student?['student_id_number'] ?? '-';
        
        final programData = student?['program'] as Map<String, dynamic>?;
        final programName = programData?['name'] ?? 'N/A';
        final facultyData = programData?['faculty'] as Map<String, dynamic>?;
        final facultyName = facultyData?['name'] ?? 'N/A';
        final yearLevel = student?['year']?.toString() ?? '-';
        
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
          excel_lib.TextCellValue(yearLevel),
          excel_lib.TextCellValue(formattedTimeIn),
          excel_lib.TextCellValue(formattedTimeOut),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception("Failed to encode excel");

      final String fileName = "${widget.event.name.replaceAll(RegExp(r'[^\w\s\-]'), '_')}_Attendance_Report.xlsx";
      
      final isSuccess = await FileSaverUtil.saveFile(Uint8List.fromList(bytes), fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSuccess ? 'Attendance report downloaded successfully!' : 'Failed to download report.'),
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

  @override
  Widget build(BuildContext context) {
    final presentCount = _allScans.length;
    final absentCount = _totalStudentsCount > presentCount ? _totalStudentsCount - presentCount : 0;
    final isMobile = MediaQuery.of(context).size.width < 768;
    return DashboardLayout(
      title: 'Attendance Report',
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: _isLoading
          ? const Center(child: FlickrLoader())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumbs / Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            'Events',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            widget.event.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Attendance Report',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title Section with Download Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance Report',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Attendance summary and statistics for ${widget.event.name}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Analytics KPI and Chart Card
                  _buildAnalyticsSection(presentCount, absentCount),
                  const SizedBox(height: 24),

                  // Search and Filter Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Attendance Logs',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            _buildViewToggle(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by student name, ID or program...',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(LucideIcons.search, size: 20, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter chips and dropdowns
                  _buildFilterSection(),
                  const SizedBox(height: 16),

                  // Scans List or Excel Preview Table
                  _isExcelView
                      ? _buildExcelPreviewTable()
                      : (_filteredScans.isEmpty
                          ? _buildEmptyState()
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              child: Column(
                                children: _filteredScans.map((scan) => QrRecentScanCard(scan: scan)).toList(),
                              ),
                            )),
                ],
              ),
            ),
    );
  }

  Widget _buildAnalyticsSection(int presentCount, int absentCount) {
    final total = _totalStudentsCount > 0 ? _totalStudentsCount : (presentCount + absentCount);
    final presentPercent = total > 0 ? (presentCount / total * 100).round() : 0;
    final absentPercent = total > 0 ? (absentCount / total * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          // KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Students',
                  value: '$total',
                  color: primaryColor,
                  icon: LucideIcons.users,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Present',
                  value: '$presentCount',
                  color: Colors.green,
                  icon: LucideIcons.checkCircle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Absent',
                  value: '$absentCount',
                  color: Colors.red,
                  icon: LucideIcons.xCircle,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Chart Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Pie Chart
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 32,
                          sections: [
                            PieChartSectionData(
                              value: presentCount > 0 ? presentCount.toDouble() : 0.001,
                              color: Colors.green,
                              title: '',
                              radius: 18,
                            ),
                            PieChartSectionData(
                              value: absentCount > 0 ? absentCount.toDouble() : 0.001,
                              color: Colors.red,
                              title: '',
                              radius: 18,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$presentPercent%',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Attendance Rate',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem('Present', Colors.green, presentCount, presentPercent),
                      const SizedBox(height: 6),
                      _buildLegendItem('Absent', Colors.red, absentCount, absentPercent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count, int percent) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          '$count ($percent%)',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
            shadowColor: Colors.black.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: primaryColor.withValues(alpha: 0.05)),
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
            : (isOutline ? Colors.transparent : primaryColor.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? primaryColor 
              : (isOutline ? primaryColor.withValues(alpha: 0.2) : Colors.transparent),
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
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
              color: isSelected ? Colors.white : (isOutline ? primaryColor.withValues(alpha: 0.7) : primaryColor),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            Icon(
              trailingIcon,
              size: 14,
              color: isSelected ? Colors.white : primaryColor.withValues(alpha: 0.7),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchController.text.isEmpty && _selectedMode == 'All' && _selectedProgram == 'All'
                    ? LucideIcons.clipboard
                    : LucideIcons.search,
                size: 60,
                color: primaryColor.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchController.text.isEmpty && _selectedMode == 'All' && _selectedProgram == 'All'
                  ? 'No scans recorded yet'
                  : 'No matching records found',
              style: GoogleFonts.poppins(
                color: Colors.black.withValues(alpha: 0.5),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.poppins(
                color: Colors.black.withValues(alpha: 0.35),
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

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            icon: LucideIcons.list,
            label: 'Card List',
            isSelected: !_isExcelView,
            onTap: () => setState(() => _isExcelView = false),
          ),
          const SizedBox(width: 4),
          _buildToggleOption(
            icon: LucideIcons.sheet,
            label: 'Excel Preview',
            isSelected: _isExcelView,
            onTap: () => setState(() => _isExcelView = true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? primaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExcelPreviewTable() {
    if (_filteredExcelRows.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.04)),
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return primaryColor.withValues(alpha: 0.02);
                    }
                    return null;
                  }),
                  columnSpacing: 24,
                  horizontalMargin: 16,
                  headingRowHeight: 48,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 48,
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
                    verticalInside: BorderSide(color: Colors.grey.shade100, width: 0.5),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Student ID',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Student Name',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Faculty',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Program',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Year Level',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Time In',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Time Out',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                  rows: _filteredExcelRows.map((row) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            row.studentId,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                        DataCell(
                          Text(
                            row.name,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            row.faculty,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                        DataCell(
                          Text(
                            row.program,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                        DataCell(
                          Text(
                            row.yearLevel,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: row.timeIn != '-' ? Colors.green.withValues(alpha: 0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              row.timeIn,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: row.timeIn != '-' ? FontWeight.w600 : FontWeight.normal,
                                color: row.timeIn != '-' ? Colors.green[800] : Colors.black45,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: row.timeOut != '-' ? Colors.green.withValues(alpha: 0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              row.timeOut,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: row.timeOut != '-' ? FontWeight.w600 : FontWeight.normal,
                                color: row.timeOut != '-' ? Colors.green[800] : Colors.black45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ExcelRowData {
  final String studentId;
  final String name;
  final String faculty;
  final String program;
  final String yearLevel;
  final String timeIn;
  final String timeOut;

  ExcelRowData({
    required this.studentId,
    required this.name,
    required this.faculty,
    required this.program,
    required this.yearLevel,
    required this.timeIn,
    required this.timeOut,
  });
}
