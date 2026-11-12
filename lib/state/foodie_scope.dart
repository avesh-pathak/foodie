import 'package:flutter/widgets.dart';

import 'foodie_app_state.dart';

class FoodieScope extends InheritedNotifier<FoodieAppState> {
  const FoodieScope({
    super.key,
    required FoodieAppState state,
    required super.child,
  }) : super(notifier: state);

  static FoodieAppState of(BuildContext context) {
    final FoodieScope? scope =
        context.dependOnInheritedWidgetOfExactType<FoodieScope>();
    assert(scope != null, 'FoodieScope is missing above this context.');
    return scope!.notifier!;
  }

  static FoodieAppState read(BuildContext context) {
    final FoodieScope? scope =
        context.getInheritedWidgetOfExactType<FoodieScope>();
    assert(scope != null, 'FoodieScope is missing above this context.');
    return scope!.notifier!;
  }
}
