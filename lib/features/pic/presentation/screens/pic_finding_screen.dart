import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../auth/domain/auth_role_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/active_area_filter_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class PicFindingScreen extends ConsumerStatefulWidget {
  const PicFindingScreen({super.key});

  @override
  ConsumerState<PicFindingScreen> createState() => _PicFindingScreenState();
}

class _PicFindingScreenState extends ConsumerState<PicFindingScreen> {
  int _limit = 5;

  Future<void> _onRefresh() async {
    debugPrint('[PicFindingScreen] pull-to-refresh triggered');
    ref.invalidate(tasksFutureProvider);
    ref.invalidate(petugasTaskMapsProvider);
    ref.invalidate(picAccessibleTaskMapsProvider);

    final results = await Future.wait([
      ref.read(tasksFutureProvider.future),
      ref.read(picAccessibleTaskMapsProvider.future),
    ]);

    final totalTasks = (results[0] as List).length;
    final totalTaskMaps = (results[1] as List).length;
    debugPrint(
      '[PicFindingScreen] refresh complete -> tasks=$totalTasks maps=$totalTaskMaps',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(tasksFutureProvider);
      ref.invalidate(petugasTaskMapsProvider);
      ref.invalidate(picAccessibleTaskMapsProvider);
      ref.read(tasksFutureProvider.future);
      ref.read(picAccessibleTaskMapsProvider.future);
      debugPrint('[PicFindingScreen] init refresh petugasTaskMapsProvider');
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeArea = ref.watch(activeAreaFilterProvider);
    final user = ref.watch(currentUserProvider);
    final reportsAsync = ref.watch(picAccessibleTaskMapsProvider);

    if (user == null || !isPicScopedRole(user.role)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(RouteNames.login);
        }
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final reports = reportsAsync.valueOrNull ?? <Map<String, dynamic>>[];

    // Ambil data task khusus untuk area yang dipilih.
    // Sembunyikan task yang sudah di Canceled oleh petugas.
    final tasksInArea = reports.where((r) {
      final resolvedArea = _resolveTaskAreaLabel(r);
      final isAreaMatch = resolvedArea == activeArea;
      final isNotCanceled = _getPicStatusTag(r) != 'Canceled';
      return isAreaMatch && isNotCanceled;
    }).toList()
      ..sort((a, b) => _safeParseDate(b['date']?.toString()).compareTo(_safeParseDate(a['date']?.toString())));

    // Hitung status untuk insight
    final pendingCount = tasksInArea
        .where((r) {
          final tag = _getPicStatusTag(r);
          return tag == 'Pending' || tag == 'Pending Rejected';
        })
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.goNamed(RouteNames.picHome),
        ),
        title: Text('Area Findings', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Area Info
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill), color: AppColors.textPrimary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Selected Area', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                            Text(activeArea ?? 'Unknown Area', style: AppTypography.h2, maxLines: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Insight Banner
                  if (pendingCount > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: Colors.redAccent, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ada $pendingCount tugas yang membutuhkan tindak lanjut Anda.',
                              style: AppTypography.body1.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: Colors.green, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Area ini aman. Tidak ada tugas pending.',
                              style: AppTypography.body1.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 1, color: AppColors.surfaceLight),
            ),
            
