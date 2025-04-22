import 'package:flutter/material.dart';

class AppConstants {
  // Durations
  static const normalDuration = Duration(milliseconds: 300);
  static const longDuration = Duration(milliseconds: 500);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Glass effect
  static const double glassOpacity = 0.15;
  static const double glassSigma = 10.0;

  // Weather
  static const String weatherApiKey = 'YOUR_API_KEY_HERE';
  static const String weatherApiBaseUrl = 'https://api.weatherapi.com/v1';
  static const String weatherApiCurrentEndpoint = '/current.json';
  static const String weatherApiForecastEndpoint = '/forecast.json';

  // Animation Durations
  static const Duration quickAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 800);

  // Glassmorphism
  static const double glassBlur = 10.0;
  static const double glassBorder = 1.0;
  
  static LinearGradient get glassGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.1),
      Colors.white.withOpacity(0.05),
    ],
  );

  static LinearGradient get glassBorderGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.2),
      Colors.white.withOpacity(0.1),
    ],
  );

  // Weather Gradients
  static LinearGradient getDayGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF1B4DE4),
            Color(0xFF2B5EFF),
          ],
        );
      case 'clouds':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF636E72),
            Color(0xFF838E92),
          ],
        );
      case 'thunderstorm':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF2C3E50),
            Color(0xFF3D5A80),
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF4A90E2),
            Color(0xFF87CEEB),
          ],
        );
    }
  }

  static LinearGradient getNightGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF0D1B2A),
            Color(0xFF1B263B),
          ],
        );
      case 'clouds':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF2D3436),
            Color(0xFF636E72),
          ],
        );
      case 'thunderstorm':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF1A1A2E),
            Color(0xFF2D3436),
          ],
        );
    }
  }
} 