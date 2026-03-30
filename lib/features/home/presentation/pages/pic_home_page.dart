import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../../areas/presentation/providers/area_provider.dart';

class PicHomePage extends ConsumerWidget {
  const PicHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(areasFutureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home PIC (Areas)')),
      body: areasAsync.when(
        data: (areas) {
          if (areas.isEmpty) {
            return const Center(child: Text('Tidak ada akses area pada akun ini.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: areas.length,
            itemBuilder: (context, index) {
              final area = areas[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(area.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Kode: ${area.code} | Tipe: ${area.buildingType}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Gagal memuat area: $error')),
      ),
    );
  }
}
