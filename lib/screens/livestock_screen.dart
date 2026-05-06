import 'package:flutter/material.dart';
import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../theme.dart';

class LivestockScreen extends StatefulWidget {
  const LivestockScreen({super.key});

  @override
  State<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends State<LivestockScreen> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _animals = [
    {'name': 'Daisy', 'id': '#A-014', 'type': 'Dairy cow', 'status': 'Healthy', 'health': 0.9},
    {'name': 'Bella', 'id': '#A-018', 'type': 'Dairy cow', 'status': 'Vaccine due', 'health': 0.55},
    {'name': 'Coop A', 'id': '#P-002', 'type': 'Layers · 120', 'status': 'Healthy', 'health': 0.85},
    {'name': 'Goats', 'id': '#G-003', 'type': 'Herd · 14', 'status': 'Healthy', 'health': 0.78},
    {'name': 'Sheep', 'id': '#S-005', 'type': 'Herd · 10', 'status': 'Healthy', 'health': 0.82},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredAnimals = _animals.where((animal) {
      final query = _searchQuery.toLowerCase();
      return animal['name'].toLowerCase().contains(query) ||
          animal['id'].toLowerCase().contains(query) ||
          animal['type'].toLowerCase().contains(query);
    }).toList();

    return PhoneShell(
      title: 'Livestock',
      showBack: true,
      bgImage: 'assets/backgrounds/bg-livestock.jpg',
      bgImageDark: 'assets/backgrounds/bg-livestock-dark.jpg',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            AgriSearchBar(
              hintText: 'Search animals by name or ID...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAnimals.length,
              itemBuilder: (context, index) {
                final animal = filteredAnimals[index];
                final isWarning = animal['status'] != 'Healthy';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: leaf,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.favorite, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  animal['name'],
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${animal['type']} ${animal['id']}',
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isWarning ? harvest : leaf).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              animal['status'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isWarning ? soil : leaf,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: animal['health'],
                          backgroundColor: Colors.black12,
                          color: isWarning ? harvest : leaf,
                          minHeight: 6,
                        ),
                      ),
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

