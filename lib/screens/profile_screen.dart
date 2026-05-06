import 'package:flutter/material.dart';
import '../widgets/phone_shell.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _items = [
    [Icons.language, 'Language', 'English / Swahili'],
    [Icons.wifi, 'Offline mode', 'On'],
    [Icons.notifications, 'Notifications', 'All'],
    [Icons.settings, 'Farm settings', 'Green Hills'],
    [Icons.help_outline, 'Help & support', ''],
  ];

  @override
  Widget build(BuildContext context) {
    return PhoneShell(
      title: 'Profile',
      showBack: true,
      showThemeToggle: true,
      bgImage: 'assets/backgrounds/bg-profile.jpg',
      bgImageDark: 'assets/backgrounds/bg-profile-dark.jpg',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [leaf, Color(0xFF1F5A38)]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  CircleAvatar(radius: 40, backgroundColor: Colors.white24, child: const Text('JM', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 12),
                  const Text('Joseph Mwangi', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                  const Text('Green Hills Farm · Nakuru', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(children: [
                    _stat('Acres', '12'), _stat('Animals', '138'), _stat('Years', '8'),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: _items.map((it) => ListTile(
                  leading: Container(height: 36, width: 36, decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: Icon(it[0] as IconData, size: 18)),
                  title: Text(it[1] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: (it[2] as String).isEmpty ? null : Text(it[2] as String, style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Sign out', style: TextStyle(color: Colors.red)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String l, String v) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(v, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(l, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ]),
    ),
  );
}
