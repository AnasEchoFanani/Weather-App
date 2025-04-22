import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with SingleTickerProviderStateMixin {
  final _weatherService = WeatherService('9ca54d6dfc95316843118ec4da9e8a89');
  Weather? _weather;
  bool _isLoading = true;
  String _errorMessage = '';
  String _currentCity = 'New York';
  bool _showDetails = false;
  late AnimationController _animationController;
  final _pageController = PageController();
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _pageController.addListener(_onPageChanged);
    
    _fetchWeather();
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page ?? 0;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Get the city name
      _currentCity = await _weatherService.getCurrentCity();
      
      // Get the weather
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
    final message = e.toString().toLowerCase();
    if (message.contains('404')) {
      return 'City not found. Try another location.';
    } else if (message.contains('timeout')) {
      return 'Connection timeout. Check your internet.';
    } else if (message.contains('permission')) {
      return 'Location access denied. Using default city.';
    } else if (message.contains('disabled')) {
      return 'Location services are disabled. Using default city.';
    } else {
      return 'Unable to get weather data. Please try again.';
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
          return [
            const Color(0xFF1B4DE4),
            const Color(0xFF2B5EFF),
          ];
        case 'clouds':
          return [
            const Color(0xFF636E72),
            const Color(0xFF838E92),
          ];
        case 'thunderstorm':
          return [
            const Color(0xFF2C3E50),
            const Color(0xFF3D5A80),
          ];
        default:
          return [
            const Color(0xFF4A90E2),
            const Color(0xFF87CEEB),
          ];
      }
    } else {
      switch (condition) {
        case 'rain':
          return [
            const Color(0xFF0D1B2A),
            const Color(0xFF1B263B),
          ];
        case 'clouds':
          return [
            const Color(0xFF2D3436),
            const Color(0xFF636E72),
          ];
        case 'thunderstorm':
          return [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ];
        default:
          return [
            const Color(0xFF1A1A2E),
            const Color(0xFF2D3436),
          ];
      }
    }
  }

  String _getWeatherMessage(String? condition, double? temp) {
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

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final weatherMessage = _getWeatherMessage(_weather?.mainCondition, _weather?.temperature);
    final isDay = isDayTime();
    
    return Scaffold(
      body: Stack(
        children: [
          // New animated background
          AnimatedBackground(
            condition: _weather?.mainCondition ?? 'clear',
            isDay: isDay,
          ),

          // Main content
          SafeArea(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index.toDouble();
                });
              },
              children: [
                _buildMainWeatherView(weatherMessage),
                _buildDetailedWeatherView(),
              ],
            ),
          ),

          // Modern page indicator
          if (_weather != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < 2; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            width: _currentPage.round() == i ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                _currentPage.round() == i ? 0.95 : 0.3,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading overlay with shimmer effect
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Shimmer.fromColors(
                      baseColor: Colors.white54,
                      highlightColor: Colors.white,
                      child: Text(
                        'Fetching weather data...',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error message with modern design
          if (_errorMessage.isNotEmpty)
            _buildErrorOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainWeatherView(String weatherMessage) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildGreeting()
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideX(begin: -30, end: 0),
            const SizedBox(height: 20),
            _buildLocationBar()
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideX(begin: 30, end: 0),
            const SizedBox(height: 40),
            Center(
              child: _buildWeatherAnimation()
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 800))
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
            ),
            const SizedBox(height: 20),
            Center(
              child: _buildTemperatureDisplay(weatherMessage)
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 800))
                .slideY(begin: 30, end: 0),
            ),
            const SizedBox(height: 40),
            _buildQuickStats()
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 800))
              .slideY(begin: 50, end: 0),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedWeatherView() {
    if (_weather == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Details',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildWeatherDetails(),
            const SizedBox(height: 20),
            _buildHourlyForecast(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Text(
              _getTimeOfDay(),
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationBar() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 15,
      blur: 10,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: _buildLocationContent(),
    );
  }

  Widget _buildLocationContent() {
    return Row(
      children: [
        const SizedBox(width: 15),
        _buildAnimatedLocationPin(),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _currentCity.toUpperCase(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildRefreshButton(),
      ],
    );
  }

  Widget _buildAnimatedLocationPin() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            2.0 * math.sin(_animationController.value * 2 * math.pi),
            0,
          ),
          child: Icon(
            Icons.location_pin,
            color: Colors.white.withOpacity(0.9),
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildRefreshButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationController.value * 2 * math.pi,
          child: IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white.withOpacity(0.8),
            ),
            onPressed: _fetchWeather,
          ),
        );
      },
    );
  }

  Widget _buildWeatherAnimation() {
    return Hero(
      tag: 'weather_animation',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: _weather == null ? 0.0 : 1.0,
        child: GestureDetector(
          onTap: () => setState(() => _showDetails = !_showDetails),
          child: Lottie.asset(
            getWeatherAnimation(_weather?.mainCondition),
            width: 220,
            height: 220,
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureDisplay(String weatherMessage) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: _weather == null ? 0.0 : 1.0,
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Text(
                  '${_weather?.temperature.round()}°',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 96,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              );
            },
          ),
          Text(
            _weather?.mainCondition ?? "",
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (weatherMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              weatherMessage,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    if (_weather == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickStat(
            Icons.thermostat_outlined,
            'Feels like',
            '${_weather?.feelsLike?.round()}°',
          ),
          _buildQuickStat(
            Icons.water_drop_outlined,
            'Humidity',
            '${_weather?.humidity}%',
          ),
          _buildQuickStat(
            Icons.air_outlined,
            'Wind',
            '${_weather?.windSpeed?.round()} km/h',
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 24,
        itemBuilder: (context, index) {
          final hour = DateTime.now().add(Duration(hours: index));
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GlassmorphicContainer(
              width: 80,
              height: 150,
              borderRadius: 15,
              blur: 10,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${hour.hour}:00',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.wb_sunny_outlined,
                    color: Colors.white.withOpacity(0.9),
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_weather?.temperature ?? 0).round()}°',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Center(
            child: GlassmorphicContainer(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 100,
              borderRadius: 15,
              blur: 10,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              child: Center(
                child: Text(
                  _errorMessage,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherDetails() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 280,
      borderRadius: 25,
      blur: 10,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDetailRow(Icons.thermostat_outlined, 'Feels Like', 
              '${_weather?.feelsLike?.round() ?? '--'}°'),
            const Divider(color: Colors.white24, height: 20),
            _buildDetailRow(Icons.water_drop_outlined, 'Humidity', 
              '${_weather?.humidity ?? '--'}%'),
            const Divider(color: Colors.white24, height: 20),
            _buildDetailRow(Icons.air_outlined, 'Wind Speed', 
              '${_weather?.windSpeed?.round() ?? '--'} km/h'),
            const Divider(color: Colors.white24, height: 20),
            _buildDetailRow(Icons.visibility_outlined, 'Visibility', 
              '${(_weather?.visibility ?? 0) ~/ 1000} km'),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _showDetails = false),
              child: Text(
                'Hide Details',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 300))
      .scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, 
          color: Colors.white.withOpacity(0.8), 
          size: 24),
        const SizedBox(width: 15),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 24,
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).scale(
            duration: const Duration(seconds: 2),
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticlesEffect() {
    if (_weather?.mainCondition?.toLowerCase() == 'rain') {
      return _RainEffect();
    } else if (_weather?.mainCondition?.toLowerCase() == 'snow') {
      return _SnowEffect();
    }
    return const SizedBox.shrink();
  }
}

class _RainEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0),
              Colors.blue.withOpacity(0.1),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnowEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0),
              Colors.white.withOpacity(0.1),
            ],
          ),
        ),
      ),
    );
  }
}