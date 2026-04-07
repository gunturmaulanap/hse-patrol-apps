import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/enums/user_role.dart';
import '../providers/task_provider.dart';
import '../../../auth/data/models/user_model.dart';
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

      // 2. Resolve task detail via Endpoint Backend (2-step API request)
      debugPrint('[DeepLinkHandler] attempt to resolve task from Backend API for token: ${widget.token}');

      Map<String, dynamic>? foundTask;
      try {
        foundTask = await ref.read(taskDetailByPicTokenProvider(widget.token).future);
        debugPrint('[DeepLinkHandler] Task fetched successfully => ${foundTask != null ? 'ID: ${foundTask['id']}, Area: ${foundTask['area']}, AreaId: ${foundTask['areaId']}' : 'null'}');
      } catch (e) {
        debugPrint('[DeepLinkHandler] failed to fetch from backend: $e');
        final errorMsg = e.toString().toLowerCase();

        // PERBAIKAN: Handle 401 Unauthorized (token expired)
        if (errorMsg.contains('401') || errorMsg.contains('unauthorized') || errorMsg.contains('tidak memiliki akses')) {
          debugPrint('[DeepLinkHandler] Token expired or unauthorized, redirecting to login');
          if (mounted) {
            final intendedPath = '/share/report/${widget.token}';
            final encodedRedirect = Uri.encodeComponent(intendedPath);
            final loginPath = '/login?redirect=$encodedRedirect';

            context.go(loginPath);

            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                AppToast.error(
                  context,
                  message: 'Sesi Anda telah berakhir. Silakan login kembali untuk membuka laporan.',
                );
              }
            });
          }
          return;
        }

        if (errorMsg.contains('403') || errorMsg.contains('forbidden')) {
          _navigateBasedOnRoleWithCustomMessage(
            currentUser.role,
            'Laporan valid, namun di luar tanggung jawab area Anda.',
          );
          return;
        }

        if (errorMsg.contains('404') || errorMsg.contains('not found')) {
          _navigateBasedOnRoleWithCustomMessage(
            currentUser.role,
            'Laporan tidak ditemukan, sudah dihapus, atau token kedaluwarsa.',
          );
          return;
        }
      }

      if (foundTask == null) {
        _navigateBasedOnRoleWithCustomMessage(
          currentUser.role,
          'Gagal membuka laporan. Laporan mungkin tidak valid atau koneksi bermasalah.',
        );
        return;
      }

      // 3. Validasi Role & Area Akses
      bool roleAllowed = _isRoleAllowedForTask(currentUser, foundTask);
      
      // Jika PIC ditolak oleh currentUser, coba verifikasi dengan menarik data area nya langsung.
      if (!roleAllowed && currentUser.role == UserRole.pic) {
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

          roleAllowed = hasAreaById || hasAreaByName;
          debugPrint('[DeepLinkHandler] Final PIC roleAllowed: $roleAllowed (byId: $hasAreaById, byName: $hasAreaByName)');
        } catch (e) {
          debugPrint('[DeepLinkHandler] Failed to fetch picAreas provider: $e');
          final errorMsg = e.toString().toLowerCase();

          // PERBAIKAN: Handle 401 Unauthorized (token expired)
          if (errorMsg.contains('401') || errorMsg.contains('unauthorized') || errorMsg.contains('tidak memiliki akses')) {
            debugPrint('[DeepLinkHandler] Token expired while fetching PIC areas, redirecting to login');
            if (mounted) {
              final intendedPath = '/share/report/${widget.token}';
              final encodedRedirect = Uri.encodeComponent(intendedPath);
              final loginPath = '/login?redirect=$encodedRedirect';

              context.go(loginPath);

              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  AppToast.error(
                    context,
                    message: 'Sesi Anda telah berakhir. Silakan login kembali.',
                  );
                }
              });
            }
            return;
          }
        }
      }

      final taskId = foundTask['id']?.toString() ?? '';
      
      debugPrint('[DeepLinkHandler] Task found => taskId: $taskId, final roleAllowed: $roleAllowed');

      if (!roleAllowed) {
        _navigateBasedOnRoleWithCustomMessage(
          currentUser.role,
          'Laporan valid, namun Anda tidak memiliki akses untuk task ini.',
        );
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

    if (role == UserRole.hseSupervisor || role == UserRole.petugasHse) {
      return true;
    }

    if (role == UserRole.pic) {
      // PERBAIKAN: currentUser.areaAccess mungkin kosong atau tidak terpopulate dengan benar
      // Jadi kita return false agar trigger fallback logic ke areaByUserProvider
      if (currentUser.areaAccess.isEmpty) {
        debugPrint('[DeepLinkHandler] PIC areaAccess is empty, will use fallback to API');
        return false;
      }

      final hasAreaById = areaId != null && currentUser.areaAccess.contains(areaId);
      final hasAreaByName = areaName != null && currentUser.areaAccess.contains(areaName);

      debugPrint('[DeepLinkHandler] PIC areaAccess check => byId: $hasAreaById, byName: $hasAreaByName');

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
    _hasNavigated = true;

    // Navigate ke home dulu untuk establish shell
    final homeRoute = switch (role) {
      UserRole.petugasHse => '/petugas/home',
      UserRole.hseSupervisor => '/supervisor/home',
      UserRole.pic => '/pic/home',
    };

    debugPrint('[DeepLinkHandler] navigate to home -> $homeRoute');
    context.go(homeRoute);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        AppToast.info(context, message: message);
      }
    });
  }

  void _navigateBasedOnRoleWithCustomMessage(UserRole role, String message) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    final homeRoute = switch (role) {
      UserRole.petugasHse => '/petugas/home',
      UserRole.hseSupervisor => '/supervisor/home',
      UserRole.pic => '/pic/home',
    };

    debugPrint('[DeepLinkHandler] navigate to home -> $homeRoute');
    context.go(homeRoute);

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

    // PERBAIKAN: Langsung navigate ke task detail tanpa lewat home
    // Ketika user tekan back dari task detail, GoRouter akan otomatis
    // redirect ke home route yang sesuai dengan role user
    _hasNavigated = true;

    debugPrint('[DeepLinkHandler] Navigating directly to task detail: $taskId');

    try {
      // Gunakan context.goNamed untuk replace current location dengan task detail
      // Ini akan menghapus deep link handler dari stack
      context.goNamed(
        RouteNames.taskDetail,
        pathParameters: {'id': taskId},
        queryParameters: {'picToken': widget.token},
      );
      debugPrint('[DeepLinkHandler] Successfully navigated to task detail');

      // Toast akan ditampilkan di task detail screen
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          AppToast.success(context, message: message);
        }
      });
    } catch (e) {
      debugPrint('[DeepLinkHandler] Error navigating to task detail: $e');
      // Fallback: coba dengan pushNamed
      try {
        context.pushNamed(
          RouteNames.taskDetail,
          pathParameters: {'id': taskId},
          queryParameters: {'picToken': widget.token},
        );
      } catch (e2) {
        debugPrint('[DeepLinkHandler] Fatal error: $e2');
      }
    }
  }

  void _navigateToHome(String routeName, String message) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    debugPrint('[DeepLinkHandler] navigate to home -> $routeName');
    context.go(routeName);

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
    };

    debugPrint('[DeepLinkHandler] navigate to home with error -> $homeRoute');
    context.go(homeRoute);

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
