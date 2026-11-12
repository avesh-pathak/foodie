import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/foodie_bottom_nav.dart';
import '../widgets/foodie_logo.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[
      HomeScreen(onSelectTab: _goToTab),
      const SearchScreen(),
      OrdersScreen(onSelectTab: _goToTab),
      FavoritesScreen(onSelectTab: _goToTab),
      ProfileScreen(onSelectTab: _goToTab),
    ];
  }

  void _goToTab(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final int activeOrders = FoodieScope.of(context).activeOrders.length;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useRail =
            constraints.maxWidth >= 840 && constraints.maxHeight >= 600;
        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop && _currentIndex != 0) {
              setState(() => _currentIndex = 0);
            }
          },
          child: useRail
              ? _buildWideLayout(activeOrders)
              : _buildCompactLayout(activeOrders),
        );
      },
    );
  }

  Widget _buildCompactLayout(int activeOrders) {
    return Scaffold(
      extendBody: true,
      backgroundColor: context.foodie.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: FoodieBottomNav(
        currentIndex: _currentIndex,
        onTap: _goToTab,
        activeOrderCount: activeOrders,
      ),
    );
  }

  Widget _buildWideLayout(int activeOrders) {
    return Scaffold(
      backgroundColor: context.foodie.background,
      body: SafeArea(
        child: Row(
          children: <Widget>[
            _FoodieNavigationRail(
              currentIndex: _currentIndex,
              activeOrderCount: activeOrders,
              onTap: _goToTab,
            ),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodieNavigationRail extends StatelessWidget {
  const _FoodieNavigationRail({
    required this.currentIndex,
    required this.activeOrderCount,
    required this.onTap,
  });

  final int currentIndex;
  final int activeOrderCount;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.foodie.surface,
        border: Border(
          right: BorderSide(
            color: context.foodie.border.withValues(alpha: 0.85),
          ),
        ),
      ),
      child: NavigationRailTheme(
        data: NavigationRailThemeData(
          backgroundColor: context.foodie.surface,
          indicatorColor: context.foodie.primarySoft,
          elevation: 0,
          selectedIconTheme: IconThemeData(
            color: context.foodie.primaryInk,
            size: 22,
          ),
          unselectedIconTheme: IconThemeData(
            color: context.foodie.muted,
            size: 22,
          ),
          selectedLabelTextStyle: context.foodieType.label.copyWith(
            color: context.foodie.primaryInk,
            fontSize: 11.5,
          ),
          unselectedLabelTextStyle: context.foodieType.label.copyWith(
            color: context.foodie.muted,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
          useIndicator: true,
          minExtendedWidth: 196,
        ),
        child: NavigationRail(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          extended: true,
          groupAlignment: -0.75,
          leading: const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 28),
            child: FoodieLogo(size: 34),
          ),
          trailing: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: context.foodie.background,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: context.foodie.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: context.foodie.info,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Demo mode',
                    style: context.foodieType.small.copyWith(
                      fontSize: 8.5,
                      color: context.foodie.infoInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
          destinations: <NavigationRailDestination>[
            const NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: Text('Home'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded),
              label: Text('Search'),
            ),
            NavigationRailDestination(
              icon: Badge(
                isLabelVisible: activeOrderCount > 0,
                label: Text('$activeOrderCount'),
                backgroundColor: context.foodie.primary,
                textColor: context.foodie.onPrimary,
                child: const Icon(Icons.receipt_long_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: activeOrderCount > 0,
                label: Text('$activeOrderCount'),
                backgroundColor: context.foodie.primary,
                textColor: context.foodie.onPrimary,
                child: const Icon(Icons.receipt_long_rounded),
              ),
              label: const Text('Orders'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: Text('Favorites'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
