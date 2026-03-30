import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

class HseAksamalaApp extends StatelessWidget {
  const HseAksamalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HSE Aksamala',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SizedBox.shrink(),
    );
  }
}
