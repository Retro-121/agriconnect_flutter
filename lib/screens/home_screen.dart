import 'package:flutter/material.dart';
import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _userName = 'Joseph'; // Default name

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Joseph';
    });
  }

  static const _tiles = [
    _Tile('/vets', 'Vets', 'Book a visit', Icons.medical_services_outlined),
    _Tile('/suppliers', 'Suppliers', 'Seeds & feed', Icons.shopping_bag_outlined),
    _Tile('/market', 'Market', 'Live prices', Icons.show_chart),
    _Tile('/assistant', 'AI Coach', 'Ask anything', Icons.smart_toy_outlined),
    _Tile('/reminders', 'Reminders', 'Never miss a task', Icons.notifications_active_outlined),
    _Tile('/weather', 'Weather', '5-day forecast', Icons.cloud_outlined),
    _Tile('/livestock', 'Livestock', 'Track animals', Icons.pets_outlined),
    _Tile('/community', 'Community', 'Talk to farmers', Icons.groups_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTiles = _tiles.where((tile) {
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: leaf,
                  child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        children: const [
                          Text('GREEN HILLS · NAKURU',
                              style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5)),
                          SizedBox(height: 4),
                          Text('24°',
                              style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w600)),
                          Text('Partly cloudy · Rain Thu',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const Icon(Icons.wb_sunny, color: harvest, size: 56),
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

