import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedBackground extends StatelessWidget {
  final String condition;
  final bool isDay;

  const AnimatedBackground({
    super.key,
    required this.condition,
    required this.isDay,
  });

  List<Color> _getGradientColors() {
    final lowercaseCondition = condition.toLowerCase();
    
    if (isDay) {
      switch (lowercaseCondition) {
        case 'clear':
          return [
            const Color(0xFF7CB9E8),  // Sky blue
            const Color(0xFF00B4D8),  // Deep sky blue
          ];
        case 'clouds':
          return [
            const Color(0xFF94A3B8),  // Cool gray
            const Color(0xFF475569),  // Slate
          ];
        case 'rain':
          return [
            const Color(0xFF1E293B),  // Dark blue gray
            const Color(0xFF0F172A),  // Darker blue
          ];
        case 'thunderstorm':
          return [
            const Color(0xFF312E81),  // Indigo
            const Color(0xFF1E1B4B),  // Dark indigo
          ];
        default:
          return [
            const Color(0xFF7CB9E8),
            const Color(0xFF00B4D8),
          ];
      }
    } else {
      // Night colors
      switch (lowercaseCondition) {
        case 'clear':
          return [
            const Color(0xFF1E293B),  // Dark blue gray
            const Color(0xFF0F172A),  // Darker blue
          ];
        case 'clouds':
          return [
            const Color(0xFF1F2937),  // Dark gray
            const Color(0xFF111827),  // Darker gray
          ];
        case 'rain':
          return [
            const Color(0xFF0F172A),  // Very dark blue
            const Color(0xFF020617),  // Almost black
          ];
        case 'thunderstorm':
          return [
            const Color(0xFF1E1B4B),  // Dark indigo
            const Color(0xFF0F172A),  // Dark blue
          ];
        default:
          return [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated gradient background
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getGradientColors(),
            ),
          ),
        ),

        // Animated overlay patterns
        Opacity(
          opacity: 0.1,
          child: _AnimatedPatterns(
            condition: condition,
            isDay: isDay,
          ),
        ),

        // Subtle color overlay for depth
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.black.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedPatterns extends StatelessWidget {
  final String condition;
  final bool isDay;

  const _AnimatedPatterns({
    required this.condition,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
        20,
        (index) => Positioned(
          left: math.Random().nextDouble() * MediaQuery.of(context).size.width,
          top: math.Random().nextDouble() * MediaQuery.of(context).size.height,
          child: _buildAnimatedPattern(index),
        ),
      ),
    );
  }

  Widget _buildAnimatedPattern(int index) {
    final size = math.Random().nextDouble() * 30 + 10;
    final lowercaseCondition = condition.toLowerCase();

    Widget pattern;
    if (lowercaseCondition.contains('rain')) {
      pattern = _RainDrop(size: size);
    } else if (lowercaseCondition.contains('snow')) {
      pattern = _Snowflake(size: size);
    } else if (lowercaseCondition.contains('cloud')) {
      pattern = _Cloud(size: size);
    } else {
      pattern = _Star(size: size);
    }

    return pattern.animate(
      onPlay: (controller) => controller.repeat(),
    ).moveY(
      duration: Duration(milliseconds: 2000 + index * 500),
      begin: -50,
      end: 50,
    ).fadeIn(duration: const Duration(milliseconds: 500));
  }
}

class _RainDrop extends StatelessWidget {
  final double size;

  const _RainDrop({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size / 4,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

class _Snowflake extends StatelessWidget {
  final double size;

  const _Snowflake({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  final double size;

  const _Cloud({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.5,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  final double size;

  const _Star({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size / 2,
      height: size / 2,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
} 