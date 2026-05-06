import 'package:flutter/material.dart';
import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../theme.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  String _searchQuery = '';

  final List<Map<String, String>> _reminders = [
    {'title': 'Vaccinate calves', 'time': 'Today · 3:00 PM'},
    {'title': 'Irrigate maize plot A', 'time': 'Today · before 6 PM'},
    {'title': 'Spray tomatoes', 'time': 'Tomorrow · 7:00 AM'},
    {'title': 'Buy DAP fertilizer', 'time': 'Fri · morning'},
    {'title': 'Vet check Bella', 'time': 'Sat · 10:00 AM'},
    {'title': 'Prune fruit trees', 'time': 'Next Mon · morning'},
    {'title': 'Repair goat shed', 'time': 'Next Tue · all day'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredReminders = _reminders.where((rem) {
      final query = _searchQuery.toLowerCase();
      return rem['title']!.toLowerCase().contains(query) ||
          rem['time']!.toLowerCase().contains(query);
    }).toList();

    return PhoneShell(
      title: 'Reminders',
      showBack: true,
      bgImage: 'assets/backgrounds/bg-reminders.jpg',
      bgImageDark: 'assets/backgrounds/bg-reminders-dark.jpg',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            AgriSearchBar(
              hintText: 'Search reminders (e.g. vaccine, irrigate)...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredReminders.length,
              itemBuilder: (context, index) {
                final rem = filteredReminders[index];
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
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: harvest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications, color: soil),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rem['title']!,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              rem['time']!,
                              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_outline, color: leaf),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

