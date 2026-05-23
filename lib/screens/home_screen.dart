import 'package:flutter/material.dart';
import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../widgets/profile_avatar.dart';
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
  String _profileImageUrl = '';
  bool _offlineMode = false;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadUserName();
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
                      Text('👋',
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

