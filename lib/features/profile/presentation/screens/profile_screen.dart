import 'package:flutter/material.dart';
import '../../../../app/router/route_names.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../app/theme/app_spacing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Data Profil akan tampil di sini.'),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: 'Logout',
                type: AppButtonType.outlined,
                onPressed: () {
                  context.goNamed(RouteNames.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
