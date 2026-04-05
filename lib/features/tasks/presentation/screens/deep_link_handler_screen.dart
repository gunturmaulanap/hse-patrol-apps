import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/enums/user_role.dart';
import '../providers/task_provider.dart';
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
  @override
  void initState() {
    super.initState();
    // Jalankan validasi setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processDeepLink();
    });
  }

  Future<void> _processDeepLink() async {
    try {
      // 1. Cek Otentikasi
      final authState = ref.read(authNotifierProvider);
      final user = authState.user;

      if (user == null) {
        // Belum login - arahkan ke login
        debugPrint('[DeepLinkHandler] User belum login, redirect ke login');
        if (mounted) {
          // Tampilkan toast setelah navigasi untuk menghindari context dispose error
          context.goNamed(RouteNames.login);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              AppToast.info(
                context,
                message: 'Silakan login terlebih dahulu',
              );
            }
          });
        }
        return;
      }

      // 2. Fetch Data Task berdasarkan PIC Token
      debugPrint('[DeepLinkHandler] Fetching task dengan token: ${widget.token}');
      final taskAsyncValue = await ref.read(taskDetailByPicTokenProvider(widget.token).future);

      final taskId = taskAsyncValue['id']?.toString() ?? '';
      final authorId = taskAsyncValue['authorId'] as int?;
      final areaId = taskAsyncValue['areaId']?.toString();

      debugPrint('[DeepLinkHandler] Task ID: $taskId, Author ID: $authorId, Area ID: $areaId');

      // 3. Validasi Role & Akses
      final role = user.role;

      if (role == UserRole.hseSupervisor) {
        // Supervisor - Akses penuh (by-pass validasi)
        debugPrint('[DeepLinkHandler] User adalah Supervisor - akses penuh');
        _navigateToTaskDetail(taskId, 'Melanjutkan tindakan follow-up task.');
        return;
      }

      if (role == UserRole.petugasHse) {
        // Petugas HSE - Cek authorId
        if (authorId == user.id) {
          // Same author - boleh akses
          debugPrint('[DeepLinkHandler] Petugas adalah pembuat laporan');
          _navigateToTaskDetail(taskId, 'Melanjutkan tindakan...');
        } else {
          // Different author - tolak akses
          debugPrint('[DeepLinkHandler] Laporan dibuat oleh petugas lain');
          _navigateToHome(RouteNames.petugasHome, 'Laporan tersebut dibuat oleh Petugas HSE lain.');
        }
        return;
      }

      if (role == UserRole.pic) {
        // PIC - Cek area access
        if (areaId != null && user.areaAccess.contains(areaId)) {
          // Punya kewenangan area
          debugPrint('[DeepLinkHandler] PIC punya kewenangan area');
          _navigateToTaskDetail(taskId, 'Melanjutkan tindakan...');
        } else {
          // Tidak punya kewenangan
          debugPrint('[DeepLinkHandler] PIC tidak punya kewenangan area ini');
          _navigateToHome(RouteNames.picHome, 'Task tersebut bukan tanggung jawab area Anda.');
        }
        return;
      }

      // Role tidak dikenali
      debugPrint('[DeepLinkHandler] Role tidak dikenali: $role');
      _navigateToHome(RouteNames.petugasHome, 'Role tidak dikenali.');

    } catch (e, st) {
      debugPrint('[DeepLinkHandler] Error: $e');
      debugPrint('[DeepLinkHandler] StackTrace: $st');

      // Cek apakah ini error 404 (task tidak ditemukan)
      final errorMessage = e.toString().toLowerCase();
      final isNotFoundError = errorMessage.contains('404') ||
                              errorMessage.contains('not found') ||
                              errorMessage.contains('task tidak ditemukan');

      // Navigate ke home berdasarkan role
      final authState = ref.read(authNotifierProvider);
      final user = authState.user;

      if (mounted) {
        if (user != null) {
          _navigateBasedOnRoleWithError(user.role, isNotFoundError);
        } else {
          // Fallback ke petugas home jika user null
          context.go('/petugas/home');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              AppToast.error(
                context,
                message: 'Gagal memuat detail laporan. Pastikan link masih valid.',
              );
            }
          });
        }
      }
    }
  }

  void _navigateToTaskDetail(String taskId, String message) {
    if (!mounted) return;

    // Navigate dulu, baru toast
    context.goNamed(
      RouteNames.taskDetail,
      pathParameters: {'id': taskId},
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
    if (!mounted) return;

    // Navigate dulu, baru toast
    context.goNamed(routeName);

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
    if (!mounted) return;

    final String errorMessage;
    if (isNotFoundError) {
      errorMessage = 'Laporan tidak ditemukan atau telah dihapus.';
    } else {
      errorMessage = 'Gagal memuat detail laporan. Pastikan link masih valid.';
    }

    // Navigate dulu
    switch (role) {
      case UserRole.petugasHse:
        context.go('/petugas/home');
        break;
      case UserRole.hseSupervisor:
        context.go('/supervisor/home');
        break;
      case UserRole.pic:
        context.go('/pic/home');
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
