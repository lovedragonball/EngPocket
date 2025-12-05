/// Main App Widget
library;

import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../config/app_router.dart';

class EngPocketApp extends StatelessWidget {
  const EngPocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EngPocket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
