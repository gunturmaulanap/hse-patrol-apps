import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/models/hse_task_model.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../../../areas/presentation/providers/area_provider.dart';

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

final taskDetailMapProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, taskId) async {
  final id = int.tryParse(taskId);
  if (id == null) {
    throw Exception('ID task tidak valid: $taskId');
  }

  final repository = ref.watch(taskRepositoryProvider);
  final task = await repository.getTaskById(id);
  final areaNameById = await _buildAreaNameByIdMap(ref);
  return _toUiTaskMap(task, areaNameById: areaNameById);
});

// Provider untuk mencari task berdasarkan picToken (untuk Deep Link dari WhatsApp)
final taskDetailByPicTokenProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, picToken) async {
  final repository = ref.watch(taskRepositoryProvider);
  final task = await repository.getTaskByPicToken(picToken);
  final areaNameById = await _buildAreaNameByIdMap(ref);
  return _toUiTaskMap(task, areaNameById: areaNameById);
});

final petugasTaskMapsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final tasks = await ref.watch(tasksFutureProvider.future);
  final areaNameById = await _buildAreaNameByIdMap(ref);

  return tasks
      .map((task) => _toUiTaskMap(task, areaNameById: areaNameById))
      .toList();
});

Map<String, dynamic> _toUiTaskMap(
  HseTaskModel task, {
  required Map<int, String> areaNameById,
}) {
  final areaName = _resolveAreaName(task, areaNameById);
  final title = _resolveTitle(task, areaName);

  final followUps = task.followUps
      .map((item) {
        final map = Map<String, dynamic>.from(item);
        final rawStatus = (map['status']?.toString() ?? '').toLowerCase();
        final normalizedAction = rawStatus == 'approved'
            ? 'Approved'
            : rawStatus == 'rejected'
                ? 'Rejected'
                : rawStatus == 'canceled' || rawStatus == 'cancelled'
                    ? 'Canceled'
                    : (map['action']?.toString() ?? 'Follow Up');

        final photosRaw = map['photos'];
        final photos = photosRaw is Map
            ? photosRaw.values
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
            : photosRaw is List
                ? photosRaw
                    .map((e) => e?.toString() ?? '')
                    .where((e) => e.isNotEmpty)
                    .toList()
                : <String>[];

        return <String, dynamic>{
          ...map,
          'type': 'PIC_FOLLOW_UP',
          'action': normalizedAction,
          'notes': map['notes_hse']?.toString().isNotEmpty == true
              ? map['notes_hse']?.toString()
              : map['notes_pic']?.toString() ?? '',
          'photos': photos,
        };
      })
      .toList();

  return <String, dynamic>{
    'id': task.id.toString(),
    'title': title,
    'area': areaName,
    'rootCause': task.rootCause,
    'notes': task.notes,
    'riskLevel': task.riskLevel,
    'status': _normalizeStatus(task.status),
    'date': task.date,
    'userId': task.userId,
    'user_id': task.userId,
    'createdBy': task.userId,
    'created_by': task.userId,
    'staffName': _resolveStaffName(task),
    'photos': task.photos,
    'followUps': followUps,
  };
}

Future<Map<int, String>> _buildAreaNameByIdMap(Ref ref) async {
  try {
    final areas = await ref.read(areaRepositoryProvider).getAreas();
    return {
      for (final area in areas) area.id: area.name,
    };
  } catch (_) {
    return <int, String>{};
  }
}

final supervisorOwnTaskMapsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final allReports = await ref.watch(petugasTaskMapsProvider.future);

  final currentUserId = int.tryParse(currentUser?.id ?? '');
  if (currentUserId == null) return <Map<String, dynamic>>[];

  // Filter hanya task milik supervisor yang sedang login.
  // Guard mockDb dihapus: ID backend bisa berbeda dari ID mock.
  return allReports.where((report) => _ownerId(report) == currentUserId).toList();
});

final supervisorStaffTaskMapsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final allReports = await ref.watch(petugasTaskMapsProvider.future);

  final currentUserId = int.tryParse(currentUser?.id ?? '');
  final nonSelfReports = currentUserId == null
      ? allReports
      : allReports.where((report) => _ownerId(report) != currentUserId).toList();

  // Staff Task: semua task yang bukan milik supervisor login.
  // Penyaringan per petugas dilakukan menggunakan created_by/user_id di UI.
  return nonSelfReports;
});

/// Provider daftar staff (hse_staff/petugas) dari mock master data.
/// Digunakan untuk menampilkan chip staff di tab Staff Task meskipun
/// staff tersebut belum punya task.
/// Ketika backend sudah expose endpoint GET /users?role=hse_staff,
/// ganti dengan FutureProvider yang memanggil API tersebut.
final staffMasterUsersProvider = Provider<List<({int id, String name})>>((ref) {
  final mockDb = ref.read(mockDatabaseProvider);
  final staffList = mockDb.users
      .where((u) => _isHseStaffRole(u.role))
      .map((u) {
        final id = int.tryParse(u.id) ?? 0;
        return (id: id, name: u.username);
      })
      .where((u) => u.id > 0)
      .toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return staffList;
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

String _resolveAreaName(HseTaskModel report, Map<int, String> areaNameById) {
  final areaName = areaNameById[report.areaId]?.trim();
  if (areaName != null && areaName.isNotEmpty) {
    return areaName;
  }
  return 'Area #${report.areaId}';
}

String _resolveStaffName(HseTaskModel report) {
  final fromBackend = (report.userName ?? '').trim();
  if (fromBackend.isNotEmpty) return fromBackend;
  return 'User #${report.userId}';
}

String _resolveTitle(HseTaskModel report, String areaName) {
  final fromBackend = (report.name ?? '').trim();
  if (fromBackend.isNotEmpty) return fromBackend;

  final rootCause = report.rootCause.trim().isEmpty ? '-' : report.rootCause.trim();
  return 'Inspeksi $areaName - Masalah: $rootCause';
}

String _normalizeStatus(String rawStatus) {
  final value = rawStatus.trim().toLowerCase();

  if (value == 'followupdone' || value == 'follow_up_done' || value == 'followed_up') {
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

int _ownerId(Map<String, dynamic> report) {
  return _toInt(report['created_by'] ?? report['createdBy'] ?? report['user_id'] ?? report['userId']);
}

bool _isHseStaffRole(String? role) {
  final normalized = (role ?? '').trim().toLowerCase();
  return normalized == 'hse_staff' ||
      normalized == 'hse staff' ||
      normalized == 'petugas' ||
      normalized == 'petugashse' ||
      normalized == 'petugas_hse';
}
