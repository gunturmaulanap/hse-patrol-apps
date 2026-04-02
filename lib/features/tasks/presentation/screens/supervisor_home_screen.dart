import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../providers/task_provider.dart';

class SupervisorHomeScreen extends ConsumerWidget {
  const SupervisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final ownReportsAsync = ref.watch(supervisorOwnTaskMapsProvider);

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.goNamed(RouteNames.login);
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user.role != 'supervisor') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.goNamed(RouteNames.login);
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Filter task milik supervisor sendiri
    final allReports = ownReportsAsync.valueOrNull ?? <Map<String, dynamic>>[];
    final myReports = allReports.where((report) {
      final reportOwnerId = report['userId']?.toString() ??
                           report['created_by']?.toString() ??
                           report['user_id']?.toString();
      return reportOwnerId == user.id;
    }).toList();

    final reports = [...myReports]
      ..sort(
        (a, b) => _tryParseDate(b['date']?.toString()).compareTo(_tryParseDate(a['date']?.toString())),
      );

    if (ownReportsAsync.isLoading && reports.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (ownReportsAsync.hasError && reports.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat task.',
              style: AppTypography.body1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final latestFourTasks = reports.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good Morning,', style: AppTypography.h2),
                          Text(
                            '${user.username}!',
                            style: AppTypography.h1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => context.pushNamed(RouteNames.petugasProfile),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                        child: Icon(PhosphorIcons.user(), color: AppColors.textPrimary, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryCard(context),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${latestFourTasks.length} My Tasks',
                              style: AppTypography.h1.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'latest tasks you created',
                              style: AppTypography.h3.copyWith(
                                color: AppColors.textSecondary.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () => context.pushNamed(RouteNames.supervisorAllTasks),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'View all',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFFD4D8FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                              size: 14,
                              color: const Color(0xFFD4D8FF),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = latestFourTasks[index];
                  return Align(
                    heightFactor: index == latestFourTasks.length - 1 ? 1.0 : 0.92,
                    alignment: Alignment.topCenter,
                    child: _buildExactTaskCard(
                      context,
                      title: _getReportTitle(task),
                      dateString: task['date']?.toString(),
                      rawStatus: task['status']?.toString() ?? 'Pending',
                      tag: _getStatusTag(task['status']?.toString()),
                      reportId: task['id'].toString(),
                    ),
                  );
                },
                childCount: latestFourTasks.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final List<List<int>> gridPattern = [
      [1, 1, 1, 1, 2, 3, 3],
      [1, 1, 1, 2, 2, 3, 3],
      [1, 1, 2, 2, 3, 3, 1],
      [1, 1, 2, 3, 3, 3, 1],
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.large)),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team\nSupervision',
                style: AppTypography.h3.copyWith(color: AppColors.textInverted, height: 1.15),
              ),
              Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textInverted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(PhosphorIcons.caretDown(), size: 16, color: AppColors.textInverted),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pantau progres task HSE staff dengan visual status.',
            style: AppTypography.body1.copyWith(color: AppColors.textInverted.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.pushNamed(RouteNames.supervisorDashboard),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1.2),
                foregroundColor: AppColors.textInverted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(PhosphorIcons.layout(PhosphorIconsStyle.bold), size: 16),
              label: Text(
                'Open Dashboard',
                style: AppTypography.body1.copyWith(
                  color: AppColors.textInverted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: gridPattern.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: row.asMap().entries.map((entry) {
                    final isLast = entry.key == row.length - 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 6.0),
                        child: _buildGridPill(entry.value),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridPill(int type) {
    if (type == 1) {
      return Container(
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.textInverted,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    final isBold = type == 2;
    return Container(
      height: 12,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _StripedPainter(
          color: isBold
              ? AppColors.textInverted.withValues(alpha: 0.3)
              : AppColors.textInverted.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Color _getColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD4D8FF);
      case 'follow up done':
        return const Color(0xFFFAFF9F);
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
    required String reportId,
    String? tag,
  }) {
    final bool isDark = rawStatus.toLowerCase() == 'canceled';
    final Color bgColor = _getColorByStatus(rawStatus);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final Color stripeColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);

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
                          child: Text(
                            tag,
                            style: AppTypography.caption.copyWith(color: isDark ? Colors.white : const Color(0xFF6B6E94), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
    } catch (_) {
      return '-';
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '-';
    }
  }

  String? _getStatusTag(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'follow up done':
        return 'Waiting Review';
      case 'completed':
        return 'Completed';
      case 'canceled':
        return 'Canceled';
      default:
        return null;
    }
  }

  String _getReportTitle(Map<String, dynamic> report) {
    final title = report['title']?.toString().trim();
    if (title != null && title.isNotEmpty) return title;

    final area = report['area']?.toString() ?? '-';
    final cause = report['rootCause']?.toString() ?? '-';
    return 'Inspeksi $area - Masalah: $cause';
  }

  DateTime _tryParseDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.tryParse(dateStr) ?? DateTime.fromMillisecondsSinceEpoch(0);
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

class _StripedPainter extends CustomPainter {
  final Color color;
  _StripedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width; i += 5.0) {
      canvas.drawLine(Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
