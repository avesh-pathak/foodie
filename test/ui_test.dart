import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodie/data/mock_data.dart';
import 'package:foodie/screens/addresses_screen.dart';
import 'package:foodie/screens/cart_screen.dart';
import 'package:foodie/screens/checkout_screen.dart';
import 'package:foodie/screens/favorites_screen.dart';
import 'package:foodie/screens/home_screen.dart';
import 'package:foodie/screens/login_screen.dart';
import 'package:foodie/screens/offers_screen.dart';
import 'package:foodie/screens/order_success_screen.dart';
import 'package:foodie/screens/order_tracking_screen.dart';
import 'package:foodie/screens/orders_screen.dart';
import 'package:foodie/screens/profile_screen.dart';
import 'package:foodie/screens/restaurant_screen.dart';
import 'package:foodie/screens/search_screen.dart';
import 'package:foodie/screens/settings_screen.dart';
import 'package:foodie/screens/support_screen.dart';
import 'package:foodie/screens/welcome_screen.dart';
import 'package:foodie/state/foodie_app_state.dart';
import 'package:foodie/state/foodie_scope.dart';
import 'package:foodie/theme/app_theme.dart';

/// All UI-level tests live in this one file: the Windows Flutter test runner
/// is noticeably more reliable with a single UI isolate than with several
/// heavy widget files compiled in parallel.

FoodieAppState _stateWithOrder() {
  final FoodieAppState state = FoodieAppState();
  state.login(identity: 'Avesh');
  state.addToCart(MockData.dishById('f_chicken_biryani')!, quantity: 2);
  state.addToCart(MockData.dishById('f_margherita')!, quantity: 1);
  state.addToCart(MockData.dishById('f_chocolate_cake')!, quantity: 1);
  return state;
}

void _sizePhone(WidgetTester tester, [Size size = const Size(390, 844)]) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// One screen under test.
class _Case {
  const _Case(
    this.name,
    this.build, {
    this.needsScaffold = false,
    this.size = const Size(390, 844),
  });

  final String name;
  final Widget Function() build;
  final bool needsScaffold;
  final Size size;
}

/// Paints every screen once and asserts the framework reported no layout
/// error. Both brightnesses are exercised, because a colour token can hide a
/// defect in one theme and expose it in the other.
///
/// `pump` is used instead of `pumpAndSettle` because several screens animate
/// forever by design (pulsing tracker dot, promo carousel).
Future<void> _runTheme(
  WidgetTester tester,
  ThemeData theme,
  String mode,
) async {
  _sizePhone(tester);

  final FoodieAppState orderState = _stateWithOrder();
  final String orderId = orderState.placeOrder().id;

  final List<_Case> cases = <_Case>[
    _Case('welcome', () => const WelcomeScreen()),
    _Case(
      'welcome small',
      () => const WelcomeScreen(),
      size: const Size(320, 568),
    ),
    _Case('login', () => const LoginScreen()),
    _Case('home', () => HomeScreen(onSelectTab: (_) {}), needsScaffold: true),
    _Case('search', () => const SearchScreen(), needsScaffold: true),
    _Case(
      'favourites',
      () => FavoritesScreen(onSelectTab: (_) {}),
      needsScaffold: true,
    ),
    _Case('orders', () => OrdersScreen(onSelectTab: (_) {}), needsScaffold: true),
    _Case(
      'profile',
      () => ProfileScreen(onSelectTab: (_) {}),
      needsScaffold: true,
    ),
    _Case(
      'restaurant',
      () => RestaurantScreen(
        restaurant: MockData.restaurants.first,
        heroTag: 'smoke',
      ),
    ),
    _Case('cart', () => const CartScreen()),
    _Case('cart narrow', () => const CartScreen(), size: const Size(320, 568)),
    _Case('checkout', () => const CheckoutScreen()),
    _Case('offers', () => const OffersScreen()),
    _Case('support', () => const SupportScreen()),
    _Case('settings', () => const SettingsScreen()),
    _Case('addresses', () => const AddressesScreen()),
    _Case('tracking', () => OrderTrackingScreen(orderId: orderId)),
    _Case('success', () => OrderSuccessScreen(orderId: orderId)),
  ];

  for (final _Case testCase in cases) {
    tester.view.physicalSize = testCase.size;

    final FoodieAppState state =
        testCase.name == 'tracking' || testCase.name == 'success'
            ? orderState
            : _stateWithOrder();
    final Widget body = testCase.needsScaffold
        ? Scaffold(body: testCase.build())
        : testCase.build();

    await tester.pumpWidget(
      FoodieScope(
        state: state,
        child: MaterialApp(theme: theme, home: body),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      tester.takeException(),
      isNull,
      reason: '$mode theme, "${testCase.name}" screen failed to lay out',
    );

    // Unmount so periodic work (promo carousel) is cancelled before the next
    // screen mounts, and drop decoded photography so the cache cannot grow
    // across the whole run.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }
}

void main() {
  testWidgets('cart renders its lines when the cart has items', (
    WidgetTester tester,
  ) async {
    _sizePhone(tester);

    final FoodieAppState state = FoodieAppState();
    state.login(identity: 'Avesh');
    state.addToCart(MockData.dishById('f_chicken_biryani')!, quantity: 1);

    await tester.pumpWidget(
      FoodieScope(
        state: state,
        child: MaterialApp(theme: AppTheme.light, home: const CartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // The bug this guards: the cart used to mount but paint an empty body.
    expect(find.text('Your cart'), findsOneWidget);
    expect(find.text('Bill details'), findsOneWidget);
    expect(find.text('Hyderabadi Chicken Dum Biryani'), findsOneWidget);
  });

  testWidgets('appearance picker switches the app between light and dark', (
    WidgetTester tester,
  ) async {
    _sizePhone(tester);

    final FoodieAppState state = FoodieAppState();
    expect(state.themeMode, ThemeMode.system);

    await tester.pumpWidget(
      FoodieScope(
        state: state,
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: state.themeMode,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Appearance'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(state.themeMode, ThemeMode.dark);
    expect(find.text('Red on black'), findsOneWidget);
  });

  testWidgets('welcome keeps Get Started above the fold on small phones', (
    WidgetTester tester,
  ) async {
    // The reported bug: on a 568 dp-tall phone the welcome copy pushed the
    // CTA below the fold. The button must be fully inside the viewport.
    for (final Size size in <Size>[
      const Size(320, 568),
      const Size(360, 640),
      const Size(390, 844),
    ]) {
      _sizePhone(tester, size);

      await tester.pumpWidget(
        FoodieScope(
          state: FoodieAppState(),
          child: MaterialApp(theme: AppTheme.light, home: const WelcomeScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1200));

      expect(
        tester.takeException(),
        isNull,
        reason: 'welcome overflowed at ${size.width}x${size.height}',
      );

      final Rect cta = tester.getRect(find.text('Get Started'));
      expect(
        cta.bottom,
        lessThanOrEqualTo(size.height),
        reason: 'Get Started sits below the fold at ${size.width}x${size.height}',
      );
      expect(cta.top, greaterThanOrEqualTo(0.0));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('every screen lays out in the light theme', (
    WidgetTester tester,
  ) async {
    await _runTheme(tester, AppTheme.light, 'light');
  });

  testWidgets('every screen lays out in the dark theme', (
    WidgetTester tester,
  ) async {
    await _runTheme(tester, AppTheme.dark, 'dark');
  });
}
