import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/enums/user_role.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/auth_role_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../follow_up/presentation/providers/follow_up_provider.dart';
import '../../domain/entities/task_detail.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/mappers/task_detail_mapper.dart';
import '../providers/task_provider.dart';

class TaskDetailControllerArgs {
  const TaskDetailControllerArgs({
    required this.taskId,
    required this.isPicToken,
  });

  final String taskId;
  final bool isPicToken;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TaskDetailControllerArgs &&
            other.taskId == taskId &&
            other.isPicToken == isPicToken;
  }

  @override
  int get hashCode => Object.hash(taskId, isPicToken);
}

enum TaskDetailUiEventType {
  success,
  warning,
  error,
  redirect,
}

class TaskDetailUiEvent {
  const TaskDetailUiEvent({
    required this.type,
    required this.message,
    this.redirectTaskId,
  });

  final TaskDetailUiEventType type;
  final String message;
  final String? redirectTaskId;
}

final taskDetailSubmittingProvider =
    StateProvider.autoDispose.family<bool, TaskDetailControllerArgs>(
  (ref, args) => false,
);

final taskDetailUiEventProvider =
    StateProvider.autoDispose.family<TaskDetailUiEvent?, TaskDetailControllerArgs>(
  (ref, args) => null,
);

final taskDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<TaskDetailController, TaskDetail, TaskDetailControllerArgs>(
  TaskDetailController.new,
);

class TaskDetailController
    extends AutoDisposeFamilyAsyncNotifier<TaskDetail, TaskDetailControllerArgs> {
  late TaskDetailControllerArgs _args;

  @override
  Future<TaskDetail> build(TaskDetailControllerArgs args) async {
    _args = args;

    debugPrint(
      '[TaskDetailController] build taskId=${args.taskId} isPicToken=${args.isPicToken}',
    );

    final task = await _fetchTaskDetail();

    debugPrint(
      '[TaskDetailController] loaded taskId=${task.taskId ?? task.id} '
      'status=${task.status.rawValue} timeline=${task.timeline.length}',
    );

    return task;
  }

  bool canCancelTask(TaskDetail task, UserModel? user) {
    if (user == null) return false;
    if (task.status != TaskStatus.pending) return false;

    if (user.role == UserRole.hseSupervisor) {
      return true;
    }

    return task.ownerId != null && task.ownerId == user.id;
  }

  bool canReviewFollowUp(TaskDetail task, UserModel? user) {
    if (user == null) return false;

    final role = user.role;
    if (role != UserRole.petugasHse && role != UserRole.hseSupervisor) {
      return false;
    }

    if (role == UserRole.petugasHse) {
      if (task.ownerId == null || task.ownerId != user.id) {
        return false;
      }
    }

    if (task.status != TaskStatus.followUpDone) {
      return false;
    }

    final latestFollowUpStatus = task.latestFollowUpStatus;
    if (latestFollowUpStatus == null || latestFollowUpStatus == 'rejected') {
      return false;
    }

    return true;
  }

  bool canStartPicFollowUp(TaskDetail task, UserModel? user) {
    if (user == null || !isPicScopedRole(user.role)) {
      return false;
    }

    final isPendingState =
        task.status == TaskStatus.pending || task.status == TaskStatus.pendingRejected;
    if (!isPendingState) {
      return false;
    }

    if (isPicEngineerRole(user.role) && !task.isToEngineerTask) {
      return false;
    }

    return true;
  }

  bool isWaitingPicResponse(TaskDetail task, UserModel? user) {
    if (user == null) return false;

    final isPetugas = user.role == UserRole.petugasHse;
    final isSupervisor = user.role == UserRole.hseSupervisor;
    final isTaskOwner = task.ownerId != null && task.ownerId == user.id;

    return (isPetugas || isSupervisor) &&
        isTaskOwner &&
        task.latestFollowUpStatus == 'rejected' &&
        task.status == TaskStatus.pendingRejected;
  }

  Future<void> refresh() async {
    debugPrint(
      '[TaskDetailController] refresh triggered taskId=${_args.taskId} isPicToken=${_args.isPicToken}',
    );

    _invalidateAllTaskCaches();
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchTaskDetail);
  }

  Future<void> approve(TaskDetail task) async {
    await _handleReviewAction(task: task, action: 'Approved');
  }

  Future<void> reject(TaskDetail task, {required String reason}) async {
    await _handleReviewAction(
      task: task,
      action: 'Rejected',
      reason: reason,
    );
  }

  Future<void> cancel(TaskDetail task, {required String reason}) async {
    await _handleReviewAction(
      task: task,
      action: 'Canceled',
      reason: reason,
    );
  }

  void clearUiEvent() {
    ref.read(taskDetailUiEventProvider(_args).notifier).state = null;
  }

  Future<void> _handleReviewAction({
    required TaskDetail task,
    required String action,
    String? reason,
  }) async {
    final isSubmitting = ref.read(taskDetailSubmittingProvider(_args));
    if (isSubmitting) {
      debugPrint('[TaskDetailController] action ignored because submission is in progress');
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      _emitUiEvent(
        const TaskDetailUiEvent(
          type: TaskDetailUiEventType.error,
          message: 'Sesi pengguna tidak ditemukan. Silakan login ulang.',
        ),
      );
      return;
    }

    debugPrint(
      '[TaskDetailController] handle action=$action '
      'taskId=${task.taskId ?? task.id} user=${currentUser.name}(${currentUser.role.name})',
    );

    final isApprovalAction = action == 'Approved' || action == 'Rejected';
    final isCancelAction = action == 'Canceled';

    if (isCancelAction && !canCancelTask(task, currentUser)) {
      _emitUiEvent(
        const TaskDetailUiEvent(
          type: TaskDetailUiEventType.warning,
          message: 'Anda tidak memiliki izin membatalkan laporan ini.',
        ),
      );
      return;
    }

    if (isApprovalAction && !canReviewFollowUp(task, currentUser)) {
      _emitUiEvent(
        const TaskDetailUiEvent(
          type: TaskDetailUiEventType.warning,
          message: 'Anda tidak memiliki izin mereview tindak lanjut laporan ini.',
        ),
      );
      return;
    }

    ref.read(taskDetailSubmittingProvider(_args).notifier).state = true;

    try {
      final taskId = task.taskId;
      if (taskId == null) {
        throw Exception('Task ID tidak ditemukan dalam response API');
      }

      if (isApprovalAction) {
        final latestFollowUp = task.latestTimelineEntry;
        final followUpId = latestFollowUp?.id;

        if (followUpId == null) {
          throw Exception('Follow up ID tidak ditemukan dalam response API');
        }

        final followUpRepo = ref.read(followUpRepositoryProvider);
        final approval = action.toLowerCase();

        debugPrint(
          '[TaskDetailController] approveFollowUp taskId=$taskId followUpId=$followUpId approval=$approval',
        );

        await followUpRepo.approveFollowUp(
          taskId,
          followUpId,
          approval,
          action == 'Rejected' ? reason : null,
        );
      } else if (isCancelAction) {
        final taskRepo = ref.read(taskRepositoryProvider);
        final canceledByName = currentUser.name;

        debugPrint(
          '[TaskDetailController] cancelTask taskId=$taskId canceledBy=$canceledByName',
        );

        final canceledTask = await taskRepo.cancelTask(
          taskId,
          canceledByName,
          reason ?? '',
        );

        debugPrint(
          '[TaskDetailController] cancelTask success cancelled_by=${canceledTask.cancelledBy} '
          'cancelled_at=${canceledTask.cancelledAt}',
        );
        final optimisticRaw = Map<String, dynamic>.from(task.raw)
          ..['status'] = 'cancelled'
          ..['cancel_notes'] = reason ?? ''
          ..['cancelNotes'] = reason ?? ''
          ..['cancelled_by'] = canceledByName
          ..['cancelledBy'] = canceledByName
          ..['cancelled_at'] = DateTime.now().toIso8601String()
          ..['cancelledAt'] = DateTime.now().toIso8601String();

        final optimisticTask = TaskDetailMapper.fromMap(optimisticRaw);
        state = AsyncData(optimisticTask);

        _emitUiEvent(
          const TaskDetailUiEvent(
            type: TaskDetailUiEventType.success,
            message: 'Laporan berhasil dibatalkan!',
          ),
        );

        Future.microtask(() async {
          try {
            _invalidateAllTaskCaches();
            await _refreshRelatedTaskCaches();
            final refreshedTask = await _fetchTaskDetail();
            state = AsyncData(refreshedTask);
            debugPrint(
              '[TaskDetailController] background refresh after cancel success taskId=${refreshedTask.taskId ?? refreshedTask.id} status=${refreshedTask.status.rawValue}',
            );
          } catch (error, stackTrace) {
            debugPrint(
              '[TaskDetailController] background refresh after cancel skipped error=$error stackTrace=$stackTrace',
            );
          }
        });
        return;
      }

      _invalidateAllTaskCaches();
      final refreshedTask = await _refreshAfterMutation();
      state = AsyncData(refreshedTask);

      final event = switch (action) {
        'Approved' => const TaskDetailUiEvent(
            type: TaskDetailUiEventType.success,
            message: 'Tugas Selesai!',
          ),
        'Rejected' => const TaskDetailUiEvent(
            type: TaskDetailUiEventType.error,
            message: 'Perbaikan ditolak!',
          ),
        _ => TaskDetailUiEvent(
            type: TaskDetailUiEventType.redirect,
            message: 'Laporan berhasil dibatalkan!',
            redirectTaskId:
                (refreshedTask.taskId?.toString() ?? _args.taskId).trim(),
          ),
      };

      _emitUiEvent(event);
    } catch (error, stackTrace) {
      debugPrint(
        '[TaskDetailController] action failed action=$action error=$error stackTrace=$stackTrace',
      );

      _emitUiEvent(
        TaskDetailUiEvent(
          type: TaskDetailUiEventType.error,
          message: 'Gagal memproses aksi: ${error.toString()}',
        ),
      );
    } finally {
      ref.read(taskDetailSubmittingProvider(_args).notifier).state = false;
    }
  }

  Future<TaskDetail> _fetchTaskDetail() async {
    final rawMap = _args.isPicToken
        ? await ref.refresh(taskDetailByPicTokenProvider(_args.taskId).future)
        : await ref.refresh(taskDetailMapProvider(_args.taskId).future);

    debugPrint(
      '[TaskDetailController] mapping raw task detail taskId=${_args.taskId} isPicToken=${_args.isPicToken}',
    );

    return TaskDetailMapper.fromMap(rawMap);
  }

  Future<TaskDetail> _refreshAfterMutation() async {
    _invalidateAllTaskCaches();

    await _refreshRelatedTaskCaches();

    return _fetchTaskDetail();
  }

  Future<void> _refreshRelatedTaskCaches() async {
    await Future.wait([
      ref.refresh(tasksFutureProvider.future),
      ref.refresh(petugasTaskMapsProvider.future),
      ref.refresh(supervisorOwnTaskMapsProvider.future),
      ref.refresh(supervisorStaffTaskMapsProvider.future),
      ref.refresh(supervisorAllVisibleTaskMapsProvider.future),
    ]);
  }

  void _invalidateDetailProvider() {
    if (_args.isPicToken) {
      ref.invalidate(taskDetailByPicTokenProvider(_args.taskId));
    } else {
      ref.invalidate(taskDetailMapProvider(_args.taskId));
    }
  }

  void _invalidateAllTaskCaches() {
    _invalidateDetailProvider();
    ref.invalidate(tasksFutureProvider);
    ref.invalidate(petugasTaskMapsProvider);
    ref.invalidate(supervisorOwnTaskMapsProvider);
    ref.invalidate(supervisorStaffTaskMapsProvider);
    ref.invalidate(supervisorAllVisibleTaskMapsProvider);
  }

  void _emitUiEvent(TaskDetailUiEvent event) {
    ref.read(taskDetailUiEventProvider(_args).notifier).state = event;
  }
}
