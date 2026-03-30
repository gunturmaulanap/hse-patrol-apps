import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_card.dart';
import '../providers/report_provider.dart';

class PicFindingPage extends ConsumerWidget {
  const PicFindingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsFutureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Finding PIC')),
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(child: Text('Tidak ada temuan.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.name ?? report.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Status: ${report.status.toUpperCase()}', 
                              style: TextStyle(
                                color: report.status == 'pending' ? Colors.orange : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                           IconButton(
                             icon: const Icon(Icons.check_circle, color: Colors.green),
                             onPressed: () {
                               // Action approve
                             },
                           ),
                           IconButton(
                             icon: const Icon(Icons.cancel, color: Colors.red),
                             onPressed: () {
                               // Action reject
                             },
                           ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Gagal memuat temuan: $error')),
      ),
    );
  }
}
