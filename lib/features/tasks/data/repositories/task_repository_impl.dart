import 'dart:io';
import '../../domain/repositories/task_repository.dart';
import '../datasource/task_remote_datasource.dart';
import '../models/hse_task_model.dart';
import '../models/create_hse_task_request.dart';
import '../models/hse_staff_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<HseTaskModel>> getTasks({int? areaId, String? status}) async {
    return _remoteDataSource.fetchTasks(areaId: areaId, status: status);
  }

  @override
  Future<HseTaskModel> getTaskById(int id) async {
    return _remoteDataSource.getTaskById(id);
  }

  @override
  Future<HseTaskModel> getTaskByPicToken(String picToken) async {
    return _remoteDataSource.getTaskByPicToken(picToken);
  }

  @override
  Future<HseTaskModel> createTask(CreateHseTaskRequest request, List<File>? photos) async {
    return _remoteDataSource.createTask(request, photos);
  }

  @override
  Future<HseTaskModel> updateTask(int id, CreateHseTaskRequest request, {List<File>? photos, String? mode}) async {
    return _remoteDataSource.updateTask(id, request, photos: photos, mode: mode);
  }

  @override
  Future<HseTaskModel> cancelTask(int id, String canceledBy) async {
    return _remoteDataSource.cancelTask(id, canceledBy);
  }

  @override
  Future<List<HseStaffModel>> getStaffs() async {
    return _remoteDataSource.fetchStaffs();
  }

  @override
  Future<List<HseStaffModel>> getPicUsers() async {
    return _remoteDataSource.fetchPicUsers();
  }
}
