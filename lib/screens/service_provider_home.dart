import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../widgets/profile_avatar.dart';
import '../provider_types.dart';
import 'dashboard_screen.dart';
import 'assistant_screen.dart';
import 'emergencies_screen.dart';
import 'business_screen.dart';

class ServiceProviderHomeScreen extends StatefulWidget {
  const ServiceProviderHomeScreen({super.key});

  @override
  State<ServiceProviderHomeScreen> createState() => _ServiceProviderHomeScreenState();
}

class _ServiceProviderHomeScreenState extends State<ServiceProviderHomeScreen> {
  int _index = 2;
  final _provider = ProviderState();
  String _language = 'English';
  String _userName = '';
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _provider.addListener(() => setState(() {}));
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
      _userName = prefs.getString('userName') ?? '';
      _profileImageUrl = prefs.getString('profileImageUrl') ?? '';
    });
  }

  String t(String en, String sw) => _language == 'Kiswahili' ? sw : en;

  bool _isSeller(ProviderType type) {
    return type == ProviderType.feed ||
        type == ProviderType.seed ||
        type == ProviderType.fertilizer ||
        type == ProviderType.agrochem ||
        type == ProviderType.greenhouse ||
        type == ProviderType.equipment ||
        type == ProviderType.transport;
  }

  @override
  Widget build(BuildContext context) {
    final isSeller = _isSeller(_provider.type);
    final pages = [
      const EmergenciesScreen(),
      const ServiceProviderClientsPage(),
      DashboardScreen(provider: _provider),
      const AiChatPage(),
      const ServiceProviderProfileTab(),
    ];
    final titles = [
      t('Emergencies', 'Dharura'),
      t('Clients', 'Wateja'),
      t('Home', 'Nyumbani'),
      t('AI Assistant', 'Msaidizi wa AI'),
      t('Profile', 'Wasifu'),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AgriPortal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  titles[_index],
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<ProviderType>(
            tooltip: t('Switch provider', 'Badilisha mtoa huduma'),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_provider.info.icon, color: AppColors.forest, size: 18),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, color: Colors.black54, size: 18),
                const SizedBox(width: 8),
              ],
            ),
            onSelected: _provider.set,
            itemBuilder: (_) => kProviders.entries
                .map((e) => PopupMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          Icon(e.value.icon, size: 16, color: AppColors.forest),
                          const SizedBox(width: 8),
                          Text(e.value.label),
                        ],
                      ),
                    ))
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile').then((_) => _loadLanguage()),
              child: ProfileAvatar(
                radius: 18,
                imageUrl: _profileImageUrl.isNotEmpty ? _profileImageUrl : null,
                initials: _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                backgroundColor: AppColors.forest,
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.warning_amber_outlined),
            selectedIcon: const Icon(Icons.warning_amber),
            label: t('Emergencies', 'Dharura'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: t('Clients', 'Wateja'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t('Home', 'Nyumbani'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: t('AI', 'AI'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: t('Profile', 'Wasifu'),
          ),
        ],
      ),
      floatingActionButton: _index == 3
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _index = 3),
              backgroundColor: AppColors.forest,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: Text(t('Ask AI', 'Uliza AI'), style: const TextStyle(color: Colors.white)),
            ),
    );
  }
}

class ServiceProviderClientsPage extends StatelessWidget {
  const ServiceProviderClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clients',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text('People connected to this service provider appear here.'),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: List.generate(
                5,
                (index) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person, size: 18)),
                  title: Text('Client ${index + 1}'),
                  subtitle: const Text('Connected service user'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceProviderProfileTab extends StatelessWidget {
  const ServiceProviderProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Service provider profile information will be shown here.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text('Open full profile'),
            ),
          ],
        ),
      ),
    );
  }
}
