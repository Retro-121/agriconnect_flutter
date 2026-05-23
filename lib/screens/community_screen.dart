import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _language = 'English';
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> _messages = [
    {
      'user': 'Mary W.',
      'initial': 'M',
      'text': 'Anyone selling DAP near Arusha?',
      'fromMe': false,
    },
    {
      'user': 'John K.',
      'initial': 'J',
      'text': 'My cow refuses to eat — vet recommendations?',
      'fromMe': false,
    },
    {
      'user': 'Grace M.',
      'initial': 'G',
      'text': 'Sharing my drip irrigation setup, AMA!',
      'fromMe': false,
    },
    {
      'user': 'Peter O.',
      'initial': 'P',
      'text': 'Maize prices at Eldoret market today?',
      'fromMe': false,
    },
    {
      'user': 'Sam L.',
      'initial': 'S',
      'text': 'How to control pests in organic farming?',
      'fromMe': false,
    },
    {
      'user': 'Alice J.',
      'initial': 'A',
      'text': 'Good poultry feed suppliers in Arusha?',
      'fromMe': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadMessages();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'English';
    });
  }

  String t(String en, String sw) => _language == 'Kiswahili' ? sw : en;

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedPosts = prefs.getString('community_posts');
    if (savedPosts != null) {
      final List<dynamic> decoded = json.decode(savedPosts);
      setState(() {
        _messages = List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item)),
        );
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('community_posts', json.encode(_messages));
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName') ?? prefs.getString('user_name') ?? 'Farmer';

    setState(() {
      _messages.insert(0, {
        'user': name,
        'initial': name.isNotEmpty ? name[0].toUpperCase() : 'F',
        'text': text,
        'fromMe': true,
      });
      _messageController.clear();
    });
    await _saveMessages();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMessages = _messages.where((message) {
      final query = _searchQuery.toLowerCase();
      return message['user'].toString().toLowerCase().contains(query) ||
          message['text'].toString().toLowerCase().contains(query);
    }).toList();

    return PhoneShell(
      title: t('Community', 'Jamii'),
      showBack: true,
      bgImage: 'assets/backgrounds/bg-community.jpg',
      bgImageDark: 'assets/backgrounds/bg-community-dark.jpg',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(
                      'This chat space lets farmers and service providers exchange quick updates, ask questions, and share market news.',
                      'Sehemu hii ya mazungumzo inawawezesha wakulima na watoa huduma kubadilishana taarifa za haraka, kuuliza maswali, na kushiriki habari za soko.',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('Type your message below and hit Send.', 'Andika ujumbe wako hapa chini na bonyeza Tuma.'),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
            AgriSearchBar(
              hintText: t('Search chat messages...', 'Tafuta ujumbe wa mazungumzo...'),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 10),
            if (filteredMessages.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    t('No messages yet. Start the conversation below.', 'Hakuna ujumbe bado. Anza mazungumzo hapo chini.'),
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredMessages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final message = filteredMessages[index];
                final isMe = message['fromMe'] == true;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMe ? leaf : Theme.of(context).colorScheme.surface.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: isMe ? Colors.white : leaf,
                              child: Text(
                                message['initial'].toString(),
                                style: TextStyle(
                                  color: isMe ? leaf : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              message['user'].toString(),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message['text'].toString(),
                          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: t('Write a message...', 'Andika ujumbe...'),
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: leaf),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

