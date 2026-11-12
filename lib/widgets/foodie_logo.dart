import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FoodieLogo extends StatelessWidget {
  const FoodieLogo({
    super.key,
    this.size = 44,
    this.showWordmark = true,
    this.light = false,
  });

  final double size;
  final bool showWordmark;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            // Deep orange anchors the tile so the mark stays legible
            // (5.21:1); the vivid end of the ramp keeps it brand-bright.
            gradient: LinearGradient(
              colors: <Color>[
                context.foodie.primary,
                context.foodie.primaryLift,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.34),
            boxShadow: AppShadows.soft,
          ),
          child: Icon(
            Icons.ramen_dining_rounded,
            size: size * 0.56,
            color: context.foodie.onPrimary,
          ),
        ),
        if (showWordmark) ...<Widget>[
          SizedBox(width: size * 0.28),
          Flexible(
            child: Text(
              'Foodie',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FoodieType.displayFamily,
                fontSize: size * 0.66,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                color: light ? Colors.white : context.foodie.inkStrong,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
