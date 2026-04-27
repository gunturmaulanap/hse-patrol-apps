import 'task_status.dart';

class TimelineEntry {
  const TimelineEntry({
    required this.id,
    required this.userId,
    required this.actionRaw,
    required this.statusRaw,
    required this.actionStatus,
    required this.date,
    required this.actorName,
    required this.notes,
    required this.notesHse,
    required this.notesPic,
    required this.photos,
    required this.raw,
  });

  factory TimelineEntry.fromMap(Map<String, dynamic> map) {
    final safeMap = Map<String, dynamic>.from(map);
    final actionRaw = _firstNonEmptyString([
      safeMap['action'],
      safeMap['status'],
      safeMap['type'],
    ]);

    final statusRaw = _firstNonEmptyString([
      safeMap['status'],
      safeMap['action'],
    ]);

    return TimelineEntry(
      id: _toIntOrNull(safeMap['id']),
      userId: _toIntOrNull(_firstNonNull([
        safeMap['user_id'],
        safeMap['userId'],
        safeMap['pic_id'],
        safeMap['picId'],
        safeMap['created_by_id'],
        safeMap['createdById'],
      ])),
      actionRaw: actionRaw,
      statusRaw: statusRaw,
      actionStatus: TaskStatus.fromRaw(statusRaw.isNotEmpty ? statusRaw : actionRaw),
      date: _firstNonEmptyString([
        safeMap['date'],
        safeMap['created_at'],
        safeMap['createdAt'],
        safeMap['updated_at'],
        safeMap['updatedAt'],
      ]),
      actorName: _resolveActorName(safeMap),
      notes: _firstNonEmptyString([
        safeMap['notes'],
        safeMap['comment'],
      ]),
      notesHse: _firstNonEmptyString([
        safeMap['notes_hse'],
        safeMap['notesHse'],
      ]),
      notesPic: _firstNonEmptyString([
        safeMap['notes_pic'],
        safeMap['notesPic'],
      ]),
      photos: _extractPhotoUrls(safeMap['photos']),
      raw: safeMap,
    );
  }

  final int? id;
  final int? userId;
  final String actionRaw;
  final String statusRaw;
  final TaskStatus actionStatus;
  final String date;
  final String actorName;
  final String notes;
  final String notesHse;
  final String notesPic;
  final List<String> photos;
  final Map<String, dynamic> raw;

  bool get isReviewAction {
    final normalized = actionRaw.toLowerCase();
    return normalized == 'approved' ||
        normalized == 'rejected' ||
        normalized == 'completed';
  }

  bool get isCancelAction {
    final normalized = actionRaw.toLowerCase();
    return normalized == 'canceled' || normalized == 'cancelled';
  }

  bool get isPicAction => !isReviewAction && !isCancelAction;

  String get effectiveNotes {
    if (isReviewAction && notesHse.isNotEmpty) {
      return notesHse;
    }

    if (isPicAction && notesPic.isNotEmpty) {
      return notesPic;
    }

    if (notes.isNotEmpty) {
      return notes;
    }

    if (notesHse.isNotEmpty) {
      return notesHse;
    }

    return notesPic;
  }
}

String _resolveActorName(Map<String, dynamic> map) {
  final action = _firstNonEmptyString([map['action'], map['status']]).toLowerCase();

  if (action == 'approved' || action == 'rejected' || action == 'completed') {
    return _firstNonEmptyString([
      map['approval_by'],
      map['approvalBy'],
      map['reviewed_by'],
      map['reviewedBy'],
      map['user_name'],
      map['userName'],
      map['created_by'],
      map['createdBy'],
      map['name'],
      map['user'],
      map['staff_name'],
      map['staffName'],
    ]);
  }

  if (action == 'canceled' || action == 'cancelled') {
    return _firstNonEmptyString([
      map['canceled_by_name'],
      map['cancelled_by_name'],
      map['canceledByName'],
      map['cancelledByName'],
      map['canceled_by'],
      map['cancelled_by'],
      map['canceledBy'],
      map['cancelledBy'],
      map['created_by'],
      map['createdBy'],
      map['user_name'],
      map['userName'],
      map['name'],
      map['user'],
      map['staff_name'],
      map['staffName'],
    ]);
  }

  return _firstNonEmptyString([
    map['created_by'],
    map['createdBy'],
    map['pic_name'],
    map['picName'],
    map['user_name'],
    map['userName'],
    map['name'],
    map['user'],
    map['staff_name'],
    map['staffName'],
  ]);
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

int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
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
