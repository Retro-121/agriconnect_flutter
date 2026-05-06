import 'package:flutter/material.dart';
import '../widgets/phone_shell.dart';
import '../widgets/agri_search_bar.dart';
import '../theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _searchQuery = '';

  final List<Map<String, String>> _posts = [
    {'user': 'Mary W.', 'initial': 'M', 'text': 'Anyone selling DAP near Nakuru?'},
    {'user': 'John K.', 'initial': 'J', 'text': 'My cow refuses to eat — vet recommendations?'},
    {'user': 'Grace M.', 'initial': 'G', 'text': 'Sharing my drip irrigation setup, AMA!'},
    {'user': 'Peter O.', 'initial': 'P', 'text': 'Maize prices at Eldoret market today?'},
    {'user': 'Sam L.', 'initial': 'S', 'text': 'How to control pests in organic farming?'},
    {'user': 'Alice J.', 'initial': 'A', 'text': 'Good poultry feed suppliers in Arusha?'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _posts.where((post) {
      final query = _searchQuery.toLowerCase();
      return post['user']!.toLowerCase().contains(query) ||
          post['text']!.toLowerCase().contains(query);
    }).toList();

    return PhoneShell(
      title: 'Community',
      showBack: true,
      bgImage: 'assets/backgrounds/bg-community.jpg',
      bgImageDark: 'assets/backgrounds/bg-community-dark.jpg',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            AgriSearchBar(
              hintText: 'Search community posts...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: leaf,
                        child: Text(
                          post['initial']!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['user']!,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post['text']!,
                              style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
                            ),
                          ],
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