            // List of Tasks
            Expanded(
              child: tasksInArea.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.all(24),
                        children: [
                          SizedBox(
                            height: 260,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(PhosphorIcons.folderOpen(PhosphorIconsStyle.thin), size: 64, color: AppColors.surfaceLight),
                                  const SizedBox(height: 16),
                                  Text('Tidak ada temuan di area ini.', style: AppTypography.body1.copyWith(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : (() {
                      final visibleTasks = tasksInArea.take(_limit).toList();
                      final hasMore = tasksInArea.length > _limit;
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.all(24),
                          children: [
                            ...visibleTasks.map((task) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildExactTaskCard(
                                context,
                                title: _getReportTitle(task),
                                dateString: task['date']?.toString(),
                                rawStatus: task['status']?.toString() ?? 'Pending',
                                tag: _getPicStatusTag(task),
                                reportId: task['id'].toString(),
                              ),
                            )),
                            if (hasMore)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 8),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _limit = tasksInArea.length;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                                  ),
                                  child: Text(
                                    'Tampilkan ${tasksInArea.length - _limit} Temuan Lainnya',
                                    style: AppTypography.body1.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    })(),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE UI COMPONENT ---

  Color _getColorByPicStatus(String statusTag) {
    switch (statusTag.toLowerCase()) {
      case 'pending': return const Color(0xFFD4D8FF); // Ungu Muda
      case 'follow up done': return const Color(0xFFFAFF9F); // Kuning Muda
      case 'approved': return const Color(0xFFC1F0D0); // Hijau Muda (Completed)
      case 'pending rejected': return const Color(0xFFFFCDD2); // Merah Muda (Pink)
      default: return const Color(0xFFFFFFFF);
    }
  }

  String _canonicalStatus(dynamic raw) {
    final value = raw?.toString().trim().toLowerCase() ?? '';
    return value.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  // Helper untuk menentukan status sebenarnya dari report (sama seperti di petugas/supervisor)
  String _getActualStatus(Map<String, dynamic> report) {
    final followUps = report['followUps'] as List<dynamic>? ??
                      report['follow_ups'] as List<dynamic>? ?? [];

    if (followUps.isNotEmpty) {
      final lastFollowUp = followUps.last as Map<String, dynamic>;
      final lastStatus = _canonicalStatus(lastFollowUp['status']);

      // Jika follow-up terakhir rejected, maka status report adalah "Pending Rejected"
      if (lastStatus == 'rejected') {
        return 'Pending Rejected';
      }
    }

    final rawStatus = report['status'];
    final status = _canonicalStatus(rawStatus);
    debugPrint('[PicFindingScreen] status normalization raw=$rawStatus canonical=$status');

    if (status == 'pending') return 'Pending';
    if (status == 'followupdone' || status == 'followedup' || status == 'followup') {
      return 'Follow Up Done';
    }
    if (status == 'completed' || status == 'approved' || status == 'done') {
      return 'Completed';
    }
    if (status == 'canceled' || status == 'cancelled') {
      return 'Canceled';
    }

    // Default ke status report
    return report['status']?.toString() ?? 'Pending';
  }

  String _getPicStatusTag(Map<String, dynamic> report) {
    // Gunakan actual status yang sama dengan petugas/supervisor
    final actualStatus = _getActualStatus(report);
    final normalized = _canonicalStatus(actualStatus);
    debugPrint('[PicFindingScreen] tag mapping actual=$actualStatus normalized=$normalized');

    // Penamaan POV PIC
    if (normalized == 'pendingrejected') {
      return 'Pending Rejected';
    } else if (normalized == 'completed' || normalized == 'approved') {
      return 'Approved'; // POV PIC melihat Completed sebagai Approved
    } else if (normalized == 'followupdone' || normalized == 'followedup' || normalized == 'followup') {
      return 'Follow Up Done';
    } else if (normalized == 'pending') {
      return 'Pending';
    }

    return actualStatus; // Pending
  }

  String _resolveTaskAreaLabel(Map<String, dynamic> report) {
    final candidates = [
      report['area_name'],
      report['areaName'],
      report['area_description'],
      report['areaDescription'],
      report['area'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  Widget _buildExactTaskCard(
    BuildContext context, {
    required String title,
    required String? dateString,
    required String rawStatus,
    required String tag,
    required String reportId,
  }) {
    final Color bgColor = _getColorByPicStatus(tag);
    final Color textColor = const Color(0xFF1E1E1E);
    final Color stripeColor = Colors.black.withValues(alpha: 0.05);

    return InkWell(
      onTap: () => context.pushNamed(RouteNames.taskDetail, pathParameters: {'id': reportId}),
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
            Positioned.fill(child: CustomPaint(painter: _CardStripedPainter(color: stripeColor))),
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
                          style: AppTypography.h2.copyWith(color: textColor, fontSize: 18, fontWeight: FontWeight.w600, height: 1.2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tag, style: AppTypography.caption.copyWith(
                          color: tag == 'Pending Rejected' ? Colors.redAccent : const Color(0xFF6B6E94),
                          fontWeight: FontWeight.w700
                        )),
                      )
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

  DateTime _safeParseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
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
