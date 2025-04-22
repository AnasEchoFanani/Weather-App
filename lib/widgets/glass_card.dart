import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/constants.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final double? opacity;
  final double? sigma;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.opacity,
    this.sigma,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.radiusL),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: sigma ?? AppConstants.glassSigma,
          sigmaY: sigma ?? AppConstants.glassSigma,
        ),
        child: Container(
          padding: padding ?? EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white)
                .withOpacity(opacity ?? AppConstants.glassOpacity),
            borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.radiusL),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
} 