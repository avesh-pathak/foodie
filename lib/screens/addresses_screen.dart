import 'package:flutter/material.dart';

import '../models/delivery_address.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/address_widgets.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  Future<void> _delete(
    BuildContext context,
    FoodieAppState state,
    DeliveryAddress address,
  ) async {
    if (state.addresses.length <= 1) {
      showFoodieSnack(
        context,
        'Keep at least one address for deliveries.',
        icon: Icons.info_outline_rounded,
      );
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete this address?'),
        content: Text(
          '${address.label} • ${address.oneLine} will be removed from your saved addresses.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      state.deleteAddress(address.id);
      if (context.mounted) {
        showFoodieSnack(context, 'Address removed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    return Scaffold(
      backgroundColor: context.foodie.background,
      appBar: AppBar(title: const Text('Saved addresses')),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              children: <Widget>[
                Text(
                  'Where should we deliver?',
                  style: context.foodieType.h2.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 5),
                Text(
                  'Choose an address for this order, or update your saved locations.',
                  style: context.foodieType.bodyMuted,
                ),
                const SizedBox(height: 18),
                ...state.addresses.map(
                  (DeliveryAddress address) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AddressOption(
                      address: address,
                      selected: address.id == state.selectedAddress.id,
                      onTap: () {
                        state.setDeliveryAddress(address.id);
                        showFoodieSnack(context, 'Delivering to ${address.label}');
                      },
                      onEdit: () => showAddressForm(
                        context,
                        initial: address,
                      ),
                      onDelete: () => _delete(context, state, address),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => showAddressForm(context),
                    icon: const Icon(Icons.add_location_alt_outlined, size: 19),
                    label: const Text('Add a new address'),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.foodie.surfaceWarm,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.info_outline_rounded,
                        size: 17,
                        color: context.foodie.primaryInk,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'These addresses are mock data for the demo. Selecting one here updates your delivery address everywhere.',
                          style: context.foodieType.small.copyWith(
                            fontSize: 10.5,
                            color: context.foodie.ink,
                          ),
                        ),
                      ),
                    ],
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
