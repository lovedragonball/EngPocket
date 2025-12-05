/// EngPocket - แอปติวภาษาอังกฤษสำหรับเด็กไทย
/// 
/// Main entry point
library;

import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseHelper.instance.init();
  
  runApp(const EngPocketApp());
}
