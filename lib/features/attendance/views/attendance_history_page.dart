import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/attendance_provider.dart';
import '../models/qr_scan_ui_model.dart';
import '../widgets/qr_recent_scan_card.dart';

class AttendanceHistoryPage extends ConsumerStatefulWidget {
  final String eventId;
  final String eventName;

  const AttendanceHistoryPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  ConsumerState<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends ConsumerState<AttendanceHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<QrScanUIModel> _allScans = [];
  List<QrScanUIModel> _filteredScans = [];
  bool _isLoading = true;
  String _selectedMode = 'All';
  String _selectedProgram = 'All';

  static const Color primaryColor = Color(0xFF003DA5);
  static const Color accentColor = Color(0xFFFFC107);

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
      final rawScans = await repository.getRecentScansForEvent(widget.eventId);
      
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

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Decorative Backgrounds
              Positioned(
                top: 100,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Positioned(
                bottom: 260,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(75),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom AppBar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    color: Colors.white,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 32,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    LucideIcons.arrowLeft,
                                    color: primaryColor,
                                    size: 21,
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Scan ',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    TextSpan(
                                      text: 'History',
                                      style: TextStyle(color: accentColor),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.12),
                                    ),
                                  ),
                                  child: Text(
                                    '${_filteredScans.length}',
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.eventName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
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

                  const SizedBox(height: 12),

                  // Scan List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadScans,
                      color: primaryColor,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: primaryColor))
                          : _filteredScans.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                                  itemCount: _filteredScans.length,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return QrRecentScanCard(scan: _filteredScans[index]);
                                  },
                                ),
                    ),
                  ),
                ],
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
}
