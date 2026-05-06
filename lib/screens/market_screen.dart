import 'package:flutter/material.dart';
import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../theme.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _items = [
    {'name': 'Maize', 'unit': '1 kg', 'price': '55 KES', 'change': '+3%', 'trend': 'up'},
    {'name': 'Beans', 'unit': '1 kg', 'price': '120 KES', 'change': '-1%', 'trend': 'down'},
    {'name': 'Milk', 'unit': '1 L', 'price': '62 KES', 'change': '+2%', 'trend': 'up'},
    {'name': 'Tomatoes', 'unit': '1 crate', 'price': '2,400 KES', 'change': '+8%', 'trend': 'up'},
    {'name': 'Potatoes', 'unit': '1 sack', 'price': '3,100 KES', 'change': '-2%', 'trend': 'down'},
    {'name': 'Wheat', 'unit': '1 kg', 'price': '45 KES', 'change': '+1%', 'trend': 'up'},
    {'name': 'Sorghum', 'unit': '1 kg', 'price': '70 KES', 'change': '0%', 'trend': 'neutral'},
    {'name': 'Rice', 'unit': '1 kg', 'price': '150 KES', 'change': '+5%', 'trend': 'up'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = _items.where((item) {
      final query = _searchQuery.toLowerCase();
      return item['name']!.toLowerCase().contains(query);
    }).toList();

    return PhoneShell(
      title: 'Market prices',
      showBack: true,
      bgImage: 'assets/backgrounds/bg-market.jpg',
      bgImageDark: 'assets/backgrounds/bg-market-dark.jpg',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            AgriSearchBar(
              hintText: 'Search market items...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final isUp = item['trend'] == 'up';
                final isDown = item['trend'] == 'down';

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
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: harvest.withOpacity(0.3),
                        child: const Icon(Icons.eco, color: leaf),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              item['unit'],
                              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['price'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item['change'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isUp ? leaf : (isDown ? Colors.red : Colors.grey),
                            ),
                          ),
                        ],
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

