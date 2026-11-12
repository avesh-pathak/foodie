import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/foodie_page_route.dart';
import 'addresses_screen.dart';
import 'login_screen.dart';
import 'offers_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  Future<void> _editProfile(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => const _EditProfileSheet(),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Log out of Foodie?'),
        content: const Text(
          'Your cart, orders and favourites from this demo session will be reset.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    FoodieScope.of(context).logout();
    Navigator.of(context).pushAndRemoveUntil(
      FoodiePageRoute<void>(page: const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 118),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'YOUR SPACE',
                          style: context.foodieType.eyebrow,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Profile.',
                          style: context.foodieType.h1.copyWith(fontSize: 26),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.foodie.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: context.foodie.border),
                    ),
                    child: IconButton(
                      onPressed: () => _editProfile(context),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 19,
                        color: context.foodie.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      context.foodie.panelDark,
                      Color.lerp(
                        context.foodie.panelDark,
                        context.foodie.primary,
                        0.22,
                      )!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.floating,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/promo_food.jpg'),
                    fit: BoxFit.cover,
                    opacity: 0.12,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: context.foodie.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            state.avatarInitials,
                            style: context.foodieType.h2.copyWith(
                              color: context.foodie.onPrimary,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                state.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.foodieType.h2.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.contact,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.foodieType.small.copyWith(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: Text(
                                  'FOODIE MEMBER',
                                  style: context.foodieType.label.copyWith(
                                    fontSize: 7,
                                    letterSpacing: 0.5,
                                    color: Colors.white.withValues(alpha: 0.88),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _editProfile(context),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.12),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(36, 36),
                          ),
                          icon: const Icon(Icons.edit_rounded, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: context.foodie.overlayDark.withValues(
                          alpha: 0.55,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          _ProfileStat(
                            value: '${state.orders.length}',
                            label: 'Orders',
                          ),
                          _StatDivider(),
                          _ProfileStat(
                            value:
                                '${state.favoriteRestaurants.length + state.favoriteDishes.length}',
                            label: 'Favourites',
                          ),
                          _StatDivider(),
                          _ProfileStat(
                            value: '${state.addresses.length}',
                            label: 'Addresses',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  FoodiePageRoute<void>(page: const OffersScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        context.foodie.goldSoft,
                        context.foodie.goldSoft,
                        context.foodie.gold,
                      ],
                      stops: <double>[0, 0.82, 1],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: context.foodie.goldDeep,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: context.foodie.gold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Foodie Gold',
                              style: context.foodieType.h3.copyWith(
                                fontSize: 14,
                                color: context.foodie.goldInk,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Free delivery above ₹199 • Extra 5% off',
                              style: context.foodieType.small.copyWith(
                                fontSize: 10.5,
                                color: context.foodie.goldInk.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 19,
                        color: context.foodie.goldInk,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text('Your account', style: context.foodieType.h3),
              const SizedBox(height: 9),
              _MenuGroup(
                children: <Widget>[
                  _MenuTile(
                    icon: Icons.location_on_outlined,
                    title: 'Saved addresses',
                    subtitle: '${state.addresses.length} delivery locations',
                    role: _MenuRole.info,
                    onTap: () => Navigator.of(context).push(
                      FoodiePageRoute<void>(page: const AddressesScreen()),
                    ),
                  ),
                  _MenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'My orders',
                    subtitle: state.activeOrders.isEmpty
                        ? '${state.pastOrders.length} past orders'
                        : '${state.activeOrders.length} live • ${state.pastOrders.length} past',
                    role: _MenuRole.brand,
                    onTap: () => onSelectTab(2),
                  ),
                  _MenuTile(
                    icon: Icons.favorite_border_rounded,
                    title: 'Favourites',
                    subtitle:
                        '${state.favoriteRestaurants.length + state.favoriteDishes.length} saved items',
                    role: _MenuRole.brand,
                    onTap: () => onSelectTab(3),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('More from Foodie', style: context.foodieType.h3),
              const SizedBox(height: 9),
              _MenuGroup(
                children: <Widget>[
                  _MenuTile(
                    icon: Icons.local_offer_outlined,
                    title: 'Offers & coupons',
                    subtitle: 'Fresh deals, every day',
                    role: _MenuRole.gold,
                    onTap: () => Navigator.of(context).push(
                      FoodiePageRoute<void>(page: const OffersScreen()),
                    ),
                  ),
                  _MenuTile(
                    icon: Icons.support_agent_rounded,
                    title: 'Help & support',
                    subtitle: 'Chat with us or browse FAQs',
                    role: _MenuRole.info,
                    onTap: () => Navigator.of(context).push(
                      FoodiePageRoute<void>(page: const SupportScreen()),
                    ),
                  ),
                  _MenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'Notifications, demo data & more',
                    role: _MenuRole.neutral,
                    onTap: () => Navigator.of(context).push(
                      FoodiePageRoute<void>(page: const SettingsScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _MenuGroup(
                children: <Widget>[
                  _MenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Log out',
                    subtitle: 'Return to the login screen',
                    role: _MenuRole.danger,
                    destructive: true,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      'Foodie 1.0.0  •  Made for hungry people',
                      style: context.foodieType.small.copyWith(
                        fontSize: 9.5,
                        color: context.foodie.subtle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Demo app — no real accounts, orders or payments.',
                      style: context.foodieType.small.copyWith(
                        fontSize: 8.5,
                        color: context.foodie.subtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: context.foodieType.h2.copyWith(
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: context.foodieType.small.copyWith(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
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
          for (int i = 0; i < children.length; i++) ...<Widget>[
            children[i],
            if (i < children.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 62),
                child: Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }
}

/// Semantic role of a menu row. Each role owns one tinted icon well so a
/// row reads as a category without shouting.
enum _MenuRole { info, brand, gold, neutral, danger }

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.role = _MenuRole.brand,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final _MenuRole role;
  final bool destructive;

  Color _wellFill(FoodiePalette palette) {
    switch (role) {
      case _MenuRole.info:
        return palette.infoSoft;
      case _MenuRole.brand:
        return palette.primarySoft;
      case _MenuRole.gold:
        return palette.goldSoft;
      case _MenuRole.neutral:
        return palette.surfaceMuted;
      case _MenuRole.danger:
        return palette.dangerSoft;
    }
  }

  Color _wellInk(FoodiePalette palette) {
    switch (role) {
      case _MenuRole.info:
        return palette.infoInk;
      case _MenuRole.brand:
        return palette.primaryInk;
      case _MenuRole.gold:
        return palette.goldInk;
      case _MenuRole.neutral:
        return palette.muted;
      case _MenuRole.danger:
        return palette.dangerInk;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FoodiePalette palette = context.foodie;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      minVerticalPadding: 10,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _wellFill(palette),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 18, color: _wellInk(palette)),
      ),
      title: Text(
        title,
        style: context.foodieType.body.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: destructive ? palette.danger : palette.inkStrong,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.foodieType.small.copyWith(fontSize: 10),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 19,
        color: destructive ? palette.danger : palette.subtle,
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final FoodieAppState state = FoodieScope.read(context);
    _nameController = TextEditingController(text: state.displayName);
    _contactController = TextEditingController(text: state.contact);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FoodieScope.of(context).updateProfile(
      name: _nameController.text,
      contact: _contactController.text,
    );
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        2,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 22,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Edit profile', style: context.foodieType.h2),
              const SizedBox(height: 6),
              Text(
                'Your name is used for greetings across the app.',
                style: context.foodieType.bodyMuted,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Your name cannot be empty.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Phone or email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Add a phone or email for your profile.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
