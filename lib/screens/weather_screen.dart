import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../theme.dart';
import 'api_config.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _currentWeather;
  List<dynamic>? _forecastList;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // 1. Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // 2. Get Location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // 3. Fetch Data from OpenWeatherMap
      final apiKey = ApiConfig.weatherApiKey;
      final lat = position.latitude;
      final lon = position.longitude;

      // Current Weather
      final currentRes = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));
      
      // Forecast
      final forecastRes = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));

      if (currentRes.statusCode == 200 && forecastRes.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _currentWeather = json.decode(currentRes.body);
          
          // Filter forecast (taking one item per day, roughly every 8th item since it's 3-hour chunks)
          final allForecasts = json.decode(forecastRes.body)['list'] as List;
          _forecastList = [];
          for (int i = 0; i < allForecasts.length; i += 8) {
             _forecastList!.add(allForecasts[i]);
          }
          
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getWeekday(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  IconData _getWeatherIcon(String mainCondition) {
    switch (mainCondition.toLowerCase()) {
      case 'clouds': return Icons.cloud;
      case 'rain': return Icons.umbrella;
      case 'clear': return Icons.wb_sunny;
      case 'snow': return Icons.ac_unit;
      case 'thunderstorm': return Icons.flash_on;
      default: return Icons.wb_cloudy;
    }
  }

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredForecast = _forecastList?.where((item) {
      if (_searchQuery.isEmpty) return true;
      final day = _getWeekday(item['dt']).toLowerCase();
      final desc = item['weather'][0]['description'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return day.contains(query) || desc.contains(query);
    }).toList();

    return PhoneShell(
      title: 'Weather',
      showBack: true,
      bgImage: 'assets/backgrounds/bg-weather.jpg',
      bgImageDark: 'assets/backgrounds/bg-weather-dark.jpg',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = '';
                            });
                            _fetchWeather();
                          },
                          child: const Text('Retry'),
                        )
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      AgriSearchBar(
                        hintText: 'Search forecast by day or condition...',
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                      // Current Weather Header
                      if (_currentWeather != null && _searchQuery.isEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: leaf.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _currentWeather!['name'] ?? 'Your Location',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_currentWeather!['main']['temp'].round()}°C',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                _currentWeather!['weather'][0]['description'].toString().toUpperCase(),
                                style: const TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        
                      Text(_searchQuery.isEmpty ? '5-Day Forecast' : 'Search Results', 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      // Forecast List
                      if (filteredForecast != null)
                        ...filteredForecast.map((item) {
                          final condition = item['weather'][0]['main'];
                          final desc = item['weather'][0]['description'];
                          final temp = item['main']['temp'].round();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 50, child: Text(_getWeekday(item['dt']), style: const TextStyle(fontWeight: FontWeight.w600))),
                                Icon(_getWeatherIcon(condition), color: harvest),
                                const SizedBox(width: 12),
                                Expanded(child: Text(desc, style: TextStyle(color: Theme.of(context).hintColor))),
                                Text('$temp°', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
    );
  }
}
