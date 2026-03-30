import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';
import '../../data/models/hse_report_model.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSourceImpl();
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final remote = ref.read(reportRemoteDataSourceProvider);
  return ReportRepositoryImpl(remote);
});

final reportsFutureProvider = FutureProvider<List<HseReportModel>>((ref) async {
  final repository = ref.watch(reportRepositoryProvider);
  return repository.getReports();
});
