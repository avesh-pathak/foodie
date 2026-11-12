import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FoodieBottomNav extends StatelessWidget {
  const FoodieBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.activeOrderCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int activeOrderCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.soft,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 70,
              backgroundColor: context.foodie.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              indicatorColor: context.foodie.primarySoft,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              labelTextStyle:
                  WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                final bool selected = states.contains(WidgetState.selected);
                return context.foodieType.label.copyWith(
                  fontSize: 9.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? context.foodie.primaryInk
                      : context.foodie.muted,
                );
              }),
              iconTheme:
                  WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                final bool selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  size: 22,
                  color: selected
                      ? context.foodie.primaryInk
                      : context.foodie.muted,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              destinations: <Widget>[
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  selectedIcon: Icon(Icons.search_rounded),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: _OrderIcon(
                    count: activeOrderCount,
                    icon: Icons.receipt_long_outlined,
                  ),
                  selectedIcon: _OrderIcon(
                    count: activeOrderCount,
                    icon: Icons.receipt_long_rounded,
                  ),
                  label: 'Orders',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Favorites',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderIcon extends StatelessWidget {
  const _OrderIcon({required this.count, required this.icon});

  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      backgroundColor: context.foodie.primary,
      textColor: context.foodie.onPrimary,
      child: Icon(icon),
    );
  }
}
