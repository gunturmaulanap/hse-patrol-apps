import '../../data/models/hse_report_model.dart';

abstract class ReportRepository {
  Future<List<HseReportModel>> getReports();
}
