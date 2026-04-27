import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/enums/user_role.dart';
import '../providers/task_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/auth_role_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../areas/presentation/providers/area_provider.dart';

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
          _showToastAfterNavigation(() {
            AppToast.info(
              context,
              message: 'Silakan login terlebih dahulu untuk membuka laporan.',
            );
          });
        }
        return;
      }

      // 2. Resolve task detail via Endpoint Backend
      // Cek apakah token adalah ID numerik atau picToken string
      final reportId = int.tryParse(widget.token);

      debugPrint('[DeepLinkHandler] attempt to resolve task from Backend API for token: ${widget.token} (isNumeric: ${reportId != null})');

      Map<String, dynamic>? foundTask;
      bool fetchLooksUnauthorized = false;
      bool fetchLooksNotFound = false;

      try {
        if (reportId != null) {
          // Jika numeric, gunakan getTaskById (endpoint yang sudah ada)
          debugPrint('[DeepLinkHandler] Using report ID: $reportId');
          final repository = ref.read(taskRepositoryProvider);
          final taskModel = await repository.getTaskById(reportId);

          // Convert ke UI map format
          final areaNameById = await _buildAreaNameByIdMap(ref);
          foundTask = _toUiTaskMap(taskModel, areaNameById: areaNameById);
        } else {
          // Jika string, gunakan picToken (fallback)
          debugPrint('[DeepLinkHandler] Using picToken: ${widget.token}');
          foundTask = await ref.read(taskDetailByPicTokenProvider(widget.token).future);
        }

        debugPrint('[DeepLinkHandler] Task fetched successfully => ${foundTask != null ? 'ID: ${foundTask['id']}, Area: ${foundTask['area']}, AreaId: ${foundTask['areaId']}' : 'null'}');
      } catch (e) {
        debugPrint('[DeepLinkHandler] failed to fetch from backend: $e');
        final errorMsg = e.toString().toLowerCase();

        fetchLooksUnauthorized =
            errorMsg.contains('403') ||
            errorMsg.contains('forbidden') ||
            errorMsg.contains('unauthorized') ||
            errorMsg.contains('not authorized') ||
            errorMsg.contains('tidak memiliki akses') ||
            errorMsg.contains('access denied');

        fetchLooksNotFound =
            errorMsg.contains('404') || errorMsg.contains('not found');

        debugPrint(
          '[DeepLinkHandler] fetch classification => unauthorized: $fetchLooksUnauthorized, notFound: $fetchLooksNotFound',
        );

        if (isPicScopedRole(currentUser.role)) {
          foundTask = await _findAccessiblePicScopedTask(currentUser);
          if (foundTask != null) {
            debugPrint(
              '[DeepLinkHandler] recovered task for PIC-scoped role from local accessible provider => id=${foundTask['id']}',
            );
          }
        }

        if (fetchLooksUnauthorized && foundTask == null) {
          _navigateBasedOnRoleWithCustomMessage(
            currentUser.role,
            'Laporan valid, namun di luar tanggung jawab area Anda.',
          );
          return;
        }

        if (fetchLooksNotFound && foundTask == null) {
          _navigateBasedOnRoleWithCustomMessage(
            currentUser.role,
            'Laporan tidak ditemukan, sudah dihapus, atau link tidak valid.',
          );
          return;
        }
      }

      if (foundTask == null) {
        final isPicAreaAccessCase =
            isPicScopedRole(currentUser.role) && fetchLooksUnauthorized;

        debugPrint(
          '[DeepLinkHandler] foundTask null => role: ${currentUser.role}, isPicAreaAccessCase: $isPicAreaAccessCase',
        );

        _navigateBasedOnRoleWithCustomMessage(
          currentUser.role,
          isPicAreaAccessCase
              ? 'Laporan valid, namun di luar tanggung jawab area Anda.'
              : 'Gagal membuka laporan. Laporan mungkin tidak valid atau koneksi bermasalah.',
        );
        return;
      }

      // 3. Validasi Role & Area Akses
      bool roleAllowed = _isRoleAllowedForTask(currentUser, foundTask);
      
      // Jika PIC ditolak oleh currentUser, coba verifikasi dengan menarik data area nya langsung.
      if (!roleAllowed && isPicScopedRole(currentUser.role)) {
        try {
          debugPrint('[DeepLinkHandler] PIC role detected but initial check failed. Fetching areas from API...');
          final picAreas = await ref.read(areaByUserProvider.future);
          final areaId = foundTask['areaId']?.toString();
          final areaName = foundTask['area']?.toString();

          debugPrint('[DeepLinkHandler] Task data => areaId: $areaId, areaName: $areaName');
          debugPrint('[DeepLinkHandler] PIC areas count: ${picAreas.length}');

          if (picAreas.isEmpty) {
            debugPrint('[DeepLinkHandler] WARNING: PIC has no areas assigned!');
          } else {
            debugPrint('[DeepLinkHandler] Available areas: ${picAreas.map((a) => '${a.id}:${a.name}').join(', ')}');
          }

          // Perbaiki: Cek areaId dan areaName dengan lebih robust
          bool hasAreaById = false;
          bool hasAreaByName = false;

          if (areaId != null) {
            hasAreaById = picAreas.any((a) => a.id.toString() == areaId.trim());
            debugPrint('[DeepLinkHandler] Checking areaId "$areaId": $hasAreaById');
          }

          if (areaName != null) {
            // Case-insensitive comparison untuk area name
            hasAreaByName = picAreas.any((a) => a.name.toLowerCase().trim() == areaName.toLowerCase().trim());
            debugPrint('[DeepLinkHandler] Checking areaName "$areaName": $hasAreaByName');
          }

          final areaAllowed = hasAreaById || hasAreaByName;
          final toDepartment = _toInt(foundTask['to_department'] ?? foundTask['toDepartment']) ?? 0;
          final engineerAllowed = !isPicEngineerRole(currentUser.role) || toDepartment == 2;
          roleAllowed = areaAllowed && engineerAllowed;
          debugPrint('[DeepLinkHandler] Final PIC roleAllowed: $roleAllowed (byId: $hasAreaById, byName: $hasAreaByName)');
        } catch (e) {
          debugPrint('[DeepLinkHandler] Failed to fetch picAreas provider: $e');
        }
      }

      final taskId = foundTask['id']?.toString() ?? '';
      
      debugPrint('[DeepLinkHandler] Task found => taskId: $taskId, final roleAllowed: $roleAllowed');

      if (!roleAllowed) {
        final denyMessage = 'Laporan valid, namun Anda tidak memiliki akses untuk task ini.';
        _navigateBasedOnRoleWithCustomMessage(currentUser.role, denyMessage);
        return;
      }

      if (taskId.isNotEmpty) {
        _navigateToTaskDetail(taskId, 'Melanjutkan tindakan ke detail laporan.');
        return;
      }

      _navigateToRelevantList(
        currentUser.role,
        'Token valid, namun ID task spesifik tidak dapat ditentukan.',
      );

    } catch (e, st) {
      debugPrint('[DeepLinkHandler] Error: $e');
      debugPrint('[DeepLinkHandler] StackTrace: $st');

      // Navigate ke home berdasarkan role
      final role = ref.read(currentUserProvider)?.role ?? UserRole.petugasHse;
      if (mounted) {
        _navigateBasedOnRoleWithError(role, true);
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<Map<String, dynamic>?> _findAccessiblePicScopedTask(
    UserModel currentUser,
  ) async {
    if (!isPicScopedRole(currentUser.role)) {
      return null;
    }

    final accessibleTasks = await ref.read(picAccessibleTaskMapsProvider.future);
    final token = widget.token.trim();

    final matched = accessibleTasks.where((task) {
      final taskId = task['id']?.toString().trim();
      final picToken = task['picToken']?.toString().trim() ??
          task['pic_token']?.toString().trim();

      return taskId == token || picToken == token;
    }).toList();

    if (matched.isEmpty) {
      return null;
    }

    return matched.first;
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
      '[DeepLinkHandler] Initial role validation => '
      'role: $role, '
      'authorId: $authorId, '
      'areaId: $areaId, '
      'areaName: $areaName, '
      'currentUser.areaAccess: ${currentUser.areaAccess}',
    );

    if (role == UserRole.hseSupervisor) {
      debugPrint('[DeepLinkHandler] access granted: supervisor can access all task details');
      return true;
    }

    if (role == UserRole.petugasHse) {
      debugPrint('[DeepLinkHandler] access granted: petugas can access task detail for monitoring');
      return true;
    }

    if (isPicScopedRole(role)) {
      // PERBAIKAN: currentUser.areaAccess mungkin kosong atau tidak terpopulate dengan benar
      // Jadi kita return false agar trigger fallback logic ke areaByUserProvider
      if (currentUser.areaAccess.isEmpty) {
        debugPrint('[DeepLinkHandler] PIC areaAccess is empty, will use fallback to API');
        return false;
      }

      final hasAreaById = areaId != null && currentUser.areaAccess.contains(areaId);
      final hasAreaByName = areaName != null && currentUser.areaAccess.contains(areaName);

      debugPrint('[DeepLinkHandler] PIC areaAccess check => byId: $hasAreaById, byName: $hasAreaByName');

      final areaAllowed = hasAreaById || hasAreaByName;
      if (!areaAllowed) {
        return false;
      }

      int toDepartment = _toInt(taskMap['to_department'] ?? taskMap['toDepartment']) ?? 0;

      if (isPicEngineerRole(role)) {
        final engineerAllowed = toDepartment == 2;
        debugPrint('[DeepLinkHandler] PIC Engineer validation => areaAllowed: $areaAllowed, engineerAllowed: $engineerAllowed, to_department: $toDepartment');
        return engineerAllowed;
      }

      if (isPicHrgaRole(role)) {
        final hrgaAllowed = toDepartment == 1;
        debugPrint('[DeepLinkHandler] PIC HRGA validation => areaAllowed: $areaAllowed, hrgaAllowed: $hrgaAllowed, to_department: $toDepartment');
        return hrgaAllowed;
      }

      return true;
    }

    return false;
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
    _hasNavigated = true;

    // Navigate ke home dulu untuk establish shell
    final homeRoute = switch (role) {
      UserRole.petugasHse => '/petugas/home',
      UserRole.hseSupervisor => '/supervisor/home',
      UserRole.pic => '/pic/home',
      UserRole.picEngineer => '/pic/home',
      UserRole.picHrga => '/pic/home',
    };

    debugPrint('[DeepLinkHandler] navigate to home -> $homeRoute');
    context.go(homeRoute);

    _showToastAfterNavigation(() {
      AppToast.info(context, message: message);
    });
  }

  void _navigateBasedOnRoleWithCustomMessage(UserRole role, String message) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    final homeRoute = switch (role) {
      UserRole.petugasHse => '/petugas/home',
      UserRole.hseSupervisor => '/supervisor/home',
      UserRole.pic => '/pic/home',
      UserRole.picEngineer => '/pic/home',
      UserRole.picHrga => '/pic/home',
    };

    debugPrint('[DeepLinkHandler] navigate to home -> $homeRoute');
    context.go(homeRoute);

    _showToastAfterNavigation(() {
      AppToast.error(context, message: message);
    });
  }

  void _navigateToTaskDetail(String taskId, String message) {
    if (!mounted || _hasNavigated) return;

    debugPrint(
      '[DeepLinkHandler] grant access -> taskId: $taskId, sourceToken: ${widget.token}',
    );

    // PERBAIKAN: Langsung navigate ke task detail tanpa lewat home
    // Ketika user tekan back dari task detail, GoRouter akan otomatis
    // redirect ke home route yang sesuai dengan role user
    _hasNavigated = true;

    debugPrint('[DeepLinkHandler] Navigating directly to task detail: $taskId');

    try {
      // Gunakan context.goNamed untuk replace current location dengan task detail.
      // Pakai post frame callback agar sinkron terhadap lifecycle frame aktif.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        context.goNamed(
          RouteNames.taskDetail,
          pathParameters: {'id': taskId},
        );
        debugPrint('[DeepLinkHandler] Successfully navigated to task detail');

        _showToastAfterNavigation(() {
          AppToast.success(context, message: message);
        });
      });
    } catch (e) {
      debugPrint('[DeepLinkHandler] Error navigating to task detail: $e');
      // Fallback: coba dengan pushNamed
      try {
        context.pushNamed(
          RouteNames.taskDetail,
          pathParameters: {'id': taskId},
        );
      } catch (e2) {
        debugPrint('[DeepLinkHandler] Fatal error: $e2');
      }
    }
  }

  void _navigateBasedOnRoleWithError(UserRole role, bool isNotFoundError) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    final String errorMessage;
    if (isNotFoundError) {
      errorMessage = 'Laporan tidak ditemukan atau telah dihapus.';
    } else {
      errorMessage = 'Gagal memuat detail laporan. Pastikan link masih valid.';
    }

    final homeRoute = switch (role) {
      UserRole.petugasHse => '/petugas/home',
      UserRole.hseSupervisor => '/supervisor/home',
      UserRole.pic => '/pic/home',
      UserRole.picEngineer => '/pic/home',
      UserRole.picHrga => '/pic/home',
    };

    debugPrint('[DeepLinkHandler] navigate to home with error -> $homeRoute');
    context.go(homeRoute);

    _showToastAfterNavigation(() {
      AppToast.error(
        context,
        message: errorMessage,
      );
    });
  }

  void _showToastAfterNavigation(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      action();
    });
  }

  void _goOnce(String location) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    debugPrint('[DeepLinkHandler] navigate -> $location');
    context.go(location);
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<Map<int, String>> _buildAreaNameByIdMap(WidgetRef ref) async {
    try {
      debugPrint('[DeepLinkHandler] _buildAreaNameByIdMap ref runtimeType: ${ref.runtimeType}');
      final areas = await ref.read(areaRepositoryProvider).getAreas();
      debugPrint('[DeepLinkHandler] _buildAreaNameByIdMap fetched areas: ${areas.length}');
      return {
        for (final area in areas) area.id: area.name,
      };
    } catch (e) {
      debugPrint('[DeepLinkHandler] _buildAreaNameByIdMap failed: $e');
      return <int, String>{};
    }
  }

  Map<String, dynamic> _toUiTaskMap(
    dynamic task, {
    required Map<int, String> areaNameById,
  }) {
    // Handle both HseTaskModel and Map types
    final id = task is Map ? task['id'] : task.id;
    final areaId = task is Map ? task['area_id'] ?? task['areaId'] : task.areaId;
    final areaName = areaNameById[areaId] ?? 'Area #$areaId';
    final title = task is Map ? task['title'] ?? task['name'] : task.name ?? 'Inspeksi $areaName';
    final status = task is Map ? task['status'] : task.status;
    final picToken = task is Map ? task['pic_token'] ?? task['picToken'] : task.picToken;
    final toDepartment = task is Map
        ? (_toInt(task['to_department'] ?? task['toDepartment']) ?? 0)
        : task.toDepartment;

    return <String, dynamic>{
      'id': id.toString(),
      'taskId': id,
      'picToken': picToken,
      'title': title,
      'area': areaName,
      'areaId': areaId.toString(),
      'rootCause': task is Map ? task['root_cause'] ?? task['rootCause'] : task.rootCause,
      'notes': task is Map ? task['notes'] : task.notes,
      'riskLevel': task is Map ? task['risk_level'] ?? task['riskLevel'] : task.riskLevel,
      'status': status,
      'to_department': toDepartment,
      'toDepartment': toDepartment,
      'date': task is Map ? task['date'] ?? task['created_at'] : task.date,
      'authorId': task is Map ? task['user_id'] ?? task['created_by'] : task.userId,
      'userId': task is Map ? task['user_id'] ?? task['created_by'] : task.userId,
      'createdBy': task is Map ? task['user_id'] ?? task['created_by'] : task.userId,
      'created_by': task is Map ? task['user_id'] ?? task['created_by'] : task.userId,
      'photos': task is Map ? task['photos'] : task.photos,
      'followUps': task is Map ? (task['follow_ups'] ?? task['followUps'] ?? []) : task.followUps,
    };
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
