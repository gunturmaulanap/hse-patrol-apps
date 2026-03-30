import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/mock_api/mock_database.dart';

class PetugasCalendarScreen extends ConsumerStatefulWidget {
  const PetugasCalendarScreen({super.key});

  @override
  ConsumerState<PetugasCalendarScreen> createState() => _PetugasCalendarScreenState();
}

class _PetugasCalendarScreenState extends ConsumerState<PetugasCalendarScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _dateList;
  final ScrollController _scrollController = ScrollController();
  
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initDate(DateTime.now());
  }

  void _initDate(DateTime baseDate) {
    _selectedDate = DateTime(baseDate.year, baseDate.month, baseDate.day);
    _dateList = List.generate(31, (index) {
      return DateTime(baseDate.year, baseDate.month, baseDate.day).subtract(const Duration(days: 15)).add(Duration(days: index));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(15 * 72.0 - (MediaQuery.of(context).size.width / 2) + 36);
      }
    });
  }

  void _selectMonthYear() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFAFF9F), 
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() { _initDate(picked); });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mockDatabaseProvider);

    final tasksForSelectedDate = db.reports.where((rpt) {
      if (rpt['date'] == null) return false;
      final rptDate = DateTime.parse(rpt['date'].toString());
      
      final matchDate = rptDate.year == _selectedDate.year &&
                        rptDate.month == _selectedDate.month &&
                        rptDate.day == _selectedDate.day;
      if (!matchDate) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final area = (rpt['area'] ?? '').toString().toLowerCase();
        final rootCause = (rpt['rootCause'] ?? '').toString().toLowerCase();
        return area.contains(query) || rootCause.contains(query);
      }
      return true;
    }).toList()
      ..sort((a, b) => DateTime.parse(a['date'] as String).compareTo(DateTime.parse(b['date'] as String)));

    return Scaffold(
      backgroundColor: const Color(0xFF111111), 
      body: SafeArea(
        bottom: false, 
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _selectMonthYear,
                    child: Row(
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(_selectedDate),
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w500, letterSpacing: -0.5),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearchVisible = !_isSearchVisible;
                        if (!_isSearchVisible) _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1), shape: BoxShape.circle),
                      child: const Icon(Icons.search, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isSearchVisible ? 70 : 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      filled: true, fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 85,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _dateList.length,
                itemBuilder: (context, index) {
                  final date = _dateList[index];
                  final isSelected = date.year == _selectedDate.year && 
                                     date.month == _selectedDate.month && 
                                     date.day == _selectedDate.day;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 66,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFAFF9F) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(date.day.toString(), style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(DateFormat('EEE').format(date), style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Container(
                width: double.infinity,
                // PERBAIKAN: Menambahkan clipBehavior agar Listview tidak menembus batas lengkungan atas.
                clipBehavior: Clip.antiAlias, 
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: tasksForSelectedDate.isEmpty
                    ? Center(child: Text(_searchQuery.isNotEmpty ? 'No tasks found.' : 'No schedules for today.', style: const TextStyle(color: Colors.grey, fontSize: 16)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 120), 
                        itemCount: tasksForSelectedDate.length,
                        itemBuilder: (context, index) {
                          final task = tasksForSelectedDate[index];
                          final isCurrentTimeLine = index == 1; 
                          
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(_formatHourAMPM(task['date']?.toString()), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13)),
                                        const SizedBox(height: 24),
                                        Container(width: 8, height: 1.5, color: Colors.grey.shade400),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildExactTaskCard(
                                      context,
                                      title: _getMockTitle(task),
                                      dateString: task['date']?.toString(),
                                      rawStatus: task['status']?.toString() ?? 'Pending',
                                      tag: _getStatusTag(task['status']?.toString()),
                                      reportId: task['id'].toString(),
                                    ),
                                  ),
                                ],
                              ),
                              if (isCurrentTimeLine)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: Row(
                                    children: [
                                      Transform.translate(offset: const Offset(-2, 0), child: const Icon(Icons.diamond, size: 10, color: Colors.black)),
                                      Expanded(child: Container(height: 1.5, color: Colors.black)),
                                    ],
                                  ),
                                )
                              else
                                const SizedBox(height: 24),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFD4D8FF);
      case 'follow up done': return const Color(0xFFFAFF9F);
      case 'completed': return const Color(0xFFC1F0D0);
      case 'canceled': return const Color(0xFF1E1E1E); 
      default: return const Color(0xFFFFFFFF);
    }
  }

  Widget _buildExactTaskCard(
    BuildContext context, {
    required String title,
    required String? dateString,
    required String rawStatus,
    String? tag,
    required String reportId,
  }) {
    final bool isDark = rawStatus.toLowerCase() == 'canceled';
    final Color bgColor = _getColorByStatus(rawStatus);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final Color stripeColor = isDark 
        ? Colors.white.withValues(alpha: 0.05) 
        : Colors.black.withValues(alpha: 0.05);

    return InkWell(
      onTap: () => context.pushNamed(RouteNames.reportDetail, pathParameters: {'id': reportId}),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _CardStripedPainter(color: stripeColor)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600, height: 1.2),
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(tag, style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF6B6E94), 
                            fontSize: 12, fontWeight: FontWeight.w600
                          )),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), size: 16, color: textColor.withValues(alpha: 0.7)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _formatIndonesianDate(dateString),
                                style: TextStyle(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500, fontSize: 13),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 16, color: textColor.withValues(alpha: 0.7)),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(dateString),
                            style: TextStyle(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHourAMPM(String? dateStr) {
    if (dateStr == null) return '12 AM';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('h a').format(dt); 
    } catch (e) { return '12 AM'; }
  }

  String _formatIndonesianDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (e) { return '-'; }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('HH:mm').format(dt); 
    } catch (e) { return '-'; }
  }

  String _getMockTitle(Map<String, dynamic> report) {
    final area = report['area']?.toString() ?? '-';
    final cause = report['rootCause']?.toString() ?? '-';
    return 'Inspeksi $area - Masalah: $cause';
  }

  String? _getStatusTag(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'follow up done': return 'Waiting Review';
      case 'completed': return 'Completed';
      case 'canceled': return 'Canceled';
      default: return null;
    }
  }
}

class _CardStripedPainter extends CustomPainter {
  final Color color;
  _CardStripedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    const double space = 8.0;
    for (double i = -size.height; i < size.width; i += space) {
      canvas.drawLine(Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}