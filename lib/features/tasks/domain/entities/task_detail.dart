import 'package:flutter/foundation.dart';

import 'risk_level.dart';
import 'task_status.dart';
import 'timeline_entry.dart';

class TaskDetail {
  const TaskDetail({
    required this.id,
    required this.taskId,
    required this.picToken,
    required this.code,
    required this.title,
    required this.area,
    required this.areaId,
    required this.rootCause,
    required this.notes,
    required this.riskLevel,
    required this.riskLevelRaw,
    required this.status,
    required this.statusRaw,
    required this.ownerId,
    required this.reporterName,
    required this.toDepartmentValue,
    required this.toEngineer,
    required this.date,
    required this.photos,
    required this.timeline,
    required this.cancelledBy,
    required this.cancelledAt,
    required this.raw,
  });

  factory TaskDetail.fromMap(Map<String, dynamic> map) {
    final safeMap = Map<String, dynamic>.from(map);

    debugPrint(
      '[TaskDetail] fromMap taskId=${safeMap['taskId'] ?? safeMap['id']} '
      'status=${safeMap['status']} followUps=${(safeMap['followUps'] as List?)?.length ?? 0}',
    );

    final timeline = _parseTimeline(safeMap);
    final baseStatus = TaskStatus.fromRaw(safeMap['status']);
    final actualStatus = _resolveActualStatus(baseStatus, timeline);
    final title = _firstNonEmptyString([
      safeMap['title'],
      safeMap['name'],
      safeMap['code'],
    ], fallback: 'Inspeksi Rutin');

    return TaskDetail(
      id: _firstNonEmptyString([
        safeMap['id'],
        safeMap['taskId'],
      ]),
      taskId: _toIntOrNull(_firstNonNull([
        safeMap['taskId'],
        safeMap['id'],
      ])),
      picToken: _nullableString(safeMap['picToken'] ?? safeMap['pic_token']),
      code: _firstNonEmptyString([
        safeMap['code'],
        safeMap['report_code'],
        safeMap['reportCode'],
      ]),
      title: title,
      area: _firstNonEmptyString([
        safeMap['area'],
        safeMap['area_name'],
        safeMap['areaName'],
      ], fallback: '-'),
      areaId: _toIntOrNull(_firstNonNull([
        safeMap['areaId'],
        safeMap['area_id'],
      ])),
      rootCause: _firstNonEmptyString([
        safeMap['rootCause'],
        safeMap['root_cause'],
      ], fallback: '-'),
      notes: _firstNonEmptyString([
        safeMap['notes'],
        safeMap['description'],
      ], fallback: '-'),
      riskLevel: RiskLevel.fromRaw(safeMap['riskLevel'] ?? safeMap['risk_level']),
      riskLevelRaw: _firstNonEmptyString([
        safeMap['riskLevel'],
        safeMap['risk_level'],
      ]),
      status: actualStatus,
      statusRaw: _firstNonEmptyString([
        safeMap['status'],
      ], fallback: actualStatus.rawValue),
      ownerId: _toIntOrNull(_firstNonNull([
        safeMap['user_id'],
        safeMap['userId'],
        safeMap['authorId'],
        safeMap['created_by_id'],
        safeMap['createdById'],
        safeMap['created_by'],
        safeMap['createdBy'],
      ])),
      reporterName: _resolveReporterName(safeMap),
      toDepartmentValue: _resolveToDepartmentValue(safeMap),
      toEngineer: _toBool(safeMap['toEngineer'] ?? safeMap['to_engineer']),
      date: _nullableString(_firstNonNull([
        safeMap['date'],
        safeMap['created_at'],
        safeMap['createdAt'],
      ])),
      photos: _extractPhotoUrls(safeMap['photos']),
      timeline: timeline,
      cancelledBy: _nullableString(_firstNonNull([
        safeMap['cancelled_by'],
        safeMap['cancelledBy'],
        safeMap['canceled_by'],
        safeMap['canceledBy'],
      ])),
      cancelledAt: _nullableString(_firstNonNull([
        safeMap['cancelled_at'],
        safeMap['cancelledAt'],
        safeMap['canceled_at'],
        safeMap['canceledAt'],
      ])),
      raw: safeMap,
    );
  }

  final String id;
  final int? taskId;
  final String? picToken;
  final String code;
  final String title;
  final String area;
  final int? areaId;
  final String rootCause;
  final String notes;
  final RiskLevel riskLevel;
  final String riskLevelRaw;
  final TaskStatus status;
  final String statusRaw;
  final int? ownerId;
  final String reporterName;
  final int? toDepartmentValue;
  final bool toEngineer;
  final String? date;
  final List<String> photos;
  final List<TimelineEntry> timeline;
  final String? cancelledBy;
  final String? cancelledAt;
  final Map<String, dynamic> raw;

  TimelineEntry? get latestTimelineEntry {
    if (timeline.isEmpty) return null;
    return timeline.last;
  }

  String get latestFollowUpAction => latestTimelineEntry?.actionRaw.toLowerCase() ?? '';

