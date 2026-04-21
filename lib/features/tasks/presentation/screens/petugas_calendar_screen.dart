import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/shimmer/base_shimmer.dart';
import '../../../../core/widgets/shimmer/shimmer_box.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/task_provider.dart';

class PetugasCalendarScreen extends ConsumerStatefulWidget {
  const PetugasCalendarScreen({super.key});

  @override
  ConsumerState<PetugasCalendarScreen> createState() =>
      _PetugasCalendarScreenState();
}

class _PetugasCalendarScreenState extends ConsumerState<PetugasCalendarScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _dateList;
  final ScrollController _scrollController = ScrollController();

  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _onRefresh() async {
    debugPrint('[PetugasCalendarScreen] pull-to-refresh triggered');
    ref.invalidate(tasksFutureProvider);
    ref.invalidate(petugasTaskMapsProvider);
    ref.invalidate(petugasOwnTaskMapsProvider);

    final results = await Future.wait([
      ref.read(tasksFutureProvider.future),
      ref.read(petugasTaskMapsProvider.future),
      ref.read(petugasOwnTaskMapsProvider.future),
    ]);

    final totalTasks = (results[0] as List).length;
    final totalTaskMaps = (results[1] as List).length;
    final totalOwn = (results[2] as List).length;

    debugPrint(
      '[PetugasCalendarScreen] refresh complete -> tasks=$totalTasks maps=$totalTaskMaps own=$totalOwn',
    );
  }

  @override
  void initState() {
    super.initState();
    _initDate(DateTime.now());
  }

  void _initDate(DateTime baseDate) {
    _selectedDate = DateTime(baseDate.year, baseDate.month, baseDate.day);
    _dateList = List.generate(31, (index) {
      return DateTime(baseDate.year, baseDate.month, baseDate.day)
          .subtract(const Duration(days: 15))
          .add(Duration(days: index));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController
            .jumpTo(15 * 72.0 - (MediaQuery.of(context).size.width / 2) + 36);
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
      setState(() {
        _initDate(picked);
      });
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
    final user = ref.watch(currentUserProvider);
    final reportsAsync = ref.watch(petugasOwnTaskMapsProvider);

    // FIX: Redirect ke login jika user null (setelah hot restart)
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(RouteNames.login);
        }
      });
      return const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // FIX: Redirect ke login jika role bukan petugas
    if (user.role != UserRole.petugasHse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(RouteNames.login);
        }
      });
      return const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final reports = reportsAsync.valueOrNull ?? <Map<String, dynamic>>[];
    debugPrint(
      '[PetugasCalendarScreen] userId=${user.id} ownReports=${reports.length}',
    );

    if (reportsAsync.isLoading && reports.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: _CalendarShimmer(),
      );
    }

    if (reportsAsync.hasError && reports.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Gagal memuat jadwal dari backend.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    final tasksForSelectedDate = reports.where((rpt) {
      if (rpt['date'] == null) return false;
      final rptDate = DateTime.tryParse(rpt['date'].toString());
      if (rptDate == null) return false;

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
      ..sort((a, b) => _tryParseDate(a['date']?.toString())
          .compareTo(_tryParseDate(b['date']?.toString())));

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SafeArea(
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
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.5),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white, size: 28),
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.search,
                          color: Colors.white, size: 24),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
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
                        color:
                            isSelected ? const Color(0xFFFAFF9F) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(date.day.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(DateFormat('EEE').format(date),
                              style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
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
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 120),
                        children: [
                          SizedBox(
                            height: 220,
                            child: Center(
                              child: Text(
                                _searchQuery.isNotEmpty
                                    ? 'No tasks found.'
                                    : 'No schedules for today.',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 120),
                        itemCount: tasksForSelectedDate.length,
                        itemBuilder: (context, index) {
                          final task = tasksForSelectedDate[index];
                          final dateString = task['date']?.toString();
                          final currentPeriod = _getAmPm(dateString);
                          final previousPeriod = index > 0
                              ? _getAmPm(tasksForSelectedDate[index - 1]['date']
                                  ?.toString())
                              : currentPeriod;
                          final showPeriodDivider =
                              index > 0 && currentPeriod != previousPeriod;

                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                            _formatHourAMPM(
                                                task['date']?.toString()),
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13)),
                                        const SizedBox(height: 24),
                                        Container(
                                            width: 8,
                                            height: 1.5,
                                            color: Colors.grey.shade400),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildExactTaskCard(
                                      context,
                                      title: _getReportTitle(task),
                                      dateString: task['date']?.toString(),
                                      rawStatus: _getActualStatus(task),
                                      tag:
                                          _getStatusTag(_getActualStatus(task)),
                                      reportId: task['id'].toString(),
                                      staffName:
                                          task['staffName']?.toString() ?? '-',
                                    ),
                                  ),
                                ],
                              ),
                              if (showPeriodDivider)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        alignment: Alignment.center,
                                        child: Text(
                                          currentPeriod,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Container(
                                              height: 1.5,
                                              color: Colors.black)),
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
      ),
    );
  }

  String _getAmPm(String? dateStr) {
    if (dateStr == null) return 'AM';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return 'AM';
    return dt.hour >= 12 ? 'PM' : 'AM';
  }

  // Helper untuk menentukan status sebenarnya dari report (sama seperti di all tasks screen)
  String _getActualStatus(Map<String, dynamic> report) {
    final followUps = report['followUps'] as List<dynamic>? ??
        report['follow_ups'] as List<dynamic>? ??
        [];

    if (followUps.isNotEmpty) {
      final lastFollowUp = followUps.last as Map<String, dynamic>;
      final lastStatus = lastFollowUp['status']?.toString().toLowerCase();

      // Jika follow-up terakhir rejected, maka status report adalah "Pending Rejected"
      if (lastStatus == 'rejected') {
        return 'Pending Rejected';
      }
    }

    // Default ke status report
    return report['status']?.toString() ?? 'Pending';
  }

  Color _getColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD4D8FF);
      case 'follow up done':
        return const Color(0xFFFAFF9F);
      case 'pending rejected':
        return const Color(0xFFFFCDD2);
      case 'completed':
        return const Color(0xFFC1F0D0);
      case 'canceled':
        return const Color(0xFF1E1E1E);
      default:
        return const Color(0xFFFFFFFF);
    }
  }

  Widget _buildExactTaskCard(
    BuildContext context, {
    required String title,
    required String? dateString,
    required String rawStatus,
    String? tag,
    required String reportId,
    required String staffName,
  }) {
    final bool isDark = rawStatus.toLowerCase() == 'canceled';
    final Color bgColor = _getColorByStatus(rawStatus);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final Color stripeColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

    return InkWell(
      onTap: () => context
          .pushNamed(RouteNames.taskDetail, pathParameters: {'id': reportId}),
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
              child:
                  CustomPaint(painter: _CardStripedPainter(color: stripeColor)),
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
                          style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.2),
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(tag,
                              style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF6B6E94),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(PhosphorIcons.user(PhosphorIconsStyle.bold),
                          size: 16, color: textColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          staffName,
                          style: TextStyle(
                              color: textColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                              fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                                PhosphorIcons.calendarBlank(
                                    PhosphorIconsStyle.bold),
                                size: 16,
                                color: textColor.withValues(alpha: 0.7)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _formatIndonesianDate(dateString),
                                style: TextStyle(
                                    color: textColor.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold),
                              size: 16,
                              color: textColor.withValues(alpha: 0.7)),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(dateString),
                            style: TextStyle(
                                color: textColor.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 13),
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
    } catch (e) {
      return '12 AM';
    }
  }

  String _formatIndonesianDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return '-';
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return '-';
    }
  }

  DateTime _tryParseDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.tryParse(dateStr) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _getReportTitle(Map<String, dynamic> report) {
    final title = report['title']?.toString().trim();
    if (title != null && title.isNotEmpty) return title;

    final area = report['area']?.toString() ?? '-';
    final cause = report['rootCause']?.toString() ?? '-';
    return 'Inspeksi $area - Masalah: $cause';
  }

  String? _getStatusTag(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'follow up done':
        return 'Follow Up Done';
      case 'pending rejected':
        return 'Pending Rejected';
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Canceled';
      default:
        return null;
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
      canvas.drawLine(
          Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CalendarShimmer extends StatelessWidget {
  const _CalendarShimmer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: BaseShimmer(
              child: Column(
                children: [
                  const ShimmerBox(width: 200, height: 24),
                  const SizedBox(height: 16),
                  const ShimmerBox(width: 150, height: 20),
                ],
              ),
            ),
          ),
          // Date selector
          SizedBox(
            height: 72,
            child: BaseShimmer(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 7,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Task list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BaseShimmer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 80, height: 24),
                          SizedBox(height: 12),
                          ShimmerBox(width: double.infinity, height: 20),
                          SizedBox(height: 8),
                          ShimmerBox(width: 150, height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
