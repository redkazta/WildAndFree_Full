import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';

class WildErpApp extends StatelessWidget {
  const WildErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wild Gvng ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