  String? get latestFollowUpStatus {
    final value = latestTimelineEntry?.statusRaw.trim();
    return value == null || value.isEmpty ? null : value.toLowerCase();
  }

  bool get hasOtherDepartmentSupport {
    return toDepartmentValue == 1 || toDepartmentValue == 2;
  }

  bool get isToEngineerTask => toDepartmentValue == 2;

  String get supportDepartmentTitle {
    switch (toDepartmentValue) {
      case 1:
        return 'Butuh Support HRGA';
      case 2:
        return 'Butuh Support Engineer';
      default:
        return 'Butuh Support Department';
    }
  }

  String get supportDepartmentDescription {
    switch (toDepartmentValue) {
      case 1:
        return 'Task ini memerlukan support dari tim HRGA untuk proses tindak lanjut.';
      case 2:
        return 'Task ini memerlukan support dari tim engineer untuk proses tindak lanjut.';
      default:
        return 'Task ini memerlukan support dari department lain untuk proses tindak lanjut.';
    }
  }
}

List<TimelineEntry> _parseTimeline(Map<String, dynamic> map) {
  final rawFollowUps = _firstNonNull([
    map['followUps'],
    map['follow_ups'],
  ]);

  final timeline = <TimelineEntry>[];

  if (rawFollowUps is List) {
    for (final item in rawFollowUps) {
      if (item is Map) {
        timeline.add(TimelineEntry.fromMap(Map<String, dynamic>.from(item)));
      }
    }
  }

  final currentStatus = TaskStatus.fromRaw(map['status']);
  final hasCanceledLog = timeline.any((entry) => entry.isCancelAction);
  final isCanceledTask = currentStatus == TaskStatus.canceled;

  if (isCanceledTask && !hasCanceledLog) {
    final syntheticCancelLog = <String, dynamic>{
      'action': 'canceled',
      'status': 'canceled',
      'date': _firstNonNull([
        map['canceled_at'],
        map['cancelled_at'],
        map['canceledAt'],
        map['cancelledAt'],
        map['updated_at'],
        map['updatedAt'],
        map['date'],
      ]),
      'user_id': _firstNonNull([
        map['canceled_by_id'],
        map['cancelled_by_id'],
        map['canceledById'],
        map['cancelledById'],
      ]),
      'created_by': _firstNonNull([
        map['canceled_by_name'],
        map['cancelled_by_name'],
        map['canceledByName'],
        map['cancelledByName'],
        map['canceled_by'],
        map['cancelled_by'],
        map['canceledBy'],
        map['cancelledBy'],
      ]),
      'notes': _firstNonNull([
        map['cancel_notes'],
        map['cancelNotes'],
        map['cancel_reason'],
        map['cancelReason'],
        map['notes_hse'],
        map['notesHse'],
      ]),
    };

    debugPrint(
      '[TaskDetail] synthetic cancel timeline added '
      'taskId=${map['taskId'] ?? map['id']} actor=${syntheticCancelLog['created_by']}',
    );

    timeline.add(TimelineEntry.fromMap(syntheticCancelLog));
  }

  return timeline;
}

TaskStatus _resolveActualStatus(
  TaskStatus baseStatus,
  List<TimelineEntry> timeline,
) {
  if (timeline.isEmpty) {
    return baseStatus;
  }

  final latest = timeline.last;
  if (latest.actionRaw.toLowerCase() == 'rejected' ||
      latest.statusRaw.toLowerCase() == 'rejected') {
    return TaskStatus.pendingRejected;
  }

  return baseStatus;
}

String _resolveReporterName(Map<String, dynamic> map) {
  return _firstNonEmptyString([
    map['staffName'],
    map['staff_name'],
    map['userName'],
    map['user_name'],
    map['created_by_name'],
    map['createdByName'],
    map['created_by'],
    map['createdBy'],
    map['user'],
  ], fallback: 'HSE Officer');
}

int? _resolveToDepartmentValue(Map<String, dynamic> map) {
  // 1. Coba ambil dari field to_department / toDepartment
  final toDepartment = _firstNonNull([
    map['to_department'],
    map['toDepartment'],
  ]);

  if (toDepartment != null) {
    if (toDepartment is int) return toDepartment;
    if (toDepartment is num) return toDepartment.toInt();
    final parsed = int.tryParse(toDepartment.toString());
    if (parsed != null) return parsed;
  }

  return null;
}

dynamic _firstNonNull(List<dynamic> values) {
  for (final value in values) {
    if (value != null) return value;
  }
  return null;
}

String _firstNonEmptyString(List<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }
  }

  return fallback;
}

String? _nullableString(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _toBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value == 1;

  final normalized = value.toString().trim().toLowerCase();
  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes' ||
      normalized == 'y';
}

List<String> _extractPhotoUrls(dynamic photosRaw) {
  if (photosRaw is Map) {
    return photosRaw.values
        .map((value) => value?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }

  if (photosRaw is List) {
    return photosRaw
        .map((value) => value?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }

  return <String>[];
}
