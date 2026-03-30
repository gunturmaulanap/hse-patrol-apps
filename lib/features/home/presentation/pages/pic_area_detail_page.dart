import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';

import '../../../areas/data/models/area_model.dart';
import '../../../reports/presentation/providers/report_provider.dart';

class PicAreaDetailPage extends ConsumerWidget {
  final AreaModel area;

  const PicAreaDetailPage({super.key, required this.area});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsFutureProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Detail Area: ${area.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: reportsAsync.when(
        data: (reports) {
          final areaReports = reports.where((r) => r.areaId == area.id).toList();
          
          if (areaReports.isEmpty) {
             return const Center(child: Text('Belum ada laporan di area ini.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: areaReports.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final report = areaReports[index];
              final isActionable = report.status == 'pending' || report.status == 'rejected';

              return GFCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                boxFit: BoxFit.cover,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                titlePosition: GFPosition.start,
                title: GFListTile(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  avatar: GFAvatar(
                    backgroundColor: report.status == 'rejected' ? GFColors.DANGER 
                                   : (report.status == 'pending' ? GFColors.WARNING : GFColors.SUCCESS),
                    child: Icon(
                      report.status == 'rejected' ? Icons.warning : (report.status == 'pending' ? Icons.pending_actions : Icons.check),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(report.name ?? report.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subTitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Status: ${report.status.toUpperCase()}', style: TextStyle(
                      color: report.status == 'rejected' ? GFColors.DANGER 
                           : (report.status == 'pending' ? GFColors.WARNING : GFColors.SUCCESS),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    )),
                  ),
                ),
                content: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(report.notes, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                ),
                buttonBar: GFButtonBar(
                 padding: const EdgeInsets.only(top: 12),
                 children: [
                   if (isActionable)
                     GFButton(
                       onPressed: () {
                         // Action followup target
                       },
                       text: 'Evaluasi / Verifikasi',
                       color: GFColors.PRIMARY,
                       fullWidthButton: true,
                       shape: GFButtonShape.pills,
                       size: GFSize.LARGE,
                     )
                   else
                     GFButton(
                       onPressed: () {},
                       text: 'Lihat Detail Komplit',
                       color: GFColors.LIGHT,
                       textColor: GFColors.DARK,
                       fullWidthButton: true,
                       shape: GFButtonShape.pills,
                       size: GFSize.LARGE,
                     )
                 ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
