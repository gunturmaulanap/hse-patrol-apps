enum TaskStatus {
  pending,
  followUpDone,
  pendingRejected,
  completed,
  canceled,
  unknown;

  factory TaskStatus.fromRaw(dynamic raw) {
    final normalized = raw?.toString().trim().toLowerCase() ?? '';

    switch (normalized) {
      case 'pending':
        return TaskStatus.pending;
      case 'follow up done':
      case 'followed_up':
      case 'follow_up_done':
        return TaskStatus.followUpDone;
      case 'pending rejected':
        return TaskStatus.pendingRejected;
      case 'completed':
      case 'approved':
        return TaskStatus.completed;
      case 'canceled':
      case 'cancelled':
        return TaskStatus.canceled;
      default:
        return TaskStatus.unknown;
    }
  }
}

extension TaskStatusX on TaskStatus {
  String get rawValue {
    return switch (this) {
      TaskStatus.pending => 'pending',
      TaskStatus.followUpDone => 'follow up done',
      TaskStatus.pendingRejected => 'pending rejected',
      TaskStatus.completed => 'completed',
      TaskStatus.canceled => 'canceled',
      TaskStatus.unknown => 'unknown',
    };
  }

  bool get isCanceled => this == TaskStatus.canceled;
}
