import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../providers/task_provider.dart';

class PetugasAllTasksScreen extends ConsumerStatefulWidget {
  const PetugasAllTasksScreen({super.key});

  @override
  ConsumerState<PetugasAllTasksScreen> createState() => _PetugasAllTasksScreenState();
}

class _PetugasAllTasksScreenState extends ConsumerState<PetugasAllTasksScreen> {
  final TextEditingController _searchController = TextEditingController();
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

    // FIX: Redirect ke login jika user null (setelah hot restart)
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

    // FIX: Redirect ke login jika role bukan petugas
    if (user.role != 'petugas') {
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

    final reports = reportsAsync.valueOrNull ?? <Map<String, dynamic>>[];

    if (reportsAsync.isLoading && reports.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (reportsAsync.hasError && reports.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat task dari backend.',
              style: AppTypography.body1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 24, 16),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pushNamed(RouteNames.petugasProfile),
                      child: Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                        child: Icon(PhosphorIcons.user(), color: AppColors.textPrimary, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tasks Dashboard', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                          Text(user.username, style: AppTypography.h1, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchController,
                  style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search report name or area...',
                    hintStyle: AppTypography.body1.copyWith(color: AppColors.textSecondary),
                    prefixIcon: Padding(padding: const EdgeInsets.all(12), child: Icon(PhosphorIcons.magnifyingGlass(), color: AppColors.textSecondary, size: 20)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), color: AppColors.textSecondary, size: 20), onPressed: () { _searchController.clear(); setState(() { _searchQuery = ''; }); })
                        : null,
                    filled: true, fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.pill), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TabBar(
                isScrollable: true, tabAlignment: TabAlignment.start, dividerColor: Colors.transparent, 
                padding: const EdgeInsets.symmetric(horizontal: 24), labelPadding: const EdgeInsets.symmetric(horizontal: 8), 
                indicator: BoxDecoration(color: const Color(0xFFD4D8FF), borderRadius: BorderRadius.circular(AppRadius.pill)),
                labelColor: const Color(0xFF1E1E1E), unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTypography.body1.copyWith(fontWeight: FontWeight.bold), indicatorPadding: EdgeInsets.zero,
                tabs: [ _buildTab('All'), _buildTab('Pending'), _buildTab('Follow Up Done'), _buildTab('Completed'), _buildTab('Canceled') ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTaskList(reports, 'All'),
                    _buildTaskList(reports, 'Pending'),
                    _buildTaskList(reports, 'Follow Up Done'),
                    _buildTaskList(reports, 'Completed'),
                    _buildTaskList(reports, 'Canceled'),
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
    return Tab(height: 40, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(text)));
  }

  Widget _buildTaskList(List<Map<String, dynamic>> allReports, String filter) {
    List<Map<String, dynamic>> filtered = filter == 'All' 
        ? allReports 
        : allReports.where((r) => r['status'] == filter).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final title = _getReportTitle(r).toLowerCase();
        final area = (r['area']?.toString() ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || area.contains(query);
      }).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.folderOpen(PhosphorIconsStyle.thin), size: 64, color: AppColors.surfaceLight),
            const SizedBox(height: 16),
            Text(_searchQuery.isNotEmpty ? 'No tasks found for "$_searchQuery"' : 'No $filter tasks yet.', style: AppTypography.body1.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var rpt in filtered) {
      final area = rpt['area']?.toString() ?? 'Unknown Area';
      if (!grouped.containsKey(area)) { grouped[area] = []; }
      grouped[area]!.add(rpt);
    }

    final sortedAreas = grouped.keys.toList()..sort();

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, 
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: sortedAreas.length,
      itemBuilder: (context, index) {
        final area = sortedAreas[index];
        final tasks = grouped[area]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('${index + 1}. $area', style: AppTypography.h3.copyWith(color: AppColors.textPrimary))),
            ...tasks.asMap().entries.map((taskEntry) {
              final task = taskEntry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildExactTaskCard(
                  context,
                  index: taskEntry.key, 
                  title: _getReportTitle(task),
                  dateString: task['date']?.toString(),
                  rawStatus: task['status']?.toString() ?? 'Pending',
                  tag: _getStatusTag(task['status']?.toString()),
                  reportId: task['id'].toString(),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Color _getColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFD4D8FF);
      case 'follow up done': return const Color(0xFFFAFF9F);
      case 'completed': return const Color(0xFFC1F0D0);
      case 'canceled': return const Color(0xFF1E1E1E); // Hitam Solid
      default: return const Color(0xFFFFFFFF);
    }
  }

  Widget _buildExactTaskCard(
    BuildContext context, {
    required int index,
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
      onTap: () => context.pushNamed(RouteNames.taskDetail, pathParameters: {'id': reportId}),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _CardStripedPainter(color: stripeColor)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
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
                          style: AppTypography.h2.copyWith(color: textColor, fontSize: 18, fontWeight: FontWeight.w600, height: 1.2),
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
                          child: Text(tag, style: AppTypography.caption.copyWith(
                            color: isDark ? Colors.white : const Color(0xFF6B6E94), 
                            fontWeight: FontWeight.w600
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
                                style: AppTypography.body1.copyWith(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600, fontSize: 13),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 16, color: textColor.withValues(alpha: 0.7)),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(dateString),
                            style: AppTypography.body1.copyWith(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600, fontSize: 13),
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
