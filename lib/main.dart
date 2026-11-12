import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The system bar style itself is applied from the app's theme builder, so it
  // follows light/dark instead of being fixed to the cream canvas.
  runApp(const FoodieApp());
}
