import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('9ca54d6dfc95316843118ec4da9e8a89');
  Weather? _weather;
  bool _isLoading = true;
  String _errorMessage = '';
  String _currentCity = 'New York';
  bool _showDetails = false;

  Future<void> _fetchWeather() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        _currentCity = await _weatherService.getCurrentCity()
            .timeout(const Duration(seconds: 5), onTimeout: () => 'New York');
      } catch (e) {
        _currentCity = 'New York';
        debugPrint('Location fallback: $e');
      }

      final weather = await _weatherService.getWeather(_currentCity);
      
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = _getUserFriendlyError(e);
        _isLoading = false;
      });
      debugPrint('Weather fetch error: $e');
    }
  }

  String _getUserFriendlyError(Exception e) {
    final message = e.toString();
    if (message.contains('404')) {
      return 'City not found. Try another location.';
    } else if (message.contains('Timeout')) {
      return 'Connection timeout. Check your internet.';
    } else if (message.contains('permission')) {
      return 'Location permission required';
    } else {
      return 'Failed to get weather data';
    }
  }

  bool isDayTime() {
    final now = DateTime.now();
    final hour = now.hour;
    return hour >= 6 && hour < 18;
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    final isDay = isDayTime();

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return isDay ? 'assets/sunny.json' : 'assets/night.json';
      default:
        return isDay ? 'assets/sunny.json' : 'assets/night.json';
    }
  }

  List<Color> _getGradientColors(String? condition) {
    condition = condition?.toLowerCase() ?? 'clear';
    final isDay = isDayTime();

    if (isDay) {
      switch (condition) {
        case 'rain':
          return [Colors.blue.shade800, Colors.blue.shade400];
        case 'clouds':
          return [Colors.grey.shade800, Colors.grey.shade600];
        case 'thunderstorm':
          return [Colors.indigo.shade900, Colors.blue.shade700];
        default:
          return [Colors.blue.shade800, Colors.blue.shade400];
      }
    } else {
      switch (condition) {
        case 'rain':
          return [Colors.blueGrey.shade900, Colors.blueGrey.shade600];
        case 'clouds':
          return [Colors.black, Colors.grey.shade900];
        case 'thunderstorm':
          return [Colors.indigo.shade900, Colors.black];
        default:
          return [Colors.black, Colors.blueGrey.shade900];
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _getGradientColors(_weather?.mainCondition),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.white.withOpacity(0.9), size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _currentCity.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              fontFamily: 'Roboto',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, color: Colors.white.withOpacity(0.8)),
                          onPressed: _fetchWeather,
                        ),
                      ],
                    ),
                  ),

                  // Main Weather Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Weather Animation
                        GestureDetector(
                          onTap: () => setState(() => _showDetails = !_showDetails),
                          child: Lottie.asset(
                            getWeatherAnimation(_weather?.mainCondition),
                            width: 180,
                            height: 180,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Temperature
                        Text(
                          '${_weather?.temperature.round()}°',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Weather Condition
                        Text(
                          _weather?.mainCondition ?? "",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Details Button or Details Section
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _showDetails
                              ? _buildWeatherDetails()
                              : _buildDetailsButton(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsButton() {
    return GestureDetector(
      onTap: () => setState(() => _showDetails = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Show Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Column(
      children: [
        _buildDetailRow(Icons.thermostat, 'Feels Like', '${_weather?.feelsLike?.round() ?? '--'}°'),
        const Divider(color: Colors.white30, height: 20),
        _buildDetailRow(Icons.water_drop, 'Humidity', '${_weather?.humidity ?? '--'}%'),
        const Divider(color: Colors.white30, height: 20),
        _buildDetailRow(Icons.air, 'Wind Speed', '${_weather?.windSpeed?.round() ?? '--'} km/h'),
        const Divider(color: Colors.white30, height: 20),
        _buildDetailRow(Icons.visibility, 'Visibility', '${(_weather?.visibility ?? 0) ~/ 1000} km'),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => setState(() => _showDetails = false),
          child: Text(
            'Hide Details',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
          const SizedBox(width: 15),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontFamily: 'Roboto',
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}