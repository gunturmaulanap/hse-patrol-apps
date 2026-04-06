import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/enums/user_role.dart';
import '../providers/task_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// DeepLinkHandlerScreen
///
/// Screen ini berfungsi sebagai "pintu gerbang" untuk deep link dari WhatsApp.
/// Melakukan validasi otentikasi dan hak akses sebelum mengarahkan user ke
/// halaman yang sesuai.
class DeepLinkHandlerScreen extends ConsumerStatefulWidget {
  final String token;

  const DeepLinkHandlerScreen({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<DeepLinkHandlerScreen> createState() => _DeepLinkHandlerScreenState();
}

class _DeepLinkHandlerScreenState extends ConsumerState<DeepLinkHandlerScreen> {
  bool _isProcessing = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Jalankan validasi setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processDeepLink();
    });
  }

  Future<void> _processDeepLink() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      debugPrint('[DeepLinkHandler] incoming token: ${widget.token}');

      // 1. Cek Otentikasi
      final sessionManager = ref.read(sessionManagerProvider);
      final authRepository = ref.read(authRepositoryProvider);

      UserModel? currentUser = ref.read(currentUserProvider);
      final sessionToken = await sessionManager.getToken();
      final hasSessionToken = sessionToken != null && sessionToken.isNotEmpty;

      debugPrint(
        '[DeepLinkHandler] auth snapshot => currentUser: ${currentUser?.email}, hasSessionToken: $hasSessionToken',
      );

      // Jika session token ada tapi currentUser belum siap (cold start/warm resume),
      // hydrate user dari endpoint /me.
      if (currentUser == null && hasSessionToken) {
        try {
          final me = await authRepository.getMe();
          currentUser = me;
          ref.read(authNotifierProvider.notifier).setHydratedUser(me);
          debugPrint('[DeepLinkHandler] hydrated currentUser from /me => role: ${currentUser.role}');
        } catch (e) {
          debugPrint('[DeepLinkHandler] failed hydrating /me: $e');
        }
      }

      if (currentUser == null) {
        // Belum login - arahkan ke login
        final intendedPath = '/share/report/${widget.token}';
        final encodedRedirect = Uri.encodeComponent(intendedPath);
        final loginPath = '/login?redirect=$encodedRedirect';

        debugPrint('[DeepLinkHandler] user belum login, redirect ke: $loginPath');
        if (mounted) {
          _goOnce(loginPath);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              AppToast.info(
                context,
                message: 'Silakan login terlebih dahulu untuk membuka laporan.',
              );
            }
          });
        }
        return;
      }

      // 2. Validasi token via endpoint existing
      final validation = await ref.read(picTokenValidationProvider(widget.token).future);
      final tokenValid = _asBool(validation['tokenValid']) ?? false;
      final authorized = _asBool(validation['authorized']) ?? false;

      debugPrint(
        '[DeepLinkHandler] validation result => tokenValid: $tokenValid, authorized: $authorized, metadata: $validation',
      );

      if (!tokenValid) {
        _navigateBasedOnRoleWithCustomMessage(
          currentUser.role,
          'Token laporan tidak valid atau sudah kedaluwarsa.',
        );
        return;
      }

      if (!authorized) {
        _navigateBasedOnRoleWithCustomMessage(
          currentUser.role,
          'Anda tidak memiliki akses untuk membuka laporan ini.',
        );
        return;
      }

      // 3A. Strategi A: resolve langsung by token (jika endpoint existing mengembalikan task)
      Map<String, dynamic>? resolvedTask;
      try {
        debugPrint('[DeepLinkHandler] attempt strategy A -> resolve direct task by token');
        final taskMap = await ref.read(taskDetailByPicTokenProvider(widget.token).future);
        final roleAllowed = _isRoleAllowedForTask(currentUser, taskMap);
        final taskId = taskMap['id']?.toString() ?? '';

        debugPrint(
          '[DeepLinkHandler] strategy A result => taskId: $taskId, roleAllowed: $roleAllowed',
        );

        if (taskId.isNotEmpty && roleAllowed) {
          _navigateToTaskDetail(taskId, 'Melanjutkan tindakan follow-up task.');
          return;
        }

        if (!roleAllowed) {
          _navigateBasedOnRoleWithCustomMessage(
            currentUser.role,
            'Laporan valid, namun akses role Anda tidak sesuai untuk task ini.',
          );
          return;
        }

        resolvedTask = taskMap;
      } catch (e) {
        debugPrint('[DeepLinkHandler] strategy A failed: $e');
      }

      // 3B/3C. Fallback client-side resolve tanpa ubah backend
      debugPrint('[DeepLinkHandler] attempt strategy B/C -> resolve from existing app data');
      final fallbackTaskId = await _resolveTaskIdFromExistingData(
        currentUser,
        validation,
        resolvedTask,
      );

      if (fallbackTaskId != null && fallbackTaskId.isNotEmpty) {
        _navigateToTaskDetail(
          fallbackTaskId,
          'Token valid, task ditemukan dari data aplikasi.',
        );
        return;
      }

      _navigateToRelevantList(
        currentUser.role,
        'Token valid, namun task spesifik tidak dapat ditentukan. Silakan pilih dari daftar task.',
      );

    } catch (e, st) {
      debugPrint('[DeepLinkHandler] Error: $e');
      debugPrint('[DeepLinkHandler] StackTrace: $st');

      // Cek apakah ini error 404 (task tidak ditemukan)
      final errorMessage = e.toString().toLowerCase();
      final isNotFoundError = errorMessage.contains('404') ||
                              errorMessage.contains('not found') ||
                              errorMessage.contains('task tidak ditemukan');

      // Navigate ke home berdasarkan role
      final role = ref.read(currentUserProvider)?.role ?? UserRole.petugasHse;

      if (mounted) {
        _navigateBasedOnRoleWithError(role, isNotFoundError);
      }
    } finally {
      _isProcessing = false;
    }
  }

  bool _isRoleAllowedForTask(UserModel currentUser, Map<String, dynamic> taskMap) {
    final role = currentUser.role;
    final authorId = _toInt(
      taskMap['authorId'] ??
          taskMap['createdBy'] ??
          taskMap['created_by'] ??
          taskMap['userId'] ??
          taskMap['user_id'],
    );
    final areaId = taskMap['areaId']?.toString();
    final areaName = taskMap['area']?.toString();

    debugPrint(
      '[DeepLinkHandler] role validation => role: $role, authorId: $authorId, areaId: $areaId, areaName: $areaName',
    );

    if (role == UserRole.hseSupervisor) {
      return true;
    }

    if (role == UserRole.petugasHse) {
      final currentUserId = _toInt(currentUser.id);
      return authorId != null && currentUserId != null && authorId == currentUserId;
    }

    if (role == UserRole.pic) {
      final hasAreaById = areaId != null && currentUser.areaAccess.contains(areaId);
      final hasAreaByName = areaName != null && currentUser.areaAccess.contains(areaName);
      return hasAreaById || hasAreaByName;
    }

    return false;
  }

  Future<String?> _resolveTaskIdFromExistingData(
    UserModel currentUser,
    Map<String, dynamic> validation,
    Map<String, dynamic>? resolvedTask,
  ) async {
    final explicitTaskId = _pickTaskId(validation) ?? _pickTaskId(resolvedTask);

    final allTaskMaps = await ref.read(petugasTaskMapsProvider.future);
    debugPrint('[DeepLinkHandler] existing app tasks count: ${allTaskMaps.length}');

    final areaIdFromValidation = validation['areaId']?.toString();
    final role = currentUser.role;

    var candidates = allTaskMaps.where((task) {
      final taskAreaId = task['areaId']?.toString();
      final taskAuthor = _toInt(task['authorId'] ?? task['createdBy'] ?? task['created_by'] ?? task['userId'] ?? task['user_id']);

      if (areaIdFromValidation != null && areaIdFromValidation.isNotEmpty && taskAreaId != areaIdFromValidation) {
        return false;
      }

      if (role == UserRole.petugasHse) {
        return taskAuthor == _toInt(currentUser.id);
      }

      if (role == UserRole.pic) {
        final areaName = task['area']?.toString();
        final areaAllowedById = taskAreaId != null && currentUser.areaAccess.contains(taskAreaId);
        final areaAllowedByName = areaName != null && currentUser.areaAccess.contains(areaName);
        return areaAllowedById || areaAllowedByName;
      }

      // Supervisor melihat semua.
      return true;
    }).toList();

    debugPrint(
      '[DeepLinkHandler] fallback candidates => role: $role, areaFilter: $areaIdFromValidation, count: ${candidates.length}, explicitTaskId: $explicitTaskId',
    );

    if (explicitTaskId != null && explicitTaskId.isNotEmpty) {
      final found = candidates.firstWhere(
        (task) => task['id']?.toString() == explicitTaskId,
        orElse: () => <String, dynamic>{},
      );

      if (found.isNotEmpty) {
        return explicitTaskId;
      }
    }

    if (candidates.length == 1) {
      return candidates.first['id']?.toString();
    }

    return null;
  }

  String? _pickTaskId(Map<String, dynamic>? map) {
    if (map == null) return null;
    final values = [
      map['taskId'],
      map['task_id'],
      map['reportId'],
      map['report_id'],
      map['id'],
    ];

    for (final value in values) {
      final text = value?.toString();
      if (text != null && text.trim().isNotEmpty) {
        return text.trim();
      }
    }
    return null;
  }

  bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    if (normalized == 'true' || normalized == '1' || normalized == 'yes' || normalized == 'valid' || normalized == 'authorized') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no' || normalized == 'invalid' || normalized == 'unauthorized') {
      return false;
    }
    return null;
  }

  void _navigateToRelevantList(UserRole role, String message) {
    if (!mounted || _hasNavigated) return;

    final route = switch (role) {
      UserRole.petugasHse => RouteNames.petugasAllTasks,
      UserRole.hseSupervisor => RouteNames.supervisorAllTasks,
      UserRole.pic => RouteNames.picTasks,
    };

    _goOnceNamed(route);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        AppToast.info(context, message: message);
      }
    });
  }

  void _navigateBasedOnRoleWithCustomMessage(UserRole role, String message) {
    if (!mounted || _hasNavigated) return;

    switch (role) {
      case UserRole.petugasHse:
        _goOnce('/petugas/home');
        break;
      case UserRole.hseSupervisor:
        _goOnce('/supervisor/home');
        break;
      case UserRole.pic:
        _goOnce('/pic/home');
        break;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        AppToast.error(context, message: message);
      }
    });
  }

  void _navigateToTaskDetail(String taskId, String message) {
    if (!mounted || _hasNavigated) return;

    debugPrint(
      '[DeepLinkHandler] grant access -> taskId: $taskId, sourceToken: ${widget.token}',
    );

    // Navigate dulu, baru toast
    _goOnceNamed(
      RouteNames.taskDetail,
      pathParameters: {'id': taskId},
      queryParameters: {'picToken': widget.token},
    );

    // Toast setelah navigasi untuk hindari context dispose error
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        AppToast.success(
          context,
          message: message,
        );
      }
    });
  }

  void _navigateToHome(String routeName, String message) {
    if (!mounted || _hasNavigated) return;

    // Navigate dulu, baru toast
    _goOnceNamed(routeName);

    // Toast setelah navigasi
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        AppToast.error(
          context,
          message: message,
        );
      }
    });
  }

  void _navigateBasedOnRoleWithError(UserRole role, bool isNotFoundError) {
    if (!mounted || _hasNavigated) return;

    final String errorMessage;
    if (isNotFoundError) {
      errorMessage = 'Laporan tidak ditemukan atau telah dihapus.';
    } else {
      errorMessage = 'Gagal memuat detail laporan. Pastikan link masih valid.';
    }

    // Navigate dulu
    switch (role) {
      case UserRole.petugasHse:
        _goOnce('/petugas/home');
        break;
      case UserRole.hseSupervisor:
        _goOnce('/supervisor/home');
        break;
      case UserRole.pic:
        _goOnce('/pic/home');
        break;
    }

    // Toast setelah navigasi
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        AppToast.error(
          context,
          message: errorMessage,
        );
      }
    });
  }

  void _goOnce(String location) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    debugPrint('[DeepLinkHandler] navigate -> $location');
    context.go(location);
  }

  void _goOnceNamed(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
  }) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    debugPrint(
      '[DeepLinkHandler] navigate named -> $routeName, pathParameters: $pathParameters, queryParameters: $queryParameters',
    );
    context.goNamed(
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
    );
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  UserRole _resolveRole(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized == 'supervisor' || normalized == 'hse_supervisor') {
      return UserRole.hseSupervisor;
    }
    if (normalized == 'pic' || normalized == 'pic_area') {
      return UserRole.pic;
    }
    return UserRole.petugasHse;
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading screen sambil memproses
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat laporan...'),
          ],
        ),
      ),
    );
  }
}
