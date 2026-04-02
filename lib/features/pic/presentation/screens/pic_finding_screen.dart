import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../providers/active_area_filter_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class PicFindingScreen extends ConsumerWidget {
  const PicFindingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeArea = ref.watch(activeAreaFilterProvider);
    final reportsAsync = ref.watch(petugasTaskMapsProvider);
    final reports = reportsAsync.valueOrNull ?? <Map<String, dynamic>>[];

    // Ambil data task khusus untuk area yang dipilih.
    // Sembunyikan task yang sudah di Canceled oleh petugas.
    final tasksInArea = reports.where((r) {
      final isAreaMatch = (r['area']?.toString() ?? '') == activeArea;
      final isNotCanceled = r['status'] != 'Canceled';
      return isAreaMatch && isNotCanceled;
    }).toList()
      ..sort((a, b) => _safeParseDate(b['date']?.toString()).compareTo(_safeParseDate(a['date']?.toString())));

    // Hitung status untuk insight
    final pendingCount = tasksInArea.where((r) => r['status'] == 'Pending').length;

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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.folderOpen(PhosphorIconsStyle.thin), size: 64, color: AppColors.surfaceLight),
                          const SizedBox(height: 16),
                          Text('Tidak ada temuan di area ini.', style: AppTypography.body1.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: tasksInArea.length,
                      itemBuilder: (context, index) {
                        final task = tasksInArea[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                            child: _buildExactTaskCard(
                              context,
                              title: _getReportTitle(task),
                              dateString: task['date']?.toString(),
                              rawStatus: task['status']?.toString() ?? 'Pending',
                              tag: _getPicStatusTag(task),
                              reportId: task['id'].toString(),
                          ),
                        );
                      },
                    ),
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
      case 'rejected': return const Color(0xFFFFD4D4); // Merah Muda
      default: return const Color(0xFFFFFFFF);
    }
  }

  String _getPicStatusTag(Map<String, dynamic> report) {
    final status = report['status']?.toString() ?? 'Pending';
    
    // Logika POV PIC: Jika status Pending tapi ada history rejected, tampilkan Rejected
    if (status == 'Pending') {
      final followUps = report['followUps'] as List<dynamic>? ?? [];
      final isRejected = followUps.any((f) => f['action'] == 'Rejected');
      if (isRejected) return 'Rejected';
      return 'Pending';
    } else if (status == 'Completed') {
      return 'Approved'; // POV PIC melihatnya sebagai Approved
    }
    return status; // Follow Up Done
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
                          color: tag == 'Rejected' ? Colors.redAccent : const Color(0xFF6B6E94), 
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
