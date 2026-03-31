import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../../../../app/router/route_names.dart';
import '../../../pic/presentation/providers/pic_follow_up_provider.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  // Modal Penolakan Modern / Pembatalan / Persetujuan
  void _handlePetugasReview(MockDatabase db, String action) async {
    String? reason;
    bool isConfirm = false;

    if (action == 'Rejected' || action == 'Canceled') {
      final isCancel = action == 'Canceled';
      final controller = TextEditingController();
      reason = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
          title: Text(isCancel ? 'Batalkan Laporan' : 'Tolak Perbaikan', style: AppTypography.h3),
          content: TextField(
            controller: controller,
            style: AppTypography.body1,
            decoration: InputDecoration(
              hintText: isCancel ? 'Tuliskan alasan spesifik pembatalan...' : 'Misal: Pagar pembatas tidak dilas permanen...',
              hintStyle: AppTypography.caption,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium), borderSide: BorderSide.none),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Kembali', style: AppTypography.body1.copyWith(color: AppColors.textSecondary))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCancel ? Colors.redAccent : Colors.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
                onPressed: () {
                  if (controller.text.trim().isEmpty) {
                    AppSnackBar.warning(ctx, message: 'Alasan wajib diisi!');
                    return;
                  }
                  Navigator.pop(ctx, controller.text.trim());
                },
                child: Text(isCancel ? 'Konfirmasi Batal' : 'Tolak', style: AppTypography.body1.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
      );
      if (reason == null) return;
    } else if (action == 'Approved') {
      isConfirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
          title: Text('Terima Perbaikan?', style: AppTypography.h3),
          content: Text('Apakah Anda yakin tindak lanjut sudah sesuai standar?', style: AppTypography.body1.copyWith(color: AppColors.textSecondary)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal', style: AppTypography.body1.copyWith(color: AppColors.textSecondary))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill))),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Ya, Terima', style: AppTypography.body1.copyWith(color: AppColors.textInverted, fontWeight: FontWeight.bold))),
          ],
        ),
      ) ?? false;
      if (!isConfirm) return;
    }

    db.updateReportStatus(widget.reportId, action, rejectedReason: reason);
    setState(() {});

    final snackBarMsg = action == 'Approved' ? 'Tugas Selesai!' : (action == 'Rejected' ? 'Perbaikan ditolak!' : 'Laporan Dibatalkan!');

    if (action == 'Approved') {
      AppSnackBar.success(context, message: snackBarMsg);
    } else if (action == 'Rejected') {
      AppSnackBar.error(context, message: snackBarMsg);
    } else {
      AppSnackBar.warning(context, message: snackBarMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mockDatabaseProvider);
    final user = ref.watch(currentUserProvider);

    final rptIndex = db.reports.indexWhere((r) => r['id'].toString() == widget.reportId.toString());

    if (rptIndex == -1) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => context.pop()),
          title: Text('Detail', style: AppTypography.h3.copyWith(color: Colors.white)),
        ),
        body: Center(child: Text('Laporan tidak ditemukan.', style: AppTypography.body1.copyWith(color: Colors.white))),
      );
    }

    final rpt = db.reports[rptIndex];
    final isPic = user?.role == 'pic';
    final isPetugas = user?.role == 'petugas';
    final status = rpt['status']?.toString() ?? 'Pending';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20), onPressed: () => context.pop()),
        title: Text('Task Detail', style: AppTypography.h3),
        centerTitle: true,
        // ACTION Dihapus: Tombol cancel tidak lagi di App Bar
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 140), // Ruang lega untuk action area
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroCard(rpt, status),
                  const SizedBox(height: 24),
                  Text("Informasi Laporan", style: AppTypography.h3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard(PhosphorIcons.mapPin(), 'Lokasi', rpt['area']?.toString() ?? '-')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInfoCard(PhosphorIcons.warningCircle(), 'Risiko', rpt['riskLevel']?.toString() ?? '-', iconColor: rpt['riskLevel']?.toString() == 'Kritis' ? Colors.redAccent : AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(PhosphorIcons.clock(), 'Waktu Dilaporkan', _formatDate(rpt['date']?.toString())),
                  const SizedBox(height: 24),
                  _buildSectionBox('Catatan Temuan', rpt['notes']?.toString() ?? '-', PhosphorIcons.notePencil()),
                  const SizedBox(height: 16),
                  _buildSectionBox('Akar Masalah (Root Cause)', rpt['rootCause']?.toString() ?? '-', PhosphorIcons.treeStructure()),
                  const SizedBox(height: 24),

                  if (rpt['photos'] != null && (rpt['photos'] as List).isNotEmpty) ...[
                    Text("Lampiran Bukti", style: AppTypography.h3),
                    const SizedBox(height: 12),
                    _buildPhotoGrid(List<String>.from(rpt['photos'])),
                    const SizedBox(height: 32),
                  ],

                  Builder(builder: (context) {
                    final followUps = rpt['followUps'] as List<dynamic>? ?? [];
                    if (followUps.isEmpty) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Riwayat Tindak Lanjut", style: AppTypography.h3),
                        const SizedBox(height: 16),
                        ...followUps.asMap().entries.map((entry) {
                          final isLast = entry.key == followUps.length - 1;
                          return _buildTimelineItem(entry.value as Map<String, dynamic>, isLast);
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  // UX IMPROVEMENT: Danger Zone untuk membatalkan Task (Bawah Halaman)
                  if (isPetugas && (status == 'Pending' || status == 'Follow Up Done'))
                    _buildDangerZone(),
                ],
              ),
            ),
            _buildFloatingActionArea(isPic, isPetugas, status, db),
          ],
        ),
      ),
    );
  }

  // Helper Custom Card Danger Zone Pembatalan (User Friendly UX)
  Widget _buildDangerZone() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: Colors.redAccent, size: 24),
              const SizedBox(width: 8),
              Text('Batalkan Laporan', style: AppTypography.h3.copyWith(color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Laporan hanya dapat dibatalkan jika laporan ternyata merupakan duplikat, tidak valid, atau masalah telah terselesaikan oleh tim lain tanpa memerlukan tindak lanjut PIC.',
            style: AppTypography.caption.copyWith(color: AppColors.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
              onPressed: () {
                final db = ref.read(mockDatabaseProvider);
                _handlePetugasReview(db, 'Canceled');
              },
              child: Text(
                'Batalkan Laporan Ini',
                style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Map<String, dynamic> rpt, String status) {
    // Sinkronisasi logika warna persis dengan helper list card
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = const Color(0xFFD4D8FF); // Soft Purple
        break;
      case 'follow up done':
        bgColor = const Color(0xFFFAFF9F); // Soft Yellow
        break;
      case 'completed':
        bgColor = const Color(0xFFC1F0D0); // Soft Mint Green
        break;
      case 'canceled':
        bgColor = const Color(0xFFE5E5E5); // Soft Gray
        break;
      default:
        bgColor = const Color(0xFFFFFFFF);
    }
    
    Color textColor = const Color(0xFF1E1E1E);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTypography.caption.copyWith(color: textColor, fontWeight: FontWeight.bold),
                ),
              ),
              PhosphorIcon(PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill), color: textColor, size: 28),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Inspeksi ${rpt['area'] ?? '-'}',
            style: AppTypography.caption.copyWith(color: textColor.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            rpt['rootCause']?.toString() ?? 'Inspeksi Area',
            style: AppTypography.h1.copyWith(color: textColor, height: 1.1),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(PhosphorIconData icon, String title, String value, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: PhosphorIcon(icon, color: iconColor ?? AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.caption),
                const SizedBox(height: 4),
                Text(value, style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionBox(String title, String content, PhosphorIconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.body1.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: AppTypography.body1.copyWith(height: 1.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> log, bool isLast) {
    final isPicLog = log['type']?.toString() == 'PIC_FOLLOW_UP';
    final action = log['action']?.toString();

    Color dotColor = AppColors.secondary;
    if (action == 'Rejected') dotColor = Colors.redAccent;
    if (action == 'Approved') dotColor = AppColors.primary;
    if (action == 'Canceled') dotColor = Colors.orangeAccent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(width: 16, height: 16, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 3))),
                if (!isLast) Expanded(child: Container(width: 2, color: AppColors.surfaceLight))
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.medium)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPicLog ? 'Tindak Lanjut PIC' : 'Review Petugas (${action ?? "Unknown"})',
                      style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold, color: dotColor),
                    ),
                    if (log['notes'] != null && log['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(log['notes'].toString(), style: AppTypography.caption),
                    ],
                    if (isPicLog && log['photos'] != null && (log['photos'] as List).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildPhotoGrid(List<String>.from(log['photos'] as List), height: 60),
                    ]
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> paths, {double height = 80}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: paths.map((p) {
          final isNetwork = p.toString().startsWith('http');
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isNetwork
                  ? Image.network(p.toString(), width: height, height: height, fit: BoxFit.cover, errorBuilder: (ctx, err, stk) => _errorImage(height))
                  : Image.file(File(p.toString()), width: height, height: height, fit: BoxFit.cover, errorBuilder: (ctx, err, stk) => _errorImage(height)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _errorImage(double height) {
    return Container(width: height, height: height, color: AppColors.surface, child: Icon(Icons.broken_image, color: AppColors.textSecondary));
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildFloatingActionArea(bool isPic, bool isPetugas, String status, MockDatabase db) {
    Widget? actionWidget;

    if (isPic && (status == 'Pending')) {
      actionWidget = AppButton(
        text: 'Mulai Tindak Lanjut',
        onPressed: () {
          ref.read(picFollowUpFormProvider.notifier).setReportId(widget.reportId);
          context.pushNamed(RouteNames.picFollowUpPhotos);
        },
      );
    } else if (isPetugas && status == 'Follow Up Done') {
      actionWidget = Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Tolak',
              type: AppButtonType.outlined,
              onPressed: () => _handlePetugasReview(db, 'Rejected'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: 'Selesai',
              onPressed: () => _handlePetugasReview(db, 'Approved'),
            ),
          ),
        ],
      );
    }

    if (actionWidget == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surfaceLight.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: actionWidget,
      ),
    );
  }
}