import 'package:flutter/material.dart';

import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/foodie_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _reset(
    BuildContext context,
    FoodieAppState state,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Reset demo data?'),
        content: const Text(
          'This clears your cart, favourites, search history, saved addresses and orders for this session. You will stay logged in.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.foodie.danger,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    state.resetDemoData();
    if (context.mounted) {
      showFoodieSnack(
        context,
        'Demo data reset. Fresh start!',
        icon: Icons.restart_alt_rounded,
      );
    }
  }

  String _themeSubtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follows your device';
      case ThemeMode.light:
        return 'Red on white';
      case ThemeMode.dark:
        return 'Red on black';
    }
  }

  void _showThemePicker(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: RadioGroup<ThemeMode>(
            groupValue: state.themeMode,
            onChanged: (ThemeMode? mode) {
              if (mode == null) return;
              state.setThemeMode(mode);
              Navigator.of(sheetContext).pop();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Appearance', style: sheetContext.foodieType.h2),
                const SizedBox(height: 14),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: const Text('System'),
                  subtitle: const Text('Follows your device setting'),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: const Text('Light'),
                  subtitle: const Text('Red on white'),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: const Text('Dark'),
                  subtitle: const Text('Red on black'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Row(
          children: <Widget>[
            FoodieLogo(size: 34, showWordmark: false),
            SizedBox(width: 10),
            Text('About Foodie'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Foodie is a polished restaurant customer app demo built entirely with Flutter and local mock data.',
              style: context.foodieType.bodyMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'Version 1.0.0\nNo backend • No real payments • No tracking',
              style: context.foodieType.small,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Privacy in this demo'),
        content: Text(
          'Foodie runs entirely on your device. Names, addresses, cart items and orders are kept in memory only and are lost when the app closes. No analytics, APIs or external services are used.',
          style: context.foodieType.bodyMuted,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    return Scaffold(
      backgroundColor: context.foodie.background,
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: <Widget>[
                Text('Preferences', style: context.foodieType.h3),
                const SizedBox(height: 9),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: context.foodie.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: BorderSide(color: context.foodie.border),
                  ),
                  child: Column(
                    children: <Widget>[
                      SwitchListTile(
                        value: state.notificationsEnabled,
                        onChanged: state.setNotificationsEnabled,
                        secondary: const _SettingIcon(
                          icon: Icons.notifications_none_rounded,
                        ),
                        title: const Text('Order updates'),
                        subtitle: const Text(
                          'A simulated nudge when your order moves.',
                        ),
                      ),
                      const Divider(height: 1, indent: 62),
                      SwitchListTile(
                        value: state.offersEnabled,
                        onChanged: state.setOffersEnabled,
                        secondary: const _SettingIcon(
                          icon: Icons.local_offer_outlined,
                        ),
                        title: const Text('Offers & promos'),
                        subtitle: const Text(
                          'Show personalised deals in the app.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('App', style: context.foodieType.h3),
                const SizedBox(height: 9),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: context.foodie.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: BorderSide(color: context.foodie.border),
                  ),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        onTap: () => _showThemePicker(context),
                        leading: const _SettingIcon(
                          icon: Icons.palette_outlined,
                        ),
                        title: const Text('Appearance'),
                        subtitle: Text(_themeSubtitle(state.themeMode)),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: context.foodie.subtle,
                          size: 20,
                        ),
                      ),
                      const Divider(height: 1, indent: 62),
                      ListTile(
                        onTap: () => _showPrivacy(context),
                        leading: const _SettingIcon(
                          icon: Icons.privacy_tip_outlined,
                        ),
                        title: const Text('Privacy'),
                        subtitle: const Text('How this demo handles your data'),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: context.foodie.subtle,
                          size: 20,
                        ),
                      ),
                      const Divider(height: 1, indent: 62),
                      ListTile(
                        onTap: () => _showAbout(context),
                        leading: const _SettingIcon(
                          icon: Icons.info_outline_rounded,
                        ),
                        title: const Text('About Foodie'),
                        subtitle: const Text('Version 1.0.0'),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: context.foodie.subtle,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Demo data', style: context.foodieType.h3),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.foodie.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.foodie.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Everything you see is stored in memory. Resetting gives you a clean slate without logging you out.',
                        style: context.foodieType.small.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: () => _reset(context, state),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.foodie.danger,
                            side: BorderSide(
                              color: context.foodie.danger,
                              width: 1.4,
                            ),
                          ),
                          icon: const Icon(Icons.restart_alt_rounded, size: 18),
                          label: const Text('Reset demo data'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Foodie 1.0.0 • Built with Flutter',
                    style: context.foodieType.small.copyWith(
                      fontSize: 9.5,
                      color: context.foodie.subtle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.foodie.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, size: 18, color: context.foodie.primaryInk),
    );
  }
}
