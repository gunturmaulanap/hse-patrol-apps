import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/shimmer/base_shimmer.dart';
import '../../../../core/widgets/shimmer/shimmer_box.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../areas/presentation/providers/area_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class PicPendingTasksScreen extends ConsumerWidget {
  const PicPendingTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // Filter Task:
    // 1. Hanya Area yang dimiliki PIC
    // 2. Status yang butuh action PIC: "Pending" atau "Pending Rejected" (Follow Up Done yg di-reject)
    final pendingTasks = reports.where((r) {
      final isMyArea = areaAccess.contains(r['area']);
      final picStatusTag = _getPicStatusTag(r);
      final needsAction = picStatusTag == 'Pending' || picStatusTag == 'Pending Rejected';
      return isMyArea && needsAction;
    }).toList()
      ..sort((a, b) => _safeParseDate(b['date']?.toString()).compareTo(_safeParseDate(a['date']?.toString())));

    if (reportsAsync.isLoading && pendingTasks.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: _PendingTasksShimmer(),
      );
    }

    // Pisahkan mana yang benar-benar baru, mana yang Pending Rejected (urgent)
    final rejectedTasks = pendingTasks.where((r) => _getPicStatusTag(r) == 'Pending Rejected').toList();
    final newTasks = pendingTasks.where((r) => _getPicStatusTag(r) == 'Pending').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.goNamed(RouteNames.picHome),
        ),
        title: Text('Action Required', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: pendingTasks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), size: 64, color: Colors.green),
                    ),
                    const SizedBox(height: 24),
                    Text('All Caught Up!', style: AppTypography.h2),
                    const SizedBox(height: 8),
                    Text('Tidak ada tugas pending saat ini.', style: AppTypography.body1.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Alert Banner Jika Ada Task Rejected (Sangat Urgent)
                  if (rejectedTasks.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD4D4), // Merah Muda Card Rejected
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        border: Border.all(color: Colors.redAccent, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                            child: Icon(PhosphorIcons.warning(PhosphorIconsStyle.fill), color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Urgent Revision Needed', style: AppTypography.body1.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Terdapat ${rejectedTasks.length} tindak lanjut yang ditolak oleh petugas.', style: AppTypography.caption.copyWith(color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Pending Rejected (Perlu Revisi)', style: AppTypography.h3),
                    const SizedBox(height: 16),
                    ...rejectedTasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                        child: _buildExactTaskCard(
                          context,
                          title: _getReportTitle(task),
                          area: task['area']?.toString() ?? '-',
                          dateString: task['date']?.toString(),
                          tag: 'Pending Rejected',
                        reportId: task['id'].toString(),
                      ),
                    )),
                    const SizedBox(height: 24),
                  ],

                  // Daftar Tugas Baru (Pending)
                  if (newTasks.isNotEmpty) ...[
                    Text('Tugas Baru', style: AppTypography.h3),
                    const SizedBox(height: 16),
                    ...newTasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                        child: _buildExactTaskCard(
                          context,
                          title: _getReportTitle(task),
                          area: task['area']?.toString() ?? '-',
                          dateString: task['date']?.toString(),
                          tag: 'Pending',
                        reportId: task['id'].toString(),
                      ),
                    )),
                  ],
                  const SizedBox(height: 100), // Spacing bawah untuk bottom nav dan FAB
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed(RouteNames.picHome),
        backgroundColor: AppColors.primary,
        icon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill), color: AppColors.textInverse),
        label: Text('Back to Home', style: AppTypography.body1.copyWith(
          color: AppColors.textInverse,
          fontWeight: FontWeight.bold
        )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- Helpers ---

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

  Color _getColorByPicStatus(String statusTag) {
    if (statusTag == 'Pending Rejected') return const Color(0xFFFFCDD2); // Merah Muda (Pink)
    return const Color(0xFFD4D8FF); // Ungu Muda (Pending biasa)
  }

  Widget _buildExactTaskCard(
    BuildContext context, {
    required String title,
    required String area,
    required String? dateString,
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill), size: 14, color: textColor.withValues(alpha: 0.6)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(area, style: AppTypography.caption.copyWith(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600))),
                    ],
                  ),
                  const SizedBox(height: 16),
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

class _PendingTasksShimmer extends StatelessWidget {
  const _PendingTasksShimmer();

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
                  const ShimmerBox(width: 200, height: 28),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 300, height: 16),
                ],
              ),
            ),
          ),
          // Alert banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BaseShimmer(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
