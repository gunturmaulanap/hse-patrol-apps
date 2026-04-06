import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/shimmer/base_shimmer.dart';
import '../../../../core/widgets/shimmer/shimmer_box.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../areas/presentation/providers/area_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class PicAllTasksScreen extends ConsumerStatefulWidget {
  const PicAllTasksScreen({super.key});

  @override
  ConsumerState<PicAllTasksScreen> createState() => _PicAllTasksScreenState();
}

class _PicAllTasksScreenState extends ConsumerState<PicAllTasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final reportsAsync = ref.watch(petugasTaskMapsProvider);
    final areasAsync = ref.watch(areaByUserProvider);

    // FIX: Redirect ke login jika user null
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(RouteNames.login);
        }
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final areaAccess = (areasAsync.valueOrNull ?? const [])
        .map((a) => a.name)
        .toSet();
    final reports = reportsAsync.valueOrNull ?? <Map<String, dynamic>>[];

    // Filter base data: Hanya ambil task yang areanya diizinkan untuk PIC ini
    // Dan hilangkan yang statusnya Canceled (Dihapus dari pandangan PIC)
    final picReports = reports.where((r) {
      return areaAccess.contains(r['area']) && r['status'] != 'Canceled';
    }).toList();

    final isInitialLoading =
        (reportsAsync.isLoading && !reportsAsync.hasValue) ||
        (areasAsync.isLoading && !areasAsync.hasValue);

    if (isInitialLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: _TaskListShimmer(),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact Title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text('PIC Tasks', style: AppTypography.h3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ),

              // Date Filter & Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Date Filter Row
                    Row(
                      children: [
                        Expanded(
                          child: _dateFilterButton(
                            label: 'From',
                            date: _dateFrom,
                            onTap: () => _selectDateFrom(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _dateFilterButton(
                            label: 'To',
                            date: _dateTo,
                            onTap: () => _selectDateTo(context),
                          ),
                        ),
                        if (_dateFrom != null || _dateTo != null)
                          IconButton(
                            icon: Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), size: 20),
                            onPressed: () => setState(() {
                              _dateFrom = null;
                              _dateTo = null;
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: AppTypography.body1.copyWith(color: AppColors.textSecondary),
                        prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), color: AppColors.textSecondary, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(icon: Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), color: AppColors.textSecondary, size: 18), onPressed: () { _searchController.clear(); setState(() { _searchQuery = ''; }); })
                            : null,
                        filled: true, fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tab Navigasi (Penamaan disesuaikan POV PIC)
              TabBar(
                isScrollable: true, tabAlignment: TabAlignment.start, dividerColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16), labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                indicator: BoxDecoration(color: const Color(0xFFD4D8FF), borderRadius: BorderRadius.circular(AppRadius.pill)),
                labelColor: const Color(0xFF1E1E1E), unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTypography.body1.copyWith(fontWeight: FontWeight.bold), indicatorPadding: EdgeInsets.zero,
                tabs: [ _buildTab('All'), _buildTab('Pending'), _buildTab('Follow Up Done'), _buildTab('Pending Rejected'), _buildTab('Approved') ],
              ),
              const SizedBox(height: 12),

              // List View berdasarkan Tab
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTaskList(picReports, 'All'),
                    _buildTaskList(picReports, 'Pending'),
                    _buildTaskList(picReports, 'Follow Up Done'),
                    _buildTaskList(picReports, 'Pending Rejected'),
                    _buildTaskList(picReports, 'Approved'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    return Tab(height: 36, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(text, style: TextStyle(fontSize: 13))));
  }

  Widget _dateFilterButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), size: 16, color: AppColors.textSecondary),
      label: Text(
        date == null ? label : DateFormat('dd MMM').format(date),
        style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Future<void> _selectDateFrom(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateFrom = DateTime(picked.year, picked.month, picked.day);
        if (_dateTo != null && _dateTo!.isBefore(_dateFrom!)) {
          _dateTo = _dateFrom;
        }
      });
    }
  }

  Future<void> _selectDateTo(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateTo = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  // --- Logika Filter POV PIC ---

  // Helper untuk menentukan status sebenarnya dari report (sama seperti di petugas/supervisor)
  String _getActualStatus(Map<String, dynamic> report) {
    final followUps = report['followUps'] as List<dynamic>? ??
                      report['follow_ups'] as List<dynamic>? ?? [];

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

  String _getPicStatusTag(Map<String, dynamic> report) {
    // Gunakan actual status yang sama dengan petugas/supervisor
    final actualStatus = _getActualStatus(report);

    // Penamaan POV PIC
    if (actualStatus == 'Pending Rejected') {
      return 'Pending Rejected';
    } else if (actualStatus == 'Completed') {
      return 'Approved'; // POV PIC melihat Completed sebagai Approved
    } else if (actualStatus == 'Follow Up Done') {
      return 'Follow Up Done';
    }

    return actualStatus; // Pending
  }

  Widget _buildTaskList(List<Map<String, dynamic>> allReports, String filter) {
    // Filter berdasarkan tab (menggunakan tag POV PIC)
    List<Map<String, dynamic>> filtered = filter == 'All'
        ? allReports
        : allReports.where((r) => _getPicStatusTag(r) == filter).toList();

    // Filter tambahan berdasarkan Search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final title = _getReportTitle(r).toLowerCase();
        final area = (r['area']?.toString() ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || area.contains(query);
      }).toList();
    }

    // Filter berdasarkan tanggal
    if (_dateFrom != null || _dateTo != null) {
      filtered = filtered.where((r) {
        final dateStr = r['date']?.toString();
        if (dateStr == null || dateStr.isEmpty) return false;
        try {
          final date = DateTime.parse(dateStr);
          if (_dateFrom != null && date.isBefore(_dateFrom!)) return false;
          if (_dateTo != null && date.isAfter(_dateTo!)) return false;
          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.folderOpen(PhosphorIconsStyle.thin), size: 48, color: AppColors.surfaceLight),
            const SizedBox(height: 12),
            Text(_searchQuery.isNotEmpty ? 'No tasks found for "$_searchQuery"' : 'No $filter tasks yet.', style: AppTypography.body1.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    // Grouping by Area
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var rpt in filtered) {
      final area = rpt['area']?.toString() ?? 'Unknown Area';
      if (!grouped.containsKey(area)) { grouped[area] = []; }
      grouped[area]!.add(rpt);
    }
    final sortedAreas = grouped.keys.toList()..sort();

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: sortedAreas.length,
      itemBuilder: (context, index) {
        final area = sortedAreas[index];
        final tasks = grouped[area]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${index + 1}. $area', style: AppTypography.h3.copyWith(color: AppColors.textPrimary, fontSize: 14))),
            ...tasks.map((task) {
              final tag = _getPicStatusTag(task);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildExactTaskCard(
                  context,
                  title: _getReportTitle(task),
                  dateString: task['date']?.toString(),
                  tag: tag,
                  reportId: task['id'].toString(),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Color _getColorByPicStatus(String statusTag) {
    switch (statusTag.toLowerCase()) {
      case 'pending': return const Color(0xFFD4D8FF); // Ungu
      case 'follow up done': return const Color(0xFFFAFF9F); // Kuning
      case 'approved': return const Color(0xFFC1F0D0); // Hijau (Completed)
      case 'pending rejected': return const Color(0xFFFFCDD2); // Merah Muda (Pink)
      default: return const Color(0xFFFFFFFF);
    }
  }

  Widget _buildExactTaskCard(
    BuildContext context, {
    required String title,
    required String? dateString,
    required String tag,
    required String reportId,
  }) {
    final Color bgColor = _getColorByPicStatus(tag);
    final Color textColor = const Color(0xFF1E1E1E);
    final Color stripeColor = Colors.black.withValues(alpha: 0.05);

    return InkWell(
      onTap: () => context.pushNamed(RouteNames.taskDetail, pathParameters: {'id': reportId}),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E1E), width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _CardStripedPainter(color: stripeColor))),
            Padding(
              padding: const EdgeInsets.all(12),
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
                          style: AppTypography.body1.copyWith(color: textColor, fontSize: 14, fontWeight: FontWeight.w600, height: 1.2),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(tag, style: AppTypography.caption.copyWith(
                          color: tag == 'Pending Rejected' ? Colors.redAccent : const Color(0xFF6B6E94),
                          fontWeight: FontWeight.w700, fontSize: 9
                        )),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), size: 13, color: textColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatIndonesianDate(dateString),
                          style: AppTypography.caption.copyWith(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500, fontSize: 11),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 13, color: textColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(dateString),
                        style: AppTypography.caption.copyWith(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500, fontSize: 11),
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

  String _getReportTitle(Map<String, dynamic> report) {
    final title = report['title']?.toString().trim();
    if (title != null && title.isNotEmpty) return title;

    final area = report['area']?.toString() ?? '-';
    final cause = report['rootCause']?.toString() ?? '-';
    return 'Inspeksi $area - Masalah: $cause';
  }
}

class _CardStripedPainter extends CustomPainter {
  final Color color;
  _CardStripedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 4.0..style = PaintingStyle.stroke;
    const double space = 8.0;
    for (double i = -size.height; i < size.width; i += space) {
      canvas.drawLine(Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TaskListShimmer extends StatelessWidget {
  const _TaskListShimmer();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: BaseShimmer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 200, height: 28),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 300, height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BaseShimmer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
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
                        SizedBox(height: 12),
                        Row(
                          children: [
                            ShimmerBox(width: 60, height: 14),
                            Spacer(),
                            ShimmerBox(width: 60, height: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              childCount: 5,
            ),
          ),
        ),
      ],
    );
  }
}
