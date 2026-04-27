import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../data/datasource/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/models/hse_task_model.dart';
import '../../data/models/hse_staff_model.dart';
import '../../../auth/domain/auth_role_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../areas/presentation/providers/area_provider.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final remote = ref.read(taskRemoteDataSourceProvider);
  return TaskRepositoryImpl(remote);
});

final tasksFutureProvider = FutureProvider<List<HseTaskModel>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    debugPrint('[TaskProvider][tasksFutureProvider] currentUser null -> empty');
    return <HseTaskModel>[];
  }

  debugPrint('[TaskProvider][tasksFutureProvider] fetching /hse-reports ...');
  final repository = ref.watch(taskRepositoryProvider);
  final tasks = await repository.getTasks();
  debugPrint(
    '[TaskProvider][tasksFutureProvider] fetched total=${tasks.length}',
  );
  return tasks;
});

final taskDetailMapProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, taskId) async {
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
final taskDetailByPicTokenProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, picToken) async {
  final repository = ref.watch(taskRepositoryProvider);
  final task = await repository.getTaskByPicToken(picToken);
  final areaNameById = await _buildAreaNameByIdMap(ref);
  return _toUiTaskMap(task, areaNameById: areaNameById);
});

/// Provider validasi picToken via endpoint existing tanpa ubah backend contract.
final picTokenValidationProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, picToken) async {
  final remote = ref.watch(taskRemoteDataSourceProvider);
  return remote.validatePicToken(picToken);
});

final petugasTaskMapsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final tasks = await ref.watch(tasksFutureProvider.future);
  if (tasks.isEmpty) {
    debugPrint('[TaskProvider][PetugasMaps] empty source tasks');
    return <Map<String, dynamic>>[];
  }

  final areaNameById = await _buildAreaNameByIdMap(ref);

  final mapped = tasks
      .map((task) => _toUiTaskMap(task, areaNameById: areaNameById))
      .toList();

  debugPrint(
    '[TaskProvider][PetugasMaps] total=${mapped.length} dateBuckets=${_buildDateBucketsFromMaps(mapped)}',
  );

  return mapped;
});

final picAccessibleTaskMapsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final areas = await ref.watch(areaByUserProvider.future);
  final allReports = await ref.watch(petugasTaskMapsProvider.future);

  if (currentUser == null || !isPicScopedRole(currentUser.role)) {
    debugPrint('[TaskProvider][PicAccessible] user not PIC scoped -> empty');
    return <Map<String, dynamic>>[];
  }

  final allowedAreaIds = areas.map((area) => area.id.toString()).toSet();
  final allowedAreaNames = areas
      .expand((area) => _buildAreaAliases(
            name: area.name,
            description: area.description,
            buildingType: area.buildingType,
          ))
      .toSet();

  final filtered = allReports.where((report) {
    final reportAreaId = report['areaId']?.toString().trim();
    final reportAreaNames = _buildReportAreaAliases(report);

    final hasAreaAccess =
        (reportAreaId != null && allowedAreaIds.contains(reportAreaId)) ||
            reportAreaNames.any(allowedAreaNames.contains);

    final isSupportRole =
        isPicEngineerRole(currentUser.role) || isPicHrgaRole(currentUser.role);

    if (!hasAreaAccess && !isSupportRole) {
      return false;
    }

    final toDepartment =
        _toDepartment(report['to_department'] ?? report['toDepartment']);

    if (isPicEngineerRole(currentUser.role)) {
      return toDepartment == 2 || toDepartment == 3;
    }

    if (isPicHrgaRole(currentUser.role)) {
      return toDepartment == 1 || toDepartment == 3;
    }

    return true;
  }).toList();

  debugPrint(
    '[TaskProvider][PicAccessible] role=${currentUser.role.name} areas=${areas.length} all=${allReports.length} filtered=${filtered.length}',
  );

    return filtered;
});

final currentUserTaskMapsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final currentUser = ref.watch(currentUserProvider);
    final allReports = await ref.watch(petugasTaskMapsProvider.future);

    final currentUserId = currentUser?.id;
    if (currentUserId == null) {
      debugPrint('[TaskProvider][CurrentUserTasks] currentUserId is null -> empty');
      return <Map<String, dynamic>>[];
    }

    final ownReports = allReports
        .where((report) => _ownerId(report) == currentUserId)
        .toList();

    debugPrint(
      '[TaskProvider][CurrentUserTasks] userId=$currentUserId all=${allReports.length} own=${ownReports.length}',
    );

    return ownReports;
  },
);

