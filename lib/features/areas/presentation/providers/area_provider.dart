import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/area_remote_datasource.dart';
import '../../data/repositories/area_repository_impl.dart';
import '../../domain/repositories/area_repository.dart';
import '../../data/models/area_model.dart';
import '../../../../core/mock_api/mock_database.dart';

final areaRemoteDataSourceProvider = Provider<AreaRemoteDataSource>((ref) {
  return AreaRemoteDataSourceImpl();
});

final areaRepositoryProvider = Provider<AreaRepository>((ref) {
  final remote = ref.read(areaRemoteDataSourceProvider);
  return AreaRepositoryImpl(remote);
});

final areasFutureProvider = FutureProvider<List<AreaModel>>((ref) async {
  final repository = ref.watch(areaRepositoryProvider);
  return repository.getAreas();
});

final areaProvider = FutureProvider<List<AreaModel>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final isMockRoleTesting = (currentUser?.email ?? '').toLowerCase().endsWith('@aksamala.test');

  if (isMockRoleTesting) {
    return _buildMockAreas(ref.read(mockDatabaseProvider));
  }

  try {
    final repository = ref.watch(areaRepositoryProvider);
    return repository.getAreas();
  } catch (_) {
    return _buildMockAreas(ref.read(mockDatabaseProvider));
  }
});

List<AreaModel> _buildMockAreas(MockDatabase db) {
  final seen = <String>{};
  final areas = <AreaModel>[];

  for (final report in db.reports) {
    final areaName = (report['area']?.toString() ?? '').trim();
    if (areaName.isEmpty || seen.contains(areaName)) continue;
    seen.add(areaName);

    areas.add(
      AreaModel(
        id: areas.length + 1,
        code: 'MOCK-${areas.length + 1}',
        name: areaName,
        buildingType: report['buildingType']?.toString() ?? 'General',
      ),
    );
  }

  return areas;
}
