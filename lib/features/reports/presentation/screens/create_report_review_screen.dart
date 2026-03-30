import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_report_form_provider.dart';

class CreateReportReviewScreen extends ConsumerStatefulWidget {
  const CreateReportReviewScreen({super.key});

  @override
  ConsumerState<CreateReportReviewScreen> createState() => _CreateReportReviewScreenState();
}

class _CreateReportReviewScreenState extends ConsumerState<CreateReportReviewScreen> {
  bool _isSubmitting = false;

  void _submitData() async {
    setState(() => _isSubmitting = true);
    
    final success = await ref.read(createReportFormProvider.notifier).submitReport();
    
    if (success && mounted) {
      ref.read(createReportFormProvider.notifier).reset();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Berhasil!'),
          content: const Text('Laporan Patroli berhasil dikirim.'),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            AppButton(
              text: 'Bagikan via WhatsApp',
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedShare01,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () async {
                final url = Uri.parse("whatsapp://send?text=Laporan Patroli Baru telah dibuat di aplikasi HSE Aksamala.");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
                if (ctx.mounted) {
                  ctx.pop();
                  context.goNamed(RouteNames.petugasHome);
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              text: 'Selesai',
              type: AppButtonType.outlined,
              onPressed: () {
                ctx.pop();
                context.goNamed(RouteNames.petugasHome);
              },
            ),
          ],
        ),
      );
    }
    
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createReportFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Laporan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Langkah 7 dari 7',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tinjauan Laporan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 32),
                  _buildRow('Jenis Bangunan', draft.buildingType ?? '-'),
                  _buildRow('Lokasi Area', draft.area ?? '-'),
                  _buildRow('Tingkat Risiko', draft.riskLevel ?? '-'),
                  _buildRow('Total Foto', '${draft.photos.length} Foto'),
                  _buildRow('Keterangan', draft.notes ?? '-'),
                  _buildRow('Akar Masalah', draft.rootCause ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              text: 'Kirim Laporan',
              isLoading: _isSubmitting,
              onPressed: _submitData,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: 'Kembali Edit',
              type: AppButtonType.outlined,
              onPressed: _isSubmitting ? null : () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
