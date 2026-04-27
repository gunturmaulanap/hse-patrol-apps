import '../entities/task_detail.dart';
import '../entities/timeline_entry.dart';

class TaskDetailMapper {
  const TaskDetailMapper._();

  static TaskDetail fromMap(Map<String, dynamic> map) {
    return TaskDetail.fromMap(map);
  }

  static List<TimelineEntry> timelineFromList(List<dynamic> rawList) {
    return rawList
        .whereType<Map>()
        .map((item) => TimelineEntry.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}
