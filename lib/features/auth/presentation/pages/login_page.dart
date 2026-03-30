import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _doLogin() async {
    final success = await ref.read(authNotifierProvider.notifier).login(
      _usernameController.text,
      _passwordController.text,
    );
    if (success && mounted) {
       context.goNamed(RouteNames.splash);
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           behavior: SnackBarBehavior.floating,
           content: Text(ref.read(authNotifierProvider).error ?? 'Login Failed'),
           backgroundColor: Colors.red.shade800,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
         ),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (authState.isLoading)
                const LinearProgressIndicator(color: Colors.teal),
                
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shield, size: 56, color: Colors.teal.shade700),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'HSE Aksamala',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masuk untuk melanjutkan laporan temuan & kontrol patroli.',
                      style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Username / Email',
                      hint: 'Masukkan akses Anda...',
                      controller: _usernameController,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    
                    AppTextField(
                      label: 'Kata Sandi',
                      hint: 'Masukkan password Anda...',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    AppButton(
                      label: 'Masuk Sekarang',
                      onPressed: _doLogin,
                      isLoading: authState.isLoading,
                    ),
                    
                    const SizedBox(height: 32),
                    const Divider(thickness: 1, height: 1),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Butuh bantuan akses? ', style: TextStyle(color: Colors.grey)),
                        TextButton(
                          onPressed: () {},
                          child: Text('Hubungi Admin', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}