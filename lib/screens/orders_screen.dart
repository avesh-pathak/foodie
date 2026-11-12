import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../models/food_item.dart';
import '../models/order.dart';
import '../models/restaurant.dart';
import '../state/foodie_app_state.dart';
import '../state/foodie_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/foodie_image.dart';
import '../widgets/foodie_page_route.dart';
import 'cart_screen.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _showHistory = false;

  void _reorder(FoodOrder order) {
    final FoodieAppState state = FoodieScope.of(context);
    final int added = state.reorder(order);
    if (added == 0) {
      showFoodieSnack(context, 'Those dishes are no longer on the menu.');
      return;
    }
    HapticFeedback.mediumImpact();
    showFoodieSnack(context, '$added items added to your cart');
    Navigator.of(context).push(
      FoodiePageRoute<void>(page: const CartScreen()),
    );
  }

  void _openTracking(FoodOrder order) {
    Navigator.of(context).push(
      FoodiePageRoute<void>(
        page: OrderTrackingScreen(orderId: order.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FoodieAppState state = FoodieScope.of(context);
    final List<FoodOrder> orders =
        _showHistory ? state.pastOrders : state.activeOrders;
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'YOUR ORDERS',
                            style: context.foodieType.eyebrow,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'From kitchen to couch.',
                            style: context.foodieType.h1.copyWith(fontSize: 26),
                          ),
                        ],
                      ),
                    ),
                    if (state.activeOrders.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.foodie.infoSoft,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
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
                              '${state.activeOrders.length} live',
                              style: context.foodieType.label.copyWith(
                                fontSize: 9,
                                color: context.foodie.infoInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _OrderSegmentedButton(
                  showHistory: _showHistory,
                  activeCount: state.activeOrders.length,
                  historyCount: state.pastOrders.length,
                  onChanged: (bool value) => setState(() => _showHistory = value),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: orders.isEmpty
                      ? SingleChildScrollView(
                          key: ValueKey<bool>(_showHistory),
                          padding: const EdgeInsets.only(bottom: 118),
                          child: EmptyState(
                            icon: _showHistory
                                ? Icons.history_rounded
                                : Icons.delivery_dining_rounded,
                            title: _showHistory
                                ? 'No past orders yet'
                                : 'No active orders',
                            message: _showHistory
                                ? 'Once an order is delivered, it will move here. You can then view it or reorder in a tap.'
                                : 'You are all caught up. Find a kitchen you love and we will bring the food to you.',
                            buttonLabel: 'Explore restaurants',
                            onPressed: () => widget.onSelectTab(0),
                          ),
                        )
                      : ListView.separated(
                          key: ValueKey<bool>(_showHistory),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 118),
                          itemCount: orders.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) {
                            final FoodOrder order = orders[index];
                            return _showHistory
                                ? _HistoryOrderCard(
                                    order: order,
                                    onTap: () => _openTracking(order),
                                    onReorder: () => _reorder(order),
                                  )
                                : _ActiveOrderCard(
                                    order: order,
                                    onTap: () => _openTracking(order),
                                  );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSegmentedButton extends StatelessWidget {
  const _OrderSegmentedButton({
    required this.showHistory,
    required this.activeCount,
    required this.historyCount,
    required this.onChanged,
  });

  final bool showHistory;
  final int activeCount;
  final int historyCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<bool>(
        segments: <ButtonSegment<bool>>[
          ButtonSegment<bool>(
            value: false,
            label: const Text('Active'),
            icon: Badge(
              isLabelVisible: activeCount > 0,
              label: Text('$activeCount'),
              backgroundColor: context.foodie.primary,
              textColor: context.foodie.onPrimary,
              child: const Icon(Icons.bolt_rounded, size: 17),
            ),
          ),
          ButtonSegment<bool>(
            value: true,
            label: const Text('History'),
            icon: Badge(
              isLabelVisible: historyCount > 0,
              label: Text('$historyCount'),
              backgroundColor: context.foodie.primary,
              textColor: context.foodie.onPrimary,
              child: const Icon(Icons.history_rounded, size: 17),
            ),
          ),
        ],
        selected: <bool>{showHistory},
        showSelectedIcon: false,
        onSelectionChanged: (Set<bool> values) => onChanged(values.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            return states.contains(WidgetState.selected)
                ? context.foodie.primarySoft
                : context.foodie.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            return states.contains(WidgetState.selected)
                ? context.foodie.primaryInk
                : context.foodie.muted;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: context.foodie.borderStrong),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
          textStyle: WidgetStatePropertyAll(
            context.foodieType.label.copyWith(fontSize: 11.5),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          ),
        ),
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order, required this.onTap});

  final FoodOrder order;
  final VoidCallback onTap;

  List<String> get _kitchens {
    final Set<String> names = <String>{};
    for (final OrderLine line in order.lines) {
      final FoodItem? item = MockData.dishById(line.foodId);
      final Restaurant? restaurant =
          MockData.restaurantById(item?.restaurantId ?? '');
      if (restaurant != null) names.add(restaurant.name);
    }
    return names.toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool onTheWay = order.statusIndex >= 4;
    final OrderPhase phase = _orderPhaseFor(order.statusIndex);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.foodie.phaseSoft(phase),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: context.foodie.phaseFill(phase),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          onTheWay ? 'ON THE WAY' : 'IN PROGRESS',
                          style: context.foodieType.label.copyWith(
                            fontSize: 7.5,
                            letterSpacing: 0.6,
                            color: context.foodie.phaseInk(phase),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${order.etaMinutes - order.statusIndex * 4 <= 0 ? 1 : order.etaMinutes - order.statusIndex * 4} min away',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: context.foodieType.label.copyWith(
                        fontSize: 9,
                        color: context.foodie.phaseInk(phase),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _OrderImageStack(lines: order.lines),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _kitchens.join(' + '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.foodieType.h3.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          order.lines
                              .map((OrderLine line) =>
                                  '${line.quantity}× ${line.name}')
                              .join(', '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.foodieType.small.copyWith(
                            fontSize: 10.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          children: <Widget>[
                            Text(
                              orderStatuses[order.statusIndex],
                              style: context.foodieType.label.copyWith(
                                fontSize: 9,
                                color: context.foodie.phaseInk(phase),
                              ),
                            ),
                            Text(
                              '?  ${currency(order.total)}',
                              style: context.foodieType.label.copyWith(
                                fontSize: 9,
                                color: context.foodie.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: (order.statusIndex + 1) / orderStatuses.length,
                  minHeight: 5,
                  backgroundColor: context.foodie.surfaceMuted,
                  color: context.foodie.phaseFill(phase),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Order ${order.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.small.copyWith(fontSize: 8.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Track order',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.foodieType.label.copyWith(
                        fontSize: 10,
                        color: context.foodie.primaryInk,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: context.foodie.primaryInk,
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

class _HistoryOrderCard extends StatelessWidget {
  const _HistoryOrderCard({
    required this.order,
    required this.onTap,
    required this.onReorder,
  });

  final FoodOrder order;
  final VoidCallback onTap;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final String itemSummary = order.lines
        .map((OrderLine line) => '${line.quantity}× ${line.name}')
        .join(', ');
    final OrderPhase phase = _orderPhaseFor(order.statusIndex);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.foodie.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.foodie.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.foodie.phaseSoft(phase),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'DELIVERED',
                      style: context.foodieType.label.copyWith(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: context.foodie.phaseInk(phase),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      formatDate(order.placedAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: context.foodieType.small.copyWith(fontSize: 9.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  _OrderImageStack(lines: order.lines, size: 50),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          itemSummary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.foodieType.h3.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${order.itemCount} items • ${currency(order.total)}',
                          style: context.foodieType.small.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: context.foodie.subtle,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReorder,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        side: BorderSide(color: context.foodie.borderStrong),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.replay_rounded, size: 16),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Reorder',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 42),
                      ),
                      child: const Text(
                        'View details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

class _OrderImageStack extends StatelessWidget {
  const _OrderImageStack({required this.lines, this.size = 64});

  final List<OrderLine> lines;
  final double size;

  @override
  Widget build(BuildContext context) {
    final List<OrderLine> images = lines.take(2).toList();
    return SizedBox(
      width: size + (images.length > 1 ? 14 : 0),
      height: size,
      child: Stack(
        children: <Widget>[
          for (int i = 0; i < images.length; i++)
            Positioned(
              left: i * 14,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: context.foodie.surface, width: 2),
                ),
                child: FoodieImage(
                  asset: images[i].image,
                  width: size,
                  height: size,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Maps a delivery status index onto its semantic journey phase so every
/// status badge speaks the same colour language.
///
/// Mirrors the shared `phaseForStatusIndex` helper: queued up to index 1,
/// preparing up to index 3, moving at index 4, delivered after that.
OrderPhase _orderPhaseFor(int statusIndex) {
  if (statusIndex <= 1) return OrderPhase.queued;
  if (statusIndex <= 3) return OrderPhase.preparing;
  if (statusIndex == 4) return OrderPhase.moving;
  return OrderPhase.delivered;
}
