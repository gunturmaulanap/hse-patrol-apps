import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_report_form_provider.dart';

class CreateReportLocationScreen extends ConsumerStatefulWidget {
  const CreateReportLocationScreen({super.key});

  @override
  ConsumerState<CreateReportLocationScreen> createState() => _CreateReportLocationScreenState();
}

class _CreateReportLocationScreenState extends ConsumerState<CreateReportLocationScreen> {
  String? _selectedArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Temuan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Langkah 2 dari 7',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Text(
              'Pilih Area Spesifik',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Detailkan di mana temuan ini didapatkan.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Dropdown Mockup
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Nama Area / Lokasi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: _selectedArea,
              items: const [
                DropdownMenuItem(value: 'Area Produksi 1 - Mesin Bubut', child: Text('Area Produksi 1 - Mesin Bubut')),
                DropdownMenuItem(value: 'Area Produksi 2 - Assembly', child: Text('Area Produksi 2 - Assembly')),
                DropdownMenuItem(value: 'Gudang Bahan Baku Utama', child: Text('Gudang Bahan Baku Utama')),
                DropdownMenuItem(value: 'Koridor Evakuasi Barat', child: Text('Koridor Evakuasi Barat')),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedArea = val;
                });
              },
            ),
            
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Kembali',
                    type: AppButtonType.outlined,
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    text: 'Lanjutkan',
                    onPressed: _selectedArea != null
                        ? () {
                            ref.read(createReportFormProvider.notifier).setArea(_selectedArea!);
                            context.pushNamed(RouteNames.petugasCreateReportRisk);
                          }
                        : null,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
