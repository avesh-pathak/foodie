import 'package:flutter/material.dart';

class FoodiePageRoute<T> extends PageRouteBuilder<T> {
  FoodiePageRoute({
    required Widget page,
    super.settings,
    super.fullscreenDialog = false,
  }) : super(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return page;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            if (MediaQuery.disableAnimationsOf(context)) return child;
            final CurvedAnimation curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(curved),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.045, 0.02),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
