class WeatherUtils {
  static String getWeatherMessage(String? condition, double? temp) {
    if (condition == null || temp == null) return '';
    
    condition = condition.toLowerCase();
    if (condition.contains('rain')) {
      return 'Don\'t forget your umbrella!';
    } else if (condition.contains('snow')) {
      return 'Bundle up, it\'s snowing!';
    } else if (condition.contains('clear') && temp > 25) {
      return 'Perfect day for outdoor activities!';
    } else if (condition.contains('cloud')) {
      return 'Mild conditions today';
    } else if (temp < 10) {
      return 'Bundle up, it\'s cold outside!';
    } else if (temp > 30) {
      return 'Stay hydrated, it\'s hot!';
    }
    return 'Have a great day!';
  }

  static String getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static bool isDayTime() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }

  static String getWindDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  static String getHumidityLevel(int humidity) {
    if (humidity < 30) return 'Low';
    if (humidity < 60) return 'Moderate';
    if (humidity < 80) return 'High';
    return 'Very High';
  }

  static String getVisibilityDescription(int meters) {
    final km = meters / 1000;
    if (km < 1) return 'Poor';
    if (km < 4) return 'Moderate';
    if (km < 10) return 'Good';
    return 'Excellent';
  }

  static String formatTemperature(double temp) {
    return '${temp.round()}°';
  }

  static String getUserFriendlyError(String message) {
    message = message.toLowerCase();
    if (message.contains('404')) {
      return 'City not found. Try another location.';
    } else if (message.contains('timeout')) {
      return 'Connection timeout. Check your internet.';
    } else if (message.contains('permission')) {
      return 'Location access denied. Using default city.';
    } else if (message.contains('disabled')) {
      return 'Location services are disabled. Using default city.';
    }
    return 'Unable to get weather data. Please try again.';
  }
} 