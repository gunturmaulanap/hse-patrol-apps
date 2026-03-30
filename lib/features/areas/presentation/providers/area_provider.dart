import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/area_remote_datasource.dart';
import '../../data/repositories/area_repository_impl.dart';
import '../../domain/repositories/area_repository.dart';
import '../../data/models/area_model.dart';

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
