import 'package:flutter/material.dart';
import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../widgets/profile_avatar.dart';
import '../theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'api_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _userName = 'Joseph'; // Default name
  String _profileImageUrl = '';
  bool _offlineMode = false;
  String _language = 'English';
  
  // Weather state
  String _weatherTemp = '--';
  String _weatherDesc = 'Loading...';
  String _weatherLocation = 'Your Farm';
  IconData _weatherIcon = Icons.wb_sunny;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchHomeWeather();
  }

  Future<void> _fetchHomeWeather() async {
    try {
      Position? position;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          position = await Geolocator.getCurrentPosition();
        }
      } catch (e) {
        debugPrint('Home weather location error: $e');
      }

      final apiKey = ApiConfig.weatherApiKey;
      final prefs = await SharedPreferences.getInstance();
      final savedLocation = prefs.getString('farmLocation') ?? 'Tanzania';
      final farmLat = prefs.getDouble('farmLat');
      final farmLon = prefs.getDouble('farmLon');
      
      String url;
      if (position != null) {
        url = 'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';
      } else if (farmLat != null && farmLon != null) {
        url = 'https://api.openweathermap.org/data/2.5/weather?lat=$farmLat&lon=$farmLon&appid=$apiKey&units=metric';
      } else {
        url = 'https://api.openweathermap.org/data/2.5/weather?q=$savedLocation&appid=$apiKey&units=metric';
      }

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (!mounted) return;
        setState(() {
          _weatherTemp = '${data['main']['temp'].round()}°';
          _weatherDesc = data['weather'][0]['description'].toString().toUpperCase();
          // Use user's input location if available, else use API name
          _weatherLocation = (farmLat != null && farmLon != null) 
              ? data['name'].toString().toUpperCase() 
              : (savedLocation.isNotEmpty ? savedLocation.toUpperCase() : data['name'].toString().toUpperCase());
          _weatherIcon = _getWeatherIcon(data['weather'][0]['main']);
        });
      }
    } catch (e) {
      debugPrint('Home weather fetch error: $e');
    }
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

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Joseph';
      _profileImageUrl = prefs.getString('profileImageUrl') ?? '';
      _offlineMode = prefs.getBool('offlineMode') ?? false;
      _language = prefs.getString('language') ?? 'English';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserName(); // refresh when returning from Profile
  }

  @override
  Widget build(BuildContext context) {
    final localTiles = [
      _Tile('/vets', _language == 'Kiswahili' ? 'Madaktari' : 'Vets', _language == 'Kiswahili' ? 'Weka miadi' : 'Book a visit', Icons.medical_services_outlined),
      _Tile('/suppliers', _language == 'Kiswahili' ? 'Wauzaji' : 'Suppliers', _language == 'Kiswahili' ? 'Mbegu na lishe' : 'Seeds & feed', Icons.shopping_bag_outlined),
      _Tile('/market', _language == 'Kiswahili' ? 'Soko' : 'Market', _language == 'Kiswahili' ? 'Bei za sasa' : 'Live prices', Icons.show_chart),
      _Tile('/assistant', _language == 'Kiswahili' ? 'Kocha wa AI' : 'AI Coach', _language == 'Kiswahili' ? 'Uliza chochote' : 'Ask anything', Icons.smart_toy_outlined),
      _Tile('/reminders', _language == 'Kiswahili' ? 'Vikumbusho' : 'Reminders', _language == 'Kiswahili' ? 'Usipitwe na kazi' : 'Never miss a task', Icons.notifications_active_outlined),
      _Tile('/weather', _language == 'Kiswahili' ? 'Hali ya Hewa' : 'Weather', _language == 'Kiswahili' ? 'Utabiri wa siku 5' : '5-day forecast', Icons.cloud_outlined),
      _Tile('/livestock', _language == 'Kiswahili' ? 'Mifugo' : 'Livestock', _language == 'Kiswahili' ? 'Fuatilia wanyama' : 'Track animals', Icons.pets_outlined),
      _Tile('/community', _language == 'Kiswahili' ? 'Jamii' : 'Community', _language == 'Kiswahili' ? 'Ongea na wakulima' : 'Talk to farmers', Icons.groups_outlined),
    ];

    final filteredTiles = localTiles.where((tile) {
      final query = _searchQuery.toLowerCase();
      return tile.label.toLowerCase().contains(query) ||
          tile.desc.toLowerCase().contains(query);
    }).toList();

    return PhoneShell(
      bgImage: 'assets/backgrounds/bg-home.jpg',
      bgImageDark: 'assets/backgrounds/bg-home-dark.jpg',
      showThemeToggle: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Offline banner ─────────────────────────
            if (_offlineMode)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _language == 'Kiswahili'
                            ? 'Hali ya Nje ya Mtandao — Data inaweza kuwa ya zamani'
                            : 'Offline Mode — Data may be outdated',
                        style: const TextStyle(
                            color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: const Text('Change',
                          style: TextStyle(color: Colors.orange, fontSize: 11,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Karibu 👋',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                      Text(_userName,
                          style: Theme.of(context).textTheme.displayLarge),
                    ],
                  ),
                ),
                ProfileAvatar(
                  radius: 24,
                  imageUrl: _profileImageUrl.isNotEmpty ? _profileImageUrl : null,
                  initials: _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                  backgroundColor: leaf,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AgriSearchBar(
              hintText: 'Search for features or tools...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 4),
            // Weather hero card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [leaf, Color(0xFF1F5A38)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: leaf.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_weatherLocation,
                              style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5)),
                          const SizedBox(height: 4),
                          Text(_weatherTemp,
                              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w600)),
                          Text(_weatherDesc,
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      Icon(_weatherIcon, color: harvest, size: 56),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _stat('Soil', 'Good', Icons.eco),
                      _stat('Humidity', '62%', Icons.water_drop),
                      _stat('Offline', 'Synced', Icons.wifi),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
                Text('${filteredTiles.length} tools', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
              ],
            ),
            const SizedBox(height: 12),
            if (filteredTiles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Theme.of(context).hintColor.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      Text('No features found for "$_searchQuery"',
                          style: TextStyle(color: Theme.of(context).hintColor)),
                    ],
                  ),
                ),
              )
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: filteredTiles.map((t) => _TileCard(tile: t)).toList(),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _stat(String l, String v, IconData i) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(i, color: Colors.white70, size: 16),
              const SizedBox(height: 4),
              Text(l, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              Text(v, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _Tile {
  final String route, label, desc;
  final IconData icon;
  const _Tile(this.route, this.label, this.desc, this.icon);
}

class _TileCard extends StatelessWidget {
  final _Tile tile;
  const _TileCard({required this.tile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.of(context).pushNamed(tile.route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 44, width: 44,
              decoration: BoxDecoration(
                color: leaf,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(tile.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tile.label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(tile.desc,
                    style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

