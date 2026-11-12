import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/welcome_screen.dart';
import 'state/foodie_app_state.dart';
import 'state/foodie_scope.dart';
import 'theme/app_theme.dart';

class FoodieApp extends StatefulWidget {
  const FoodieApp({super.key});

  @override
  State<FoodieApp> createState() => _FoodieAppState();
}

class _FoodieAppState extends State<FoodieApp> {
  final FoodieAppState _state = FoodieAppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FoodieScope(
      state: _state,
      child: AnimatedBuilder(
        animation: _state,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: 'Foodie',
            debugShowCheckedModeBanner: false,
            // Both palettes live on the theme, so the whole app follows the
            // brightness without a single hardcoded colour changing.
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _state.themeMode,
            home: const WelcomeScreen(),
            builder: (BuildContext context, Widget? child) {
              // The system bars follow the active palette so the status and
              // navigation icons stay legible on either canvas.
              final ThemeData theme = Theme.of(context);
              final bool isDark = theme.brightness == Brightness.dark;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                  statusBarBrightness:
                      isDark ? Brightness.dark : Brightness.light,
                  systemNavigationBarColor: theme.scaffoldBackgroundColor,
                  systemNavigationBarIconBrightness:
                      isDark ? Brightness.light : Brightness.dark,
                ),
                child: MediaQuery.withClampedTextScaling(
                  minScaleFactor: 0.9,
                  maxScaleFactor: 1.3,
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
