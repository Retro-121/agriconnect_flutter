import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groq_sdk/groq_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/agri_search_bar.dart';
import 'api_config.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late GroqChat chat;
  bool _isInitialized = false;
  bool _isLoading = false;

  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // =========================
  // STORAGE
  // =========================
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_farm_chat', json.encode(_messages));
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedChat = prefs.getString('saved_farm_chat');

    setState(() {
      if (savedChat != null) {
        Iterable decoded = json.decode(savedChat);
        _messages = List<Map<String, dynamic>>.from(decoded);
      } else {
        _messages = [
          {
            "role": "bot",
            "text": "Hujambo! Nawezaje kukusaidia leo?",
          }
        ];
      }
    });
  }

  // =========================
  // TYPING EFFECT
  // =========================
  Future<void> _typeText(String fullText, int index) async {
    List<String> parts = fullText.split(" ");
    String current = "";

    for (int i = 0; i < parts.length; i++) {
      current += parts[i] + " ";

      if (!mounted) return;

      setState(() {
        _messages[index]["text"] = current.trim();
      });

      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 40));
    }
  }

  // =========================
  // CHAT LOGIC
  // =========================
  Future<void> _callGroq(String prompt, int botIndex) async {
    try {
      if (!_isInitialized) {
        final groq = Groq(ApiConfig.groqKey);
        chat = groq.startNewChat(ApiConfig.groqModel);
        _isInitialized = true;
      }

      final result = await chat.sendMessage(prompt);
      final response = result.$1;

      print("FULL RESPONSE: $response");

      String aiText = "";

      if (response != null &&
          response.choices != null &&
          response.choices.isNotEmpty) {
        // ✅ FIXED HERE (message is already String)
        aiText = response.choices.first.message.trim();
      } else {
        aiText = "Hakuna jibu lililopatikana.";
      }

      setState(() {
        _messages[botIndex]["text"] = "";
        _messages[botIndex]["isLoading"] = false;
      });

      await _typeText(aiText, botIndex);
    } catch (e) {
      print("🔥 GROQ ERROR: $e");

      setState(() {
        _messages[botIndex] = {
          "role": "bot",
          "text": "Imeshindikana: $e",
          "isError": true,
          "prompt": prompt
        };
      });
    } finally {
      _isLoading = false;
      _saveChatHistory();
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty || _isLoading) return;

    final text = _controller.text.trim();
    _controller.clear();

    setState(() {
      _isLoading = true;

      _messages.add({"role": "user", "text": text});

      _messages.add({
        "role": "bot",
        "text": "",
        "isLoading": true,
      });
    });

    final botIndex = _messages.length - 1;

    _scrollToBottom();
    _saveChatHistory();
    _callGroq(text, botIndex);
  }

  void _retryMessage(int index) {
    final prompt = _messages[index]["prompt"];
    if (prompt == null) return;

    setState(() {
      _messages[index] = {"role": "bot", "text": "", "isLoading": true};
      _isLoading = true;
    });

    _callGroq(prompt, index);
  }

  // =========================
  // UI HELPERS
  // =========================
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, dynamic> msg, int index) {
    bool isUser = msg["role"] == "user";

    if (msg["isLoading"] == true) {
      return _typingBubble();
    }

    if (msg["isError"] == true) {
      return GestureDetector(
        onTap: () => _retryMessage(index),
        child: _bubble(msg["text"], isUser: false, color: Colors.red),
      );
    }

    return _bubble(msg["text"], isUser: isUser);
  }

  Widget _bubble(String text, {required bool isUser, Color? color}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? (isUser ? Colors.green : Colors.black54),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _typingBubble() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 40,
          child: LinearProgressIndicator(),
        ),
      ),
    );
  }

  String _searchQuery = '';

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final filteredMessages = _messages.where((msg) {
      if (_searchQuery.isEmpty) return true;
      final text = msg['text'] as String? ?? '';
      return text.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: false, // Changed to false to accommodate search bar better
      appBar: AppBar(
        title: const Text("AI Assistant"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/bg-assistant.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: AgriSearchBar(
                hintText: 'Search chat history...',
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) =>
                    _buildMessage(filteredMessages[index], index),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.green,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
