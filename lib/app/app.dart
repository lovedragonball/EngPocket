/// Main App Widget
library;

import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../config/app_router.dart';
import '../core/controllers/theme_controller.dart';
import '../core/services/gamification_service.dart';

class EngPocketApp extends StatefulWidget {
  const EngPocketApp({super.key});

  @override
  State<EngPocketApp> createState() => _EngPocketAppState();
}

class _EngPocketAppState extends State<EngPocketApp>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _gamificationInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize gamification after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGamification();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GamificationService.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _gamificationInitialized) {
      // Check streak and quests when app resumes
      GamificationService.instance.recordDailyLogin();
    }
  }

  Future<void> _initializeGamification() async {
    if (_gamificationInitialized) return;

    await GamificationService.instance.initialize(_navigatorKey);
    _gamificationInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'EngPocket',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
