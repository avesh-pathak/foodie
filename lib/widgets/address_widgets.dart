import 'package:flutter/material.dart';

import '../models/delivery_address.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';

Future<void> showAddressForm(
  BuildContext context, {
  DeliveryAddress? initial,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) => AddressFormSheet(initial: initial),
  );
}

class AddressFormSheet extends StatefulWidget {
  const AddressFormSheet({super.key, this.initial});

  final DeliveryAddress? initial;

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late AddressType _type;
  bool _makeDefault = false;

  @override
  void initState() {
    super.initState();
    final DeliveryAddress? initial = widget.initial;
    _labelController = TextEditingController(text: initial?.label ?? 'Home');
    _line1Controller = TextEditingController(text: initial?.line1 ?? '');
    _line2Controller = TextEditingController(text: initial?.line2 ?? '');
    _type = initial?.type ?? AddressType.home;
    _makeDefault = initial?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final FoodieAppState state = FoodieScope.of(context);
    if (widget.initial == null) {
      state.addAddress(
        label: _labelController.text.trim(),
        line1: _line1Controller.text.trim(),
        line2: _line2Controller.text.trim(),
        type: _type,
        makeDefault: _makeDefault,
      );
    } else {
      state.updateAddress(
        widget.initial!.copyWith(
          label: _labelController.text.trim(),
          line1: _line1Controller.text.trim(),
          line2: _line2Controller.text.trim(),
          type: _type,
          isDefault: _makeDefault,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.initial == null ? 'Add a new address' : 'Edit address',
              style: context.foodieType.h2,
            ),
            const SizedBox(height: 6),
            Text(
              'We will use this to deliver your next delicious meal.',
              style: context.foodieType.bodyMuted,
            ),
            const SizedBox(height: 22),
            Text('Save as',
                style: context.foodieType.h3.copyWith(fontSize: 14)),
            const SizedBox(height: 9),
            Row(
              children: AddressType.values.map((AddressType type) {
                final bool selected = _type == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          type == AddressType.home
                              ? Icons.home_rounded
                              : type == AddressType.work
                                  ? Icons.work_rounded
                                  : Icons.place_rounded,
                          size: 15,
                          color: selected
                              ? context.foodie.onPrimary
                              : context.foodie.ink,
                        ),
                        const SizedBox(width: 5),
                        Text(type.label),
                      ],
                    ),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _type = type;
                        _labelController.text = type.label;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _line1Controller,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Flat / house / building',
                hintText: '12, Rosewood Residency',
                prefixIcon: Icon(Icons.apartment_rounded),
              ),
              validator: (String? value) {
                if (value == null || value.trim().length < 3) {
                  return 'Please enter your building or house details.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _line2Controller,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Street, area & pincode',
                hintText: '100 Feet Road, Bengaluru 560038',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
              validator: (String? value) {
                if (value == null || value.trim().length < 5) {
                  return 'Please enter the street and pincode.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _makeDefault,
              onChanged: (bool value) => setState(() => _makeDefault = value),
              title: Text(
                'Make this my default address',
                style: context.foodieType.body
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'We will select this address automatically at checkout.',
                style: context.foodieType.small,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  widget.initial == null ? 'Save address' : 'Update address',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressOption extends StatelessWidget {
  const AddressOption({
    super.key,
    required this.address,
    required this.selected,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final DeliveryAddress address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  IconData get _icon {
    switch (address.type) {
      case AddressType.home:
        return Icons.home_rounded;
      case AddressType.work:
        return Icons.work_rounded;
      case AddressType.other:
        return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                selected ? context.foodie.primarySoft : context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color:
                  selected ? context.foodie.primary : context.foodie.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? context.foodie.primary
                      : context.foodie.surfaceWarm,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  _icon,
                  size: 20,
                  color: selected
                      ? context.foodie.onPrimary
                      : context.foodie.primaryInk,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            address.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                context.foodieType.h3.copyWith(fontSize: 14.5),
                          ),
                        ),
                        if (address.isDefault) ...<Widget>[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? context.foodie.surface
                                  : context.foodie.primarySoft,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: context.foodieType.label.copyWith(
                                fontSize: 7.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: context.foodie.primaryInk,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.line1,
                      style: context.foodieType.body.copyWith(fontSize: 13),
                    ),
                    Text(
                      address.line2,
                      style: context.foodieType.small.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: context.foodie.primaryInk,
                    size: 20,
                  ),
                ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: context.foodie.muted,
                    size: 20,
                  ),
                  onSelected: (String value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit address'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete address'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
