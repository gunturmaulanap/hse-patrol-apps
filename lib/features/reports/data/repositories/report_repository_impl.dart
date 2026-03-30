import '../../domain/repositories/report_repository.dart';
import '../datasource/report_remote_datasource.dart';
import '../models/hse_report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<HseReportModel>> getReports() async {
    return _remoteDataSource.fetchReports();
  }
}
