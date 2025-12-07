/// EngPocket - แอปติวภาษาอังกฤษสำหรับเด็กไทย
///
/// Main entry point
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/db/database_helper.dart';
import 'core/controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize database
  await DatabaseHelper.instance.init();

  // Initialize theme controller
  await themeController.init();

  runApp(const EngPocketApp());
}
