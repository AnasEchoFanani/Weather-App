import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/config/constants.dart';

class AnimatedWeatherIcon extends StatelessWidget {
  final String condition;
  final double size;
  final bool isDay;
  final VoidCallback? onTap;

  const AnimatedWeatherIcon({
    super.key,
    required this.condition,
    this.size = 220,
    required this.isDay,
    this.onTap,
  });

  String _getAnimationAsset() {
    final lowercaseCondition = condition.toLowerCase();
    
    if (lowercaseCondition.contains('cloud') ||
        lowercaseCondition.contains('mist') ||
        lowercaseCondition.contains('fog') ||
        lowercaseCondition.contains('haze') ||
        lowercaseCondition.contains('dust') ||
        lowercaseCondition.contains('smoke')) {
      return 'assets/cloud.json';
    }
    
    if (lowercaseCondition.contains('rain') ||
        lowercaseCondition.contains('drizzle')) {
      return 'assets/rain.json';
    }
    
    if (lowercaseCondition.contains('thunder')) {
      return 'assets/thunder.json';
    }
    
    if (lowercaseCondition.contains('snow')) {
      return 'assets/snow.json';
    }
    
    return isDay ? 'assets/sunny.json' : 'assets/night.json';
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'weather_animation',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: AppConstants.normalAnimation,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: GestureDetector(
                onTap: onTap,
                child: Lottie.asset(
                  _getAnimationAsset(),
                  width: size,
                  height: size,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 