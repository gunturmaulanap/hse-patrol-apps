import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/models/hse_task_model.dart';
import '../../../../core/mock_api/mock_database.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final remote = ref.read(taskRemoteDataSourceProvider);
  return TaskRepositoryImpl(remote);
});

final tasksFutureProvider = FutureProvider<List<HseTaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTasks();
});

final petugasTaskMapsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final isMockRoleTesting = (currentUser?.email ?? '').toLowerCase().endsWith('@aksamala.test');

  if (isMockRoleTesting) {
    final db = ref.read(mockDatabaseProvider);
    final mapped = db.reports.map((task) {
      final areaName = task['area']?.toString() ?? 'Unknown Area';
      final rootCause = task['rootCause']?.toString() ?? '-';

      return <String, dynamic>{
        'id': task['id']?.toString() ?? '',
        'title': (task['title']?.toString().trim().isNotEmpty ?? false)
            ? task['title'].toString().trim()
            : 'Inspeksi $areaName - Masalah: $rootCause',
        'area': areaName,
        'rootCause': rootCause,
        'notes': task['notes']?.toString() ?? '-',
        'riskLevel': task['riskLevel']?.toString() ?? '-',
        'status': _normalizeStatus(task['status']?.toString() ?? 'Pending'),
        'date': task['date']?.toString(),
        'userId': _toInt(task['userId']),
        'staffName': task['staffName']?.toString() ?? 'HSE Staff Demo',
      };
    }).toList();

    if (currentUser?.role == 'petugas') {
      final currentUserId = _toInt(currentUser?.id);
      return mapped.where((task) => _toInt(task['userId']) == currentUserId).toList();
    }

    return mapped;
  }

  try {
    final tasks = await ref.watch(tasksFutureProvider.future);

    return tasks.map((task) {
      final areaName = _resolveAreaName(task);
      final title = _resolveTitle(task, areaName);

      return <String, dynamic>{
        'id': task.id.toString(),
        'title': title,
        'area': areaName,
        'rootCause': task.rootCause,
        'notes': task.notes,
        'riskLevel': '-',
        'status': _normalizeStatus(task.status),
        'date': task.date,
        'userId': task.userId,
        'staffName': _resolveStaffName(task),
      };
    }).toList();
  } catch (_) {
    final db = ref.read(mockDatabaseProvider);

    return db.reports.map((task) {
      final areaName = task['area']?.toString() ?? 'Unknown Area';
      final rootCause = task['rootCause']?.toString() ?? '-';

      return <String, dynamic>{
        'id': task['id']?.toString() ?? '',
        'title': (task['title']?.toString().trim().isNotEmpty ?? false)
            ? task['title'].toString().trim()
            : 'Inspeksi $areaName - Masalah: $rootCause',
        'area': areaName,
        'rootCause': rootCause,
        'notes': task['notes']?.toString() ?? '-',
        'riskLevel': task['riskLevel']?.toString() ?? '-',
        'status': _normalizeStatus(task['status']?.toString() ?? 'Pending'),
        'date': task['date']?.toString(),
        'userId': _toInt(task['userId']),
        'staffName': task['staffName']?.toString() ?? 'HSE Staff Demo',
      };
    }).toList();
  }
});

final supervisorOwnTaskMapsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final allReports = await ref.watch(petugasTaskMapsProvider.future);

  final currentUserId = int.tryParse(currentUser?.id ?? '');
  if (currentUserId == null) return <Map<String, dynamic>>[];

  return allReports.where((report) => _toInt(report['userId']) == currentUserId).toList();
});

final supervisorStaffTaskMapsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final allReports = await ref.watch(petugasTaskMapsProvider.future);

  final currentUserId = int.tryParse(currentUser?.id ?? '');
  if (currentUserId == null) return allReports;

  return allReports.where((report) => _toInt(report['userId']) != currentUserId).toList();
});

final supervisorAllVisibleTaskMapsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final own = await ref.watch(supervisorOwnTaskMapsProvider.future);
  final staff = await ref.watch(supervisorStaffTaskMapsProvider.future);
  return <Map<String, dynamic>>[...own, ...staff];
});

final supervisorStaffNamesProvider = FutureProvider<List<String>>((ref) async {
  final staffTasks = await ref.watch(supervisorStaffTaskMapsProvider.future);
  final names = staffTasks
      .map((task) => (task['staffName']?.toString().trim() ?? ''))
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return names;
});

final supervisorStaffTaskByNameProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, staffName) async {
  final staffTasks = await ref.watch(supervisorStaffTaskMapsProvider.future);

  return staffTasks
      .where((task) => (task['staffName']?.toString().trim() ?? '') == staffName)
      .toList();
});

String _resolveAreaName(HseTaskModel report) {
  return 'Area #${report.areaId}';
}

String _resolveStaffName(HseTaskModel report) {
  return 'HSE Staff #${report.userId}';
}

String _resolveTitle(HseTaskModel report, String areaName) {
  final fromBackend = (report.name ?? '').trim();
  if (fromBackend.isNotEmpty) return fromBackend;

  final rootCause = report.rootCause.trim().isEmpty ? '-' : report.rootCause.trim();
  return 'Inspeksi $areaName - Masalah: $rootCause';
}

String _normalizeStatus(String rawStatus) {
  final value = rawStatus.trim().toLowerCase();

  if (value == 'followupdone' || value == 'follow_up_done') {
    return 'Follow Up Done';
  }

  if (value == 'approved' || value == 'completed') {
    return 'Completed';
  }

  if (value == 'reject' || value == 'rejected') {
    return 'Pending';
  }

  if (value == 'pending') {
    return 'Pending';
  }

  if (value == 'canceled' || value == 'cancelled') {
    return 'Canceled';
  }

  if (rawStatus.trim().isNotEmpty) {
    return rawStatus;
  }

  return 'Pending';
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
