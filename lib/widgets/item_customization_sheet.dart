import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/food_item.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'foodie_image.dart';
import 'quantity_stepper.dart';
import 'veg_badge.dart';

Future<void> showItemCustomization(
  BuildContext context,
  FoodItem item,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) => ItemCustomizationSheet(item: item),
  );
}

class ItemCustomizationSheet extends StatefulWidget {
  const ItemCustomizationSheet({
    super.key,
    required this.item,
  });

  final FoodItem item;

  @override
  State<ItemCustomizationSheet> createState() => _ItemCustomizationSheetState();
}

class _ItemCustomizationSheetState extends State<ItemCustomizationSheet> {
  /// Size of the add-on tick box.
  static const double _tickBoxSize = 20;

  final Set<AddOn> _selectedAddOns = <AddOn>{};
  final TextEditingController _noteController = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double get _unitPrice =>
      widget.item.price +
      _selectedAddOns.fold<double>(0, (sum, addOn) => sum + addOn.price);

  double get _total => _unitPrice * _quantity;

  void _addToCart() {
    FoodieScope.of(context).addToCart(
      widget.item,
      quantity: _quantity,
      addOns: _selectedAddOns.toList(),
      note: _noteController.text.trim(),
    );
    HapticFeedback.mediumImpact();
    showFoodieSnack(
      context,
      '${widget.item.name} added to your cart',
      icon: Icons.shopping_bag_outlined,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FoodieImage(
                  asset: widget.item.image,
                  width: 94,
                  height: 94,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          VegBadge(isVeg: widget.item.isVeg),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.item.category.toUpperCase(),
                              style: context.foodieType.label.copyWith(
                                color: context.foodie.primaryInk,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.item.name,
                        style: context.foodieType.h2.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.foodieType.small,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Text(
                  currency(widget.item.price),
                  style: context.foodieType.price.copyWith(fontSize: 19),
                ),
                const Spacer(),
                QuantityStepper(
                  quantity: _quantity,
                  minimum: 0,
                  onIncrement: () => setState(() => _quantity++),
                  onDecrement: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                ),
              ],
            ),
            if (widget.item.addOns.isNotEmpty) ...<Widget>[
              const SizedBox(height: 24),
              Text('Make it yours', style: context.foodieType.h3),
              const SizedBox(height: 10),
              ...widget.item.addOns.map((AddOn addOn) {
                final bool selected = _selectedAddOns.contains(addOn);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: selected
                        ? context.foodie.primarySoft
                        : context.foodie.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (!_selectedAddOns.add(addOn)) {
                            _selectedAddOns.remove(addOn);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: selected
                                ? context.foodie.primary
                                : context.foodie.border,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: _tickBoxSize,
                              height: _tickBoxSize,
                              decoration: BoxDecoration(
                                color: selected
                                    ? context.foodie.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  _tickBoxSize * 0.3,
                                ),
                                border: Border.all(
                                  color: selected
                                      ? context.foodie.primary
                                      : context.foodie.subtle,
                                  width: 1.5,
                                ),
                              ),
                              child: selected
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: context.foodie.onPrimary,
                                      size: 14,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                addOn.name,
                                style: context.foodieType.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              addOn.price == 0
                                  ? 'Free'
                                  : '+ ${currency(addOn.price)}',
                              style: context.foodieType.small.copyWith(
                                color: context.foodie.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 20),
            Text(
              'Anything special?',
              style: context.foodieType.h3.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Less spicy, extra napkins, no onions…',
                counterText: '',
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: widget.item.isAvailable ? _addToCart : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(widget.item.isAvailable
                        ? 'Add $_quantity to cart'
                        : 'Sold out'),
                    Text(currency(_total)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
