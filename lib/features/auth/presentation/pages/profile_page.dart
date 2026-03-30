import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/router/route_names.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    await ref.read(authNotifierProvider.notifier).logout();
    
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      context.goNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Profile Akses', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GFAvatar(
              size: GFSize.LARGE * 2,
              backgroundColor: GFColors.SUCCESS,
              shape: GFAvatarShape.circle,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Akun Terverifikasi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Akses Aktif: Petugas / PIC',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GFButton(
                onPressed: () => _logout(context, ref),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedLogout01,
                  color: Colors.white,
                  size: 18,
                ),
                text: 'KELUAR (LOGOUT)',
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                color: GFColors.DANGER,
                type: GFButtonType.solid,
                shape: GFButtonShape.pills,
                size: GFSize.LARGE,
                fullWidthButton: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
