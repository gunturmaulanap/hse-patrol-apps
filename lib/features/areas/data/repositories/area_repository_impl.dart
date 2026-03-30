import '../../domain/repositories/area_repository.dart';
import '../datasource/area_remote_datasource.dart';
import '../models/area_model.dart';

class AreaRepositoryImpl implements AreaRepository {
  final AreaRemoteDataSource _remoteDataSource;

  AreaRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AreaModel>> getAreas() async {
    return _remoteDataSource.fetchAreas();
  }
}