/// Task milik petugas yang sedang login saja.
final petugasOwnTaskMapsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final ownReports = await ref.watch(currentUserTaskMapsProvider.future);

  debugPrint(
    '[TaskProvider][PetugasOwn] dateBuckets=${_buildDateBucketsFromMaps(ownReports)}',
  );

  return ownReports;
});

Map<String, dynamic> _toUiTaskMap(
  HseTaskModel task, {
  required Map<int, String> areaNameById,
}) {
  final areaName = _resolveAreaName(task, areaNameById);
  final title = _resolveTitle(task, areaName);

  final followUps = task.followUps.map((item) {
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
      // Pisahkan notes_hse dan notes_pic agar bisa ditampilkan terpisah di UI
      'notes_hse': map['notes_hse']?.toString() ?? '',
      'notes_pic': map['notes_pic']?.toString() ?? '',
      // Field 'notes' untuk backward compatibility.
      // Prioritaskan notes bawaan payload agar cancel_notes/synthetic cancel log
      // tidak tertimpa kosong oleh notes_hse/notes_pic.
      'notes': (map['notes']?.toString().trim().isNotEmpty == true)
          ? map['notes']?.toString()
          : map['notes_hse']?.toString().isNotEmpty == true
              ? map['notes_hse']?.toString()
              : map['notes_pic']?.toString() ?? '',
      'photos': photos,
    };
  }).toList();

  return <String, dynamic>{
    'id': task.id.toString(),
    'taskId': task.id,
    'picToken': task.picToken,
    'title': title,
    'area': areaName,
    'areaName': areaName,
    'area_name': areaName,
    'areaId': task.areaId.toString(),
    'rootCause': task.rootCause,
    'notes': task.notes,
    'riskLevel': task.riskLevel,
    'status': _normalizeStatus(task.status),
    'toDepartment': _toDepartment(task.toDepartment),
    'to_department': _toDepartment(task.toDepartment),
    'date': task.date,
    'authorId': task.userId,
    'userId': task.userId,
    'user_id': task.userId,
    'createdBy': task.userId,
    'created_by': task.userId,
    'createdByName': _resolveStaffName(task),
    'created_by_name': _resolveStaffName(task),
    'staffName': _resolveStaffName(task),
    'photos': task.photos,
    'followUps': followUps,
    'cancelled_by': task.cancelledBy,
    'cancelledBy': task.cancelledBy,
    'cancelled_at': task.cancelledAt,
    'cancelledAt': task.cancelledAt,
  };
}

Future<Map<int, String>> _buildAreaNameByIdMap(Ref ref) async {
  try {
    final areas = await ref.read(areaRepositoryProvider).getAreas();
    return {
      for (final area in areas)
        area.id: area.description.trim().isNotEmpty
            ? area.description.trim()
            : area.name,
    };
  } catch (_) {
    return <int, String>{};
  }
}

final supervisorOwnTaskMapsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final allReports = await ref.watch(petugasTaskMapsProvider.future);
  final ownReports = await ref.watch(currentUserTaskMapsProvider.future);

  final currentUserId = currentUser?.id;

  debugPrint(
    '[TaskProvider][SupervisorOwn] userId=$currentUserId all=${allReports.length} own=${ownReports.length}',
  );
  debugPrint(
    '[TaskProvider][SupervisorOwn] dateBuckets=${_buildDateBucketsFromMaps(ownReports)}',
  );

  return ownReports;
});

final supervisorStaffTaskMapsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final allReports = await ref.watch(petugasTaskMapsProvider.future);

  final currentUserId = currentUser?.id;
  final nonSelfReports = currentUserId == null
      ? allReports
      : allReports
          .where((report) => _ownerId(report) != currentUserId)
          .toList();

  final ownerIds = nonSelfReports
      .map((e) => _ownerId(e))
      .toSet()
      .toList()
    ..sort();

  debugPrint(
    '[TaskProvider][SupervisorStaff] userId=$currentUserId all=${allReports.length} staff=${nonSelfReports.length} ownerIds=$ownerIds',
  );
  debugPrint(
    '[TaskProvider][SupervisorStaff] dateBuckets=${_buildDateBucketsFromMaps(nonSelfReports)}',
  );

  // Staff Task: semua task yang bukan milik supervisor login.
  // Penyaringan per petugas dilakukan menggunakan created_by/user_id di UI.
  return nonSelfReports;
});

final supervisorAllVisibleTaskMapsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final own = await ref.watch(supervisorOwnTaskMapsProvider.future);
  final staff = await ref.watch(supervisorStaffTaskMapsProvider.future);
  final visible = <Map<String, dynamic>>[...own, ...staff];

  debugPrint(
    '[TaskProvider][SupervisorVisible] total=${visible.length} dateBuckets=${_buildDateBucketsFromMaps(visible)}',
  );

  // Debug: print sample tasks with dates
  if (visible.isNotEmpty) {
    debugPrint('[TaskProvider][SupervisorVisible] Sample tasks:');
    for (var i = 0; i < (visible.length > 10 ? 10 : visible.length); i++) {
      final task = visible[i];
      debugPrint('  - Task ${task['id']}: date="${task['date']}" title="${task['title']}" status="${task['status']}"');
    }
  }

  return visible;
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
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, staffName) async {
  final staffTasks = await ref.watch(supervisorStaffTaskMapsProvider.future);

  return staffTasks
      .where(
          (task) => (task['staffName']?.toString().trim() ?? '') == staffName)
      .toList();
});

// Provider untuk mengambil list staff dari API /hse/staffs
final staffListProvider = FutureProvider<List<HseStaffModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getStaffs();
});

// Provider untuk mengambil list PIC users dari API /hse/pic-users
final picUsersProvider = FutureProvider<List<HseStaffModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getPicUsers();
});

// Provider untuk membuat mapping userId -> nama user dari PIC users
final picUserMapProvider = Provider<Map<int, String>>((ref) {
  final picUsersAsync = ref.watch(picUsersProvider);

  return picUsersAsync.when(
    data: (users) {
      return {
        for (final user in users) user.id: user.name,
      };
    },
    loading: () => {},
    error: (_, __) => {},
  );
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

  final rootCause =
      report.rootCause.trim().isEmpty ? '-' : report.rootCause.trim();
  return 'Inspeksi $areaName - Masalah: $rootCause';
}

String _normalizeStatus(String rawStatus) {
  final value = rawStatus.trim().toLowerCase();

  if (value == 'followupdone' ||
      value == 'follow_up_done' ||
      value == 'followed_up') {
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

int _toDepartment(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Set<String> _buildAreaAliases({
  required String name,
  required String description,
  required String buildingType,
}) {
  final aliases = <String>{};

  void addAlias(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.isNotEmpty) {
      aliases.add(normalized);
    }
  }

  addAlias(name);
  addAlias(description);

  if (name.trim().isNotEmpty && buildingType.trim().isNotEmpty) {
    addAlias('${name.trim()} ${buildingType.trim()}');
  }

  return aliases;
}

Set<String> _buildReportAreaAliases(Map<String, dynamic> report) {
  final aliases = <String>{};

  void addAlias(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    if (normalized.isNotEmpty) {
      aliases.add(normalized);
    }
  }

  addAlias(report['area']);
  addAlias(report['area_name']);
  addAlias(report['areaName']);
  addAlias(report['area_description']);
  addAlias(report['areaDescription']);

  return aliases;
}

int _ownerId(Map<String, dynamic> report) {
  return _toInt(report['created_by'] ??
      report['createdBy'] ??
      report['user_id'] ??
      report['userId']);
}

Map<String, int> _buildDateBucketsFromMaps(List<Map<String, dynamic>> reports,
    {int maxBuckets = 12}) {
  final buckets = <String, int>{};
  for (final report in reports) {
    final dateKey = _extractDateKey(report['date']?.toString());
    buckets[dateKey] = (buckets[dateKey] ?? 0) + 1;
  }

  final sortedKeys = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
  final limited = <String, int>{};
  for (final key in sortedKeys.take(maxBuckets)) {
    limited[key] = buckets[key] ?? 0;
  }
  return limited;
}

String _extractDateKey(String? rawDate) {
  if (rawDate == null || rawDate.trim().isEmpty) return 'unknown';
  final parsed = DateTime.tryParse(rawDate);
  if (parsed == null) return 'invalid';
  final y = parsed.year.toString().padLeft(4, '0');
  final m = parsed.month.toString().padLeft(2, '0');
  final d = parsed.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
