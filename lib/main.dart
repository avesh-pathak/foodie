import 'package:flutter/material.dart';

import 'app.dart';
import 'services/api_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pull the live menu from the Foodie backend when it is reachable, and
  // refresh periodically so admin edits appear in the customer app.
  ApiSync().start();
  // The system bar style itself is applied from the app's theme builder, so it
  // follows light/dark instead of being fixed to the cream canvas.
  runApp(const FoodieApp());
}