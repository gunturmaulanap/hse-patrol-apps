import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_task_form_provider.dart';
import '../../../areas/presentation/providers/area_provider.dart';
import '../../../areas/data/models/area_model.dart';

class CreateTaskLocationScreen extends ConsumerStatefulWidget {
  const CreateTaskLocationScreen({super.key});

  @override
  ConsumerState<CreateTaskLocationScreen> createState() => _CreateTaskLocationScreenState();
}

class _CreateTaskLocationScreenState extends ConsumerState<CreateTaskLocationScreen> {
  AreaModel? _selectedArea;

  @override
  void initState() {
    super.initState();
    // TODO: Nanti jika sudah ada API building type, filter areas by building type di sini
    // final buildingType = ref.read(createTaskFormProvider).buildingType;
    // Untuk sekarang, tampilkan semua areas tanpa filter

    // Load selected area dari state provider jika ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final draft = ref.read(createTaskFormProvider);
      final areasAsync = ref.read(areaProvider);
      final areas = areasAsync.valueOrNull ?? [];

      if (draft.areaId != null && areas.isNotEmpty) {
        final existingArea = areas.firstWhere(
          (area) => area.id == draft.areaId,
          orElse: () => areas.first,
        );
        setState(() {
          _selectedArea = existingArea;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final areasAsync = ref.watch(areaProvider);

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

            // Dropdown from Backend API
            areasAsync.when(
              data: (areas) {
                return DropdownButtonFormField<AreaModel>(
                  decoration: InputDecoration(
                    labelText: 'Nama Area / Lokasi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  initialValue: _selectedArea,
                  items: areas.map((area) {
                    return DropdownMenuItem(
                      value: area,
                      child: Text(area.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedArea = val;
                    });
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Gagal memuat area: $error'),
              ),
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
                            ref.read(createTaskFormProvider.notifier).setArea(_selectedArea!.name);
                            ref.read(createTaskFormProvider.notifier).setAreaId(_selectedArea!.id);
                            context.pushNamed(RouteNames.petugasCreateTaskRisk);
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
