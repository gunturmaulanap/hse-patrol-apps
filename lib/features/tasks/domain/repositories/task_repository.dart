import 'dart:io';
import '../../data/models/hse_task_model.dart';
import '../../data/models/create_hse_task_request.dart';

abstract class TaskRepository {
  Future<List<HseTaskModel>> getTasks({int? areaId, String? status});
  Future<HseTaskModel> getTaskById(int id);
  Future<HseTaskModel> getTaskByPicToken(String picToken);
  Future<HseTaskModel> createTask(CreateHseTaskRequest request, List<File>? photos);
  Future<HseTaskModel> updateTask(int id, CreateHseTaskRequest request, {List<File>? photos, String? mode});
  Future<void> cancelTask(int id);
}
