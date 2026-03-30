import '../../../../core/network/dio_client.dart';
import '../models/hse_report_model.dart';
import '../models/create_hse_report_request.dart';

abstract class ReportRemoteDataSource {
  Future<List<HseReportModel>> fetchReports();
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  @override
  Future<List<HseReportModel>> fetchReports() async {
    await Future.delayed(const Duration(seconds: 1));
    return const [
      HseReportModel(
        id: 1,
        code: 'RPT-001',
        userId: 2,
        areaId: 1,
        name: 'Kerusakan Atap Gudang',
        riskLevel: 'high',
        rootCause: 'Cuaca buruk',
        notes: 'Atap bocor di bagian timur',
        status: 'pending',
      ),
      HseReportModel(
        id: 2,
        code: 'RPT-002',
        userId: 2,
        areaId: 2,
        name: 'Mesin Overheat',
        riskLevel: 'medium',
        rootCause: 'Kurang perawatan',
        notes: 'Mesin produksi A terlalu panas',
        status: 'approved',
      ),
    ];
  }
}
