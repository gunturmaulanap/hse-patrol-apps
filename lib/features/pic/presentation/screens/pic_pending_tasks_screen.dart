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

class PicPendingTasksScreen extends ConsumerWidget {
  const PicPendingTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mockDatabaseProvider);
    final user = ref.watch(currentUserProvider);

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

    final areaAccess = user.areaAccess;

    // Filter Task:
    // 1. Hanya Area yang dimiliki PIC
    // 2. Status Pending (Termasuk Rejected yang revert ke Pending)
    final pendingTasks = db.reports.where((r) {
      final isMyArea = areaAccess.contains(r['area']);
      final isPending = r['status'] == 'Pending';
      return isMyArea && isPending;
    }).toList()
      ..sort((a, b) => DateTime.parse(b['date'] as String).compareTo(DateTime.parse(a['date'] as String)));

    // Pisahkan mana yang benar-benar baru, mana yang Rejected (urgent)
    final rejectedTasks = pendingTasks.where((r) => _getPicStatusTag(r) == 'Rejected').toList();
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
                    Text('Ditolak (Perlu Revisi)', style: AppTypography.h3),
                    const SizedBox(height: 16),
                    ...rejectedTasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildExactTaskCard(
                        context,
                        title: _getMockTitle(task),
                        area: task['area']?.toString() ?? '-',
                        dateString: task['date']?.toString(),
                        tag: 'Rejected',
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
                        title: _getMockTitle(task),
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
  String _getPicStatusTag(Map<String, dynamic> report) {
    final status = report['status']?.toString() ?? 'Pending';
    if (status == 'Pending') {
      final followUps = report['followUps'] as List<dynamic>? ?? [];
      final isRejected = followUps.any((f) => f['action'] == 'Rejected');
      if (isRejected) return 'Rejected';
    }
    return 'Pending';
  }

  Color _getColorByPicStatus(String statusTag) {
    if (statusTag == 'Rejected') return const Color(0xFFFFD4D4); // Merah Muda
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

  String _getMockTitle(Map<String, dynamic> report) {
    final cause = report['rootCause']?.toString() ?? '-';
    return 'Temuan: $cause';
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