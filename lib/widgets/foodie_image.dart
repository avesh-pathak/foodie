import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FoodieImage extends StatelessWidget {
  const FoodieImage({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.restaurant_rounded,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  Widget _fallback(BuildContext context, Object error, StackTrace? stack) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[context.foodie.primarySoft, context.foodie.surfaceWarm],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(fallbackIcon, color: context.foodie.primaryInk, size: 36),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = asset.startsWith('http')
        ? Image.network(
            asset,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (BuildContext context, Object error, StackTrace? stack) => _fallback(context, error, stack),
          )
        : Image.asset(
            asset,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (BuildContext context, Object error, StackTrace? stack) => _fallback(context, error, stack),
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}