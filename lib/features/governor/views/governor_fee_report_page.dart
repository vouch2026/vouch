import 'dart:typed_data';
import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/file_saver_helper.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../finance/models/fee_model.dart';

class GovernorFeeReportPage extends ConsumerStatefulWidget {
  final FeeModel fee;

  const GovernorFeeReportPage({
    super.key,
    required this.fee,
  });

  @override
  ConsumerState<GovernorFeeReportPage> createState() => _GovernorFeeReportPageState();
}

class _GovernorFeeReportPageState extends ConsumerState<GovernorFeeReportPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FeeStudentRowData> _allRows = [];
  List<FeeStudentRowData> _filteredRows = [];
  bool _isLoading = true;
  bool _isExcelView = true;
  String _selectedStatus = 'All'; // All, Paid, Pending, Unpaid
  String _selectedProgram = 'All';

  static const Color primaryColor = Color(0xFF003DA5);

  List<String> get _availablePrograms {
    final programs = _allRows
        .map((row) => row.program.trim())
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
      final client = Supabase.instance.client;
      final scopeType = widget.fee.scopeType;
      final scopeId = widget.fee.scopeId;

      String orgField;
      String orgType;
      if (scopeType == 'Institutional') {
        orgField = 'campus_id';
        orgType = 'campus-based';
      } else if (scopeType == 'Faculty') {
        orgField = 'faculty_id';
        orgType = 'faculty-based';
      } else {
        orgField = 'program_id';
        orgType = 'program-based';
      }

      // 1. Fetch all active members/students in the scope
      final results = await Future.wait([
        client.from('organization_members').select('''
          id,
          user:users!inner (
            id,
            first_name,
            last_name,
            student_id_number,
            program:programs!users_program_id_fkey (
              name,
              faculty:faculties!programs_faculty_id_fkey (
                name
              )
            ),
            year
          ),
          role:roles!inner (
            name
          ),
          organization:organizations!inner (
            type,
            $orgField
          )
        ''')
        .eq('status', 'active')
        .eq('user.account_status', 'active')
        .eq('role.name', 'Member')
        .eq('organization.type', orgType)
        .eq('organization.$orgField', scopeId),
        
        client.from('student_payments').select('''
          *,
          receiver:payment_receiver (
            bank_type
          )
        ''')
        .eq('fee_id', widget.fee.id!)
      ]);

      final studentsList = List<Map<String, dynamic>>.from(results[0] as List);
      final paymentsList = List<Map<String, dynamic>>.from(results[1] as List);

      final List<FeeStudentRowData> rows = [];
      for (final member in studentsList) {
        final userData = member['user'] as Map<String, dynamic>?;
        if (userData == null) continue;

        final userUuid = userData['id'] as String;
        final studentId = userData['student_id_number'] ?? '-';
        final firstName = userData['first_name'] ?? 'Unknown';
        final lastName = userData['last_name'] ?? 'Student';
        final name = '$firstName $lastName';
        
        final programData = userData['program'] as Map<String, dynamic>?;
        final programName = programData?['name'] ?? 'N/A';
        final facultyData = programData?['faculty'] as Map<String, dynamic>?;
        final facultyName = facultyData?['name'] ?? 'N/A';
        final yearLevel = userData['year']?.toString() ?? '-';

        // Find the payment submission for this student
        final payment = paymentsList.where((p) => p['student_id'] == userUuid).firstOrNull;

        String status = 'Unpaid';
        String amountText = '₱${widget.fee.amount.toStringAsFixed(2)}';
        String referenceNo = '-';
        String paymentMethod = '-';
        String paidAtText = '-';

        if (payment != null) {
          final paymentStatus = payment['status'] as String? ?? 'Pending';
          if (paymentStatus == 'Paid') {
            status = 'Paid';
            paidAtText = payment['paid_at'] != null 
                ? DateFormat('yMMMd').add_jm().format(DateTime.parse(payment['paid_at']).toLocal())
                : '-';
          } else if (paymentStatus == 'Pending') {
            status = 'Pending';
          } else if (paymentStatus == 'Rejected') {
            status = 'Unpaid'; // Rejected payment counts as Unpaid
          }
          referenceNo = payment['reference_number'] ?? '-';
          paymentMethod = (payment['receiver'] as Map<String, dynamic>?)?['bank_type'] ?? payment['payment_method'] ?? '-';
        }

        rows.add(FeeStudentRowData(
          userUuid: userUuid,
          studentId: studentId,
          name: name,
          faculty: facultyName,
          program: programName,
          yearLevel: yearLevel,
          amount: amountText,
          paidAt: paidAtText,
          referenceNo: referenceNo,
          paymentMethod: paymentMethod,
          status: status,
        ));
      }

      // Sort rows alphabetically by name
      rows.sort((a, b) => a.name.compareTo(b.name));

      if (mounted) {
        setState(() {
          _allRows = rows;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load report data: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRows = _allRows.where((row) {
        final matchesQuery = row.name.toLowerCase().contains(query) ||
            row.studentId.toLowerCase().contains(query) ||
            row.program.toLowerCase().contains(query);
        
        final matchesStatus = _selectedStatus == 'All' || row.status == _selectedStatus;
        final matchesProgram = _selectedProgram == 'All' || row.program == _selectedProgram;

        return matchesQuery && matchesStatus && matchesProgram;
      }).toList();
    });
  }

  Future<void> _downloadExcelReport() async {
    try {
      final excel = excel_lib.Excel.createExcel();
      final defaultSheet = excel.getDefaultSheet()!;
      final sheet = excel[defaultSheet];

      // Headers (Metadata)
      sheet.appendRow([
        excel_lib.TextCellValue('Fee Name'),
        excel_lib.TextCellValue(widget.fee.name),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Description'),
        excel_lib.TextCellValue(widget.fee.description ?? ''),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Required Amount'),
        excel_lib.TextCellValue('₱${widget.fee.amount.toStringAsFixed(2)}'),
      ]);
      sheet.appendRow([
        excel_lib.TextCellValue('Due Date'),
        excel_lib.TextCellValue(DateFormat('yyyy-MM-dd').format(widget.fee.dueDate)),
      ]);
      sheet.appendRow([]); // space row

      // Table Column Headers
      sheet.appendRow([
        excel_lib.TextCellValue('Student ID'),
        excel_lib.TextCellValue('Student Name'),
        excel_lib.TextCellValue('Faculty'),
        excel_lib.TextCellValue('Program'),
        excel_lib.TextCellValue('Year Level'),
        excel_lib.TextCellValue('Amount'),
        excel_lib.TextCellValue('Payment Method'),
        excel_lib.TextCellValue('Reference Number'),
        excel_lib.TextCellValue('Date Paid'),
        excel_lib.TextCellValue('Status'),
      ]);

      // Data Rows
      for (final row in _filteredRows) {
        sheet.appendRow([
          excel_lib.TextCellValue(row.studentId),
          excel_lib.TextCellValue(row.name),
          excel_lib.TextCellValue(row.faculty),
          excel_lib.TextCellValue(row.program),
          excel_lib.TextCellValue(row.yearLevel),
          excel_lib.TextCellValue(row.amount),
          excel_lib.TextCellValue(row.paymentMethod),
          excel_lib.TextCellValue(row.referenceNo),
          excel_lib.TextCellValue(row.paidAt),
          excel_lib.TextCellValue(row.status),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) throw Exception("Failed to encode excel");

      final String fileName = "${widget.fee.name.replaceAll(RegExp(r'[^\w\s\-]'), '_')}_Payment_Report.xlsx";
      final isSuccess = await FileSaverUtil.saveFile(Uint8List.fromList(bytes), fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSuccess ? 'Payment report downloaded successfully!' : 'Failed to download report.'),
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

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final paidCount = _allRows.where((row) => row.status == 'Paid').length;
    final pendingCount = _allRows.where((row) => row.status == 'Pending').length;
    final unpaidCount = _allRows.where((row) => row.status == 'Unpaid').length;
    final totalCount = _allRows.length;

    final isMobile = MediaQuery.of(context).size.width < 768;

    return DashboardLayout(
      title: 'Payment Report',
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      children: [
                        Icon(Icons.payments_outlined, size: 14, color: Colors.grey[500]),
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
                            'Fees',
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
                            'Manage Fees',
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
                            'Payment Report',
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

                  // Header View Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Report',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Collection summary and statistics for ${widget.fee.name}',
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
                  _buildAnalyticsSection(paidCount, pendingCount, unpaidCount, totalCount),
                  const SizedBox(height: 24),

                  // Search and Filter Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Collection Logs',
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

                  // Filter chips
                  _buildFilterSection(),
                  const SizedBox(height: 16),

                  // Table or Card List
                  _isExcelView
                      ? _buildExcelPreviewTable()
                      : (_filteredRows.isEmpty
                          ? _buildEmptyState()
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              child: Column(
                                children: _filteredRows.map((row) => _buildStudentCard(row)).toList(),
                              ),
                            )),
                ],
              ),
            ),
    );
  }

  Widget _buildAnalyticsSection(int paidCount, int pendingCount, int unpaidCount, int totalCount) {
    final paidPercent = totalCount > 0 ? (paidCount / totalCount * 100).round() : 0;
    final pendingPercent = totalCount > 0 ? (pendingCount / totalCount * 100).round() : 0;
    final unpaidPercent = totalCount > 0 ? (unpaidCount / totalCount * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          // KPI Cards Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                return Column(
                  children: [
                    _buildKpiCard(
                      title: 'Total Students',
                      value: '$totalCount',
                      color: primaryColor,
                      icon: LucideIcons.users,
                    ),
                    const SizedBox(height: 10),
                    _buildKpiCard(
                      title: 'Paid',
                      value: '$paidCount',
                      color: Colors.green,
                      icon: LucideIcons.checkCircle2,
                    ),
                    const SizedBox(height: 10),
                    _buildKpiCard(
                      title: 'Pending Approval',
                      value: '$pendingCount',
                      color: Colors.orange,
                      icon: LucideIcons.clock,
                    ),
                    const SizedBox(height: 10),
                    _buildKpiCard(
                      title: 'Unpaid',
                      value: '$unpaidCount',
                      color: Colors.red,
                      icon: LucideIcons.xCircle,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Total Students',
                      value: '$totalCount',
                      color: primaryColor,
                      icon: LucideIcons.users,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Paid',
                      value: '$paidCount',
                      color: Colors.green,
                      icon: LucideIcons.checkCircle2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Pending',
                      value: '$pendingCount',
                      color: Colors.orange,
                      icon: LucideIcons.clock,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Unpaid',
                      value: '$unpaidCount',
                      color: Colors.red,
                      icon: LucideIcons.xCircle,
                    ),
                  ),
                ],
              );
            },
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
                              value: paidCount > 0 ? paidCount.toDouble() : 0.001,
                              color: Colors.green,
                              title: '',
                              radius: 18,
                            ),
                            PieChartSectionData(
                              value: pendingCount > 0 ? pendingCount.toDouble() : 0.001,
                              color: Colors.orange,
                              title: '',
                              radius: 18,
                            ),
                            PieChartSectionData(
                              value: unpaidCount > 0 ? unpaidCount.toDouble() : 0.001,
                              color: Colors.red,
                              title: '',
                              radius: 18,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$paidPercent%',
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
                        'Payment Rate',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem('Paid', Colors.green, paidCount, paidPercent),
                      const SizedBox(height: 6),
                      _buildLegendItem('Pending', Colors.orange, pendingCount, pendingPercent),
                      const SizedBox(height: 6),
                      _buildLegendItem('Unpaid', Colors.red, unpaidCount, unpaidPercent),
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
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, int count, int percent) {
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
        Text(
          '$title ($count)',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          '$percent%',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
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

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          // Filter by Status
          PopupMenuButton<String>(
            onSelected: (val) {
              setState(() {
                _selectedStatus = val;
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
              return ['All', 'Paid', 'Pending', 'Unpaid'].map((status) {
                final isItemSelected = _selectedStatus == status;
                return PopupMenuItem<String>(
                  value: status,
                  height: 42,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          status == 'All' ? 'All Statuses' : status,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isItemSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isItemSelected ? primaryColor : Colors.black87,
                          ),
                        ),
                      ),
                      if (isItemSelected)
                        const Icon(LucideIcons.checkCircle2, size: 16, color: primaryColor),
                    ],
                  ),
                );
              }).toList();
            },
            child: _buildFilterChip(
              label: _selectedStatus == 'All' ? 'Status' : _selectedStatus,
              isSelected: _selectedStatus != 'All',
              trailingIcon: LucideIcons.chevronDown,
            ),
          ),
          const SizedBox(width: 8),

          // Filter by Program
          PopupMenuButton<String>(
            onSelected: (val) {
              setState(() {
                _selectedProgram = val;
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
                        const Icon(LucideIcons.checkCircle2, size: 16, color: primaryColor),
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
                _searchController.text.isEmpty && _selectedStatus == 'All' && _selectedProgram == 'All'
                    ? LucideIcons.receipt
                    : LucideIcons.search,
                size: 60,
                color: primaryColor.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchController.text.isEmpty && _selectedStatus == 'All' && _selectedProgram == 'All'
                  ? 'No collection logs found'
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
            if (!(_searchController.text.isEmpty && _selectedStatus == 'All' && _selectedProgram == 'All'))
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedStatus = 'All';
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

  Widget _buildExcelPreviewTable() {
    if (_filteredRows.isEmpty) {
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
                        'Amount',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Method',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Reference No.',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Date Paid',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                  rows: _filteredRows.map((row) {
                    Color statusChipColor;
                    Color statusTextColor;
                    switch (row.status) {
                      case 'Paid':
                        statusChipColor = Colors.green.withValues(alpha: 0.1);
                        statusTextColor = Colors.green.shade900;
                        break;
                      case 'Pending':
                        statusChipColor = Colors.orange.withValues(alpha: 0.1);
                        statusTextColor = Colors.orange.shade900;
                        break;
                      default:
                        statusChipColor = Colors.red.withValues(alpha: 0.1);
                        statusTextColor = Colors.red.shade900;
                    }

                    return DataRow(
                      cells: [
                        DataCell(Text(row.studentId, style: GoogleFonts.poppins(fontSize: 12))),
                        DataCell(Text(row.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600))),
                        DataCell(Text(row.faculty, style: GoogleFonts.poppins(fontSize: 12))),
                        DataCell(Text(row.program, style: GoogleFonts.poppins(fontSize: 12))),
                        DataCell(Text(row.yearLevel, style: GoogleFonts.poppins(fontSize: 12))),
                        DataCell(Text(row.amount, style: GoogleFonts.poppins(fontSize: 12))),
                        DataCell(Text(row.paymentMethod, style: GoogleFonts.poppins(fontSize: 12))),
                        DataCell(Text(row.referenceNo, style: GoogleFonts.poppins(fontSize: 12))),
                        DataCell(Text(row.paidAt, style: GoogleFonts.poppins(fontSize: 12))),
                        DataCell(
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusChipColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                row.status,
                                style: GoogleFonts.poppins(
                                  color: statusTextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
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

  Widget _buildStudentCard(FeeStudentRowData row) {
    Color statusColor;
    IconData statusIcon;
    switch (row.status) {
      case 'Paid':
        statusColor = const Color(0xFF2E7D32);
        statusIcon = LucideIcons.checkCircle2;
        break;
      case 'Pending':
        statusColor = const Color(0xFFE65100);
        statusIcon = LucideIcons.clock;
        break;
      default:
        statusColor = const Color(0xFFC62828);
        statusIcon = LucideIcons.xCircle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primaryColor.withValues(alpha: 0.08),
            child: Text(
              _getInitials(row.name),
              style: GoogleFonts.poppins(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name,
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${row.studentId} • ${row.program} • Lvl ${row.yearLevel}',
                  style: GoogleFonts.poppins(
                    color: Colors.black54, 
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (row.status == 'Paid') ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.creditCard, size: 12, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        'Ref: ${row.referenceNo} (${row.paymentMethod})',
                        style: GoogleFonts.poppins(
                          color: Colors.black45,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                row.amount,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      row.status,
                      style: GoogleFonts.poppins(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeeStudentRowData {
  final String userUuid;
  final String studentId;
  final String name;
  final String faculty;
  final String program;
  final String yearLevel;
  final String amount;
  final String paidAt;
  final String referenceNo;
  final String paymentMethod;
  final String status; // Paid, Pending, Unpaid

  FeeStudentRowData({
    required this.userUuid,
    required this.studentId,
    required this.name,
    required this.faculty,
    required this.program,
    required this.yearLevel,
    required this.amount,
    required this.paidAt,
    required this.referenceNo,
    required this.paymentMethod,
    required this.status,
  });
}
