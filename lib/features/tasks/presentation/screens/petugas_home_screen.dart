import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/shimmer/shimmers/home_dashboard_shimmer.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/task_provider.dart';

class PetugasHomeScreen extends ConsumerWidget {
  const PetugasHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    if (user.role != UserRole.petugasHse) {
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

    // Filter task milik petugas sendiri
    final allReports = reportsAsync.valueOrNull ?? <Map<String, dynamic>>[];
    final myReports = allReports.where((report) {
      final reportOwnerId = report['userId']?.toString() ??
                           report['created_by']?.toString() ??
                           report['user_id']?.toString();
      return reportOwnerId == user.id.toString();
    }).toList();

    final reports = [...myReports]
      ..sort((a, b) => _tryParseDate(b['date']?.toString())
          .compareTo(_tryParseDate(a['date']?.toString())));

    if (reportsAsync.isLoading && reports.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: HomeDashboardShimmer(),
      );
    }

    if (reportsAsync.hasError && reports.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat data laporan dari backend.',
              style: AppTypography.body1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final latestReports = reports.take(4).toList();

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
                        width: 48, height: 48,
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
                  _buildTeamProductivityCard(),
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
                              '${latestReports.length} My Tasks',
                              style: AppTypography.h1.copyWith(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'latest tasks you created',
                              style: AppTypography.h3.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.pushNamed(RouteNames.petugasAllTasks),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                Text('View all', style: AppTypography.caption.copyWith(color: const Color(0xFFD4D8FF), fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 14, color: const Color(0xFFD4D8FF)),
                              ],
                            ),
                          ),
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
                  final rpt = latestReports[index];
                  final isLast = index == latestReports.length - 1;

                  // Gunakan actual status yang mengecek follow-up terakhir
                  final actualStatus = _getActualStatus(rpt);

                  return Align(
                    heightFactor: isLast ? 1.0 : 0.85,
                    alignment: Alignment.topCenter,
                    child: _buildExactTaskCard(
                      context,
                      index: index,
                      title: _getReportTitle(rpt),
                      dateString: rpt['date']?.toString(),
                      rawStatus: actualStatus,
                      tag: _getStatusTag(actualStatus),
                      reportId: rpt['id'].toString(),
                    ),
                  );
                },
                childCount: latestReports.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // Helper untuk menentukan status sebenarnya dari report (sama seperti di all tasks screen)
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

  Color _getColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFD4D8FF); // Soft Purple
      case 'follow up done': return const Color(0xFFFAFF9F); // Soft Yellow
      case 'pending rejected': return const Color(0xFFFFCDD2); // Soft Pink (Merah Muda)
      case 'completed': return const Color(0xFFC1F0D0); // Soft Mint Green
      case 'canceled': return const Color(0xFF1E1E1E); // Solid Black
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
    // Garis hitam tipis untuk card biasa, garis putih tipis untuk card gelap (Canceled)
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
            // Layer Corak Garis
            Positioned.fill(
              child: CustomPaint(
                painter: _CardStripedPainter(color: stripeColor),
              ),
            ),
            // Layer Konten
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

  // Formatting helpers
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
      case 'pending': return 'Pending';
      case 'follow up done': return 'Follow Up Done';
      case 'pending rejected': return 'Pending Rejected';
      case 'completed': return 'Completed';
      case 'canceled': return 'Canceled';
      default: return null;
    }
  }

  Widget _buildTeamProductivityCard() {
    final List<List<int>> gridPattern = [
      [1, 1, 1, 1, 2, 3, 3], [1, 1, 1, 2, 2, 3, 3],
      [1, 1, 2, 2, 3, 3, 1], [1, 1, 2, 3, 3, 3, 1],
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
              Text('Team\nProductivity', style: AppTypography.h3.copyWith(color: AppColors.textInverted, height: 1.15)),
              Row(
                children: [
                  Text(DateFormat('MMMM yyyy').format(DateTime.now()), style: AppTypography.caption.copyWith(color: AppColors.textInverted, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(PhosphorIcons.caretDown(), size: 16, color: AppColors.textInverted),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Column(
            children: gridPattern.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: row.asMap().entries.map((entry) {
                    final isLast = entry.key == row.length - 1;
                    return Expanded(child: Padding(padding: EdgeInsets.only(right: isLast ? 0 : 6.0), child: _buildGridPill(entry.value)));
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
    if (type == 1) return Container(height: 12, decoration: BoxDecoration(color: AppColors.textInverted, borderRadius: BorderRadius.circular(12)));
    final isBold = type == 2;
    return Container(
      height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(painter: _StripedPainter(color: isBold ? AppColors.textInverted.withValues(alpha: 0.3) : AppColors.textInverted.withValues(alpha: 0.1))),
    );
  }
}

// Painter untuk corak tim productivity
class _StripedPainter extends CustomPainter {
  final Color color;
  _StripedPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke;
    for (double i = -size.height; i < size.width; i += 5.0) {
      canvas.drawLine(Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter untuk corak kartu tugas (All Card Pattern)
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
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
