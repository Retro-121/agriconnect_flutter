import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/agri_search_bar.dart';
import '../theme.dart';
import 'api_config.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Voice stuff
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final FlutterTts _flutterTts = FlutterTts();

  // Farmer data loaded from prefs
  String _userName = 'Farmer';
  String _farmType = 'Farming';
  String _farmAcres = '0';
  String _farmAnimals = '0';
  String _cattleType = '';
  String _farmLocation = 'Kenya';
  String _language = 'English';
  // Live data summaries
  String _remindersSummary = 'No upcoming reminders.';
  String _livestockSummary = 'No livestock groups added.';

  List<Map<String, dynamic>> _messages = [];
  String _searchQuery = '';

  // Quick prompt suggestions
  static const _quickPrompts = [
    '🌿 What crops suit my farm?',
    '🐄 Signs of sick livestock?',
    '💧 Irrigation tips for dry season',
    '📈 Best market prices today?',
    '🧪 Soil testing guide',
    '🔍 Tour app features',
  ];

  @override
  void initState() {
    super.initState();
    _loadFarmerData();
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _speech.initialize();
    await _flutterTts.setLanguage(_language == 'Kiswahili' ? 'sw-TZ' : 'en-US');
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {});
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() => _controller.text = val.recognizedWords);
          if (val.finalResult) {
            setState(() => _isListening = false);
            _speech.stop();
            if (val.recognizedWords.trim().isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted && !_isLoading) {
                  _sendMessage();
                }
              });
            }
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.speak(text);
  }

  void _sendSuggestion() {
    if (_controller.text.trim().isEmpty) return;
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Suggestion sent to AgriConnect developers! Thank you.')),
    );
  }

  String? _executeAppCommand(String text) {
    final normalized = text.toLowerCase();

    if (normalized.contains('logout') || normalized.contains('log out') || normalized.contains('sign out')) {
      _performLogout();
      return _language == 'Kiswahili'
          ? 'Nimetoka kwenye akaunti yako na kurudisha kwenye skrini ya kuingia.'
          : 'Logged you out and sent you back to the login screen.';
    }

    if (normalized.contains('clear chat') || normalized.contains('reset chat')) {
      _clearChat();
      return _language == 'Kiswahili'
          ? 'Mazungumzo yamefutwa. Tunaweza kuanza tena.'
          : 'Chat cleared. We can start fresh.';
    }

    if (normalized.contains('suggest') || normalized.contains('feedback')) {
      _sendSuggestion();
      return _language == 'Kiswahili'
          ? 'Pendekezo lako limepokelewa. Asante kwa maoni yako.'
          : 'Your suggestion has been noted. Thanks for the feedback.';
    }

    final route = _routeForAppCommand(normalized);
    if (route != null) {
      _navigateToRoute(route);
      return _language == 'Kiswahili'
          ? 'Nimefungua skrini husika kwa ajili yako.'
          : 'I opened the requested screen for you.';
    }

    return null;
  }

  String? _routeForAppCommand(String normalized) {
    if (normalized.contains('service provider') || normalized.contains('provider home') || normalized.contains('provider page')) {
      return '/service-provider-home';
    }
    if (normalized.contains('reminder') || normalized.contains('task')) {
      return '/reminders';
    }
    if (normalized.contains('weather')) {
      return '/weather';
    }
    if (normalized.contains('livestock') || normalized.contains('cattle')) {
      return '/livestock';
    }
    if (normalized.contains('community')) {
      return '/community';
    }
    if (normalized.contains('market')) {
      return '/market';
    }
    if (normalized.contains('supplier') || normalized.contains('suppliers')) {
      return '/suppliers';
    }
    if (normalized.contains('vet') || normalized.contains('vets')) {
      return '/vets';
    }
    if (normalized.contains('profile') || normalized.contains('account')) {
      return '/profile';
    }
    if (normalized.contains('help') || normalized.contains('support')) {
      return '/help';
    }
    if (normalized.contains('home') || normalized.contains('dashboard')) {
      return '/';
    }
    return null;
  }

  void _navigateToRoute(String route) {
    if (!mounted) return;
    Navigator.pushNamed(context, route);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_language == 'Kiswahili'
            ? 'Skrini imefunguliwa kwa Nakala ya AI.'
            : 'Screen opened by AI command.'),
      ),
    );
  }

  Future<void> _performLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Load farmer context ──────────────────────────────────────
  Future<void> _loadFarmerData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Farmer';
      _farmType = prefs.getString('farmType') ?? 'Farming';
      _farmAcres = prefs.getString('farmAcres') ?? '0';
      _farmAnimals = prefs.getString('farmAnimals') ?? '0';
      _cattleType = prefs.getString('cattleType') ?? '';
      _farmLocation = prefs.getString('farmLocation') ?? 'Kenya';
      _language = prefs.getString('language') ?? 'English';
      
      // Load summaries (simplified for prompt context)
      _remindersSummary = prefs.getString('reminders_summary') ?? 'No upcoming reminders.';
      _livestockSummary = prefs.getString('livestock_summary') ?? 'No livestock groups added.';
    });
    _loadChatHistory();
  }

  // ── Build system context string ──────────────────────────────
  String _buildSystemContext() {
    return '''
[SYSTEM CONTEXT — AgriConnect Pro AI]
You are "AgriConnect Pro AI", a professional, friendly farming assistant embedded in the AgriConnect Pro mobile app.

FARMER PROFILE:
- Name: $_userName
- Location: $_farmLocation
- Farm type: $_farmType
- Farm size: $_farmAcres acres
- Animals (General): $_farmAnimals${_cattleType.isNotEmpty ? ' ($_cattleType)' : ''}

CURRENT LIVE FARM DATA:
- REMINDERS: $_remindersSummary
- LIVESTOCK GROUPS: $_livestockSummary

APP FEATURES you can suggest:
- Vets screen: book vet visits
- Suppliers screen: seeds, feed & fertilizer suppliers
- Market screen: live crop & livestock prices
- Weather screen: 5-day forecast & planting guidance
- Reminders screen: SET and track farm tasks (Time, Date, Occasion)
- Livestock screen: Track Cattle by Category (Dairy, Beef, etc.), vaccinations, health, and deaths.
- Community screen: connect with other farmers

YOUR ROLE:

1. Give personalized farming advice using the farmer's real profile data.

2. Use the farmer's reminders, schedules, and tasks to provide timely recommendations and alerts.

3. Refer to livestock records and livestock groups when answering animal health, feeding, breeding, vaccination, or productivity questions.

4. Suggest relevant app tools and features whenever useful.

5. Respond in ${_language == 'Kiswahili' ? 'Kiswahili' : 'English'} unless the farmer uses another language.

6. Keep answers practical, short, actionable, and abit of humour and farmer-friendly.

7. Analyze uploaded images when provided. You can:
   - Detect visible livestock diseases or injuries
   - Identify crop diseases and pest damage
   - Analyze feed quality
   - Detect unhealthy animal conditions
   - Read labels, prescriptions, or medicine packaging
   - Explain farming-related photos

8. Help farmers make decisions using farm data such as:
   - Weather conditions
   - Feeding schedules
   - Vaccination history
   - Market prices
   - Production trends

9. Provide smart reminders and recommendations for:
   - Vaccinations
   - Deworming
   - Feeding times
   - Breeding periods
   - Medication schedules
   - Harvest periods

10. Detect emergency situations and advise immediate action for:
   - Disease outbreaks
   - Poisoning symptoms
   - Severe injuries
   - Dangerous weather conditions

11. Recommend nearby:
   - Veterinarians
   - Suppliers
   - Agrovet shops
   - Livestock markets
   - Veterinary laboratories

12. Support voice-based interaction when available:
   - Speech-to-text farmer questions
   - Voice responses
   - Multilingual assistance

13. Explain farming concepts in simple language suitable for beginners and rural farmers.

14. Help with farm management tasks such as:
   - Expense tracking
   - Profit estimation
   - Feed calculations
   - Animal record management
   - Inventory management

15. Learn from farmer activity to give smarter future suggestions and personalized farming insights.

16. If information is uncertain or requires professional diagnosis, clearly recommend consulting a veterinarian or agricultural expert.

17. If the farmer asks you to draw, create, or generate an image, reply exactly and ONLY with this text format: "[GENERATE_IMAGE: <detailed visual description of the image>]" replacing the description with a detailed prompt for an image generator. Do not include any other text in your response.

[END SYSTEM CONTEXT — answer the farmer's question below]
''';
  }

  // ── Storage ──────────────────────────────────────────────────
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
            'role': 'bot',
            'text': _language == 'Kiswahili'
                ? 'Habari $_userName! Mimi ni msaidizi wako wa kilimo. Ninajua shamba lako na naweza kukusaidia na mazao, mifugo, hali ya hewa na bei za soko. Unauliza nini leo?'
                : 'Hello $_userName! I\'m your personal farming AI. I know your farm details and can help with crops, livestock, weather, market prices and more. What can I help you with today?',
          }
        ];
      }
    });
  }

  // ── Typing effect ────────────────────────────────────────────
  Future<void> _typeText(String fullText, int index) async {
    final parts = fullText.split(' ');
    String current = '';
    for (int i = 0; i < parts.length; i++) {
      current = '$current${parts[i]} ';
      if (!mounted) return;
      setState(() => _messages[index]['text'] = current.trim());
      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 35));
    }
  }

  // ── Groq call ────────────────────────────────────────────────
  Future<void> _callGroq(String prompt, int botIndex) async {
    try {
      // Validate API key before making request
      if (!ApiConfig.hasValidGroqKey) {
        throw Exception('Missing GROQ_KEY. Please configure your API key.');
      }

      final groqUrl = Uri.parse("https://api.groq.com/openai/v1/chat/completions");
      
      List<Map<String, dynamic>> messages = [
        {"role": "system", "content": _buildSystemContext()}
      ];

      // Build context from history
      for (var msg in _messages) {
        if (msg['text'] != null && msg['text'].toString().isNotEmpty && msg['isError'] != true && msg['isLoading'] != true) {
          messages.add({
            "role": msg['role'] == 'bot' ? 'assistant' : 'user',
            "content": msg['text']
          });
        }
      }

      // If retry, the user message might not be in the history properly, so ensure it's there
      if (messages.isEmpty || messages.last['content'] != prompt) {
        messages.add({"role": "user", "content": prompt});
      }

      final response = await http.post(
        groqUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConfig.groqKey}"
        },
        body: jsonEncode({
          "model": ApiConfig.groqModel,
          "messages": messages,
          "temperature": 0.7,
        })
      );

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      String aiText = data["choices"][0]["message"]["content"] ?? '';

      setState(() {
        _messages[botIndex]['text'] = '';
        _messages[botIndex]['isLoading'] = false;
      });

      await _typeText(aiText.trim(), botIndex);
    } catch (e) {
      setState(() {
        _messages[botIndex] = {
          'role': 'bot',
          'text': _language == 'Kiswahili'
              ? 'Hitilafu: $e\n\nGusa ujumbe huu kujaribu tena.'
              : 'Error: $e\n\nTap this message to retry.',
          'isError': true,
          'prompt': prompt,
        };
      });
    } finally {
      _isLoading = false;
      _saveChatHistory();
    }
  }

  Future<void> _callGemini(String prompt, String base64Image, int botIndex) async {
    try {
      // Validate API key before making request
      if (!ApiConfig.hasValidGeminiKey) {
        throw Exception('Missing GEMINI_KEY. Please configure your API key.');
      }

      // Use Gemini API with key in headers instead of URL parameters
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${ApiConfig.geminiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "system_instruction": {
            "parts": [{"text": _buildSystemContext()}]
          },
          "contents": [{
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }]
        })
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiText = data['candidates'][0]['content']['parts'][0]['text'];
        
        setState(() {
          _messages[botIndex]['text'] = '';
          _messages[botIndex]['isLoading'] = false;
        });
        
        await _typeText(aiText.trim(), botIndex);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _messages[botIndex] = {
          'role': 'bot',
          'text': 'Error analyzing image: $e\n\nTap to retry.',
          'isError': true,
          'prompt': prompt,
          'imageBytes': base64Image,
        };
      });
    } finally {
      _isLoading = false;
      _saveChatHistory();
    }
  }

  Future<void> _showImageSourceOptions() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Take photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _generateImageFromPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _isLoading) return;
    _controller.clear();
    setState(() {
      _isLoading = true;
      _messages.add({'role': 'user', 'text': prompt});
      _messages.add({'role': 'bot', 'text': '', 'isLoading': true});
    });
    final botIndex = _messages.length - 1;
    _scrollToBottom();
    _saveChatHistory();
    await _callGeminiImageCreation(prompt, botIndex);
  }

  Future<void> _callGeminiImageCreation(String prompt, int botIndex) async {
    try {
      // Validate API key before making request
      if (!ApiConfig.hasValidGeminiKey) {
        throw Exception('Missing GEMINI_KEY. Please configure your API key.');
      }

      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/images:generate?key=${ApiConfig.geminiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'gemini-1.5-image',
          'prompt': {'text': prompt},
          'imageFormat': 'PNG',
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode}');
      }
      final data = jsonDecode(response.body);
      String? imageUrl;
      String? imageBase64;
      if (data['data'] is List && data['data'].isNotEmpty) {
        final first = data['data'][0];
        imageUrl = first['uri'] as String?;
        imageBase64 = first['b64_json'] as String?;
      }
      if (imageUrl == null && imageBase64 == null) {
        throw Exception('No image returned from Gemini');
      }
      setState(() {
        _messages[botIndex] = {
          'role': 'bot',
          'text': 'Generated image for: $prompt',
          if (imageUrl != null) 'imageUrl': imageUrl,
          if (imageBase64 != null) 'imageBytes': imageBase64,
        };
      });
    } catch (e) {
      setState(() {
        _messages[botIndex] = {
          'role': 'bot',
          'text': 'Error generating image: $e\n\nTap to retry.',
          'isError': true,
          'prompt': prompt,
        };
      });
    } finally {
      _isLoading = false;
      _saveChatHistory();
    }
  }

  void _sendMessage([String? presetText]) async {
    final text = presetText ?? _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;
    if (_isLoading) return;
    _controller.clear();

    String? base64Image;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    if (base64Image == null) {
      final commandResponse = _executeAppCommand(text);
      if (commandResponse != null) {
        setState(() {
          _messages.add({'role': 'user', 'text': text});
          _messages.add({'role': 'bot', 'text': commandResponse});
        });
        _saveChatHistory();
        return;
      }
    }

    setState(() {
      _selectedImage = null;
      _isLoading = true;
      _messages.add({
        'role': 'user', 
        'text': text,
        if (base64Image != null) 'imageBytes': base64Image,
      });
      _messages.add({'role': 'bot', 'text': '', 'isLoading': true});
    });

    final botIndex = _messages.length - 1;
    _scrollToBottom();
    _saveChatHistory();
    
    if (base64Image != null) {
      _callGemini(text.isEmpty ? 'Analyze this image.' : text, base64Image, botIndex);
    } else {
      _callGroq(text, botIndex);
    }
  }

  void _retryMessage(int index) {
    final prompt = _messages[index]['prompt'];
    final imageBytes = _messages[index]['imageBytes'];
    if (prompt == null) return;
    setState(() {
      _messages[index] = {'role': 'bot', 'text': '', 'isLoading': true};
      _isLoading = true;
    });
    if (imageBytes != null) {
      _callGemini(prompt, imageBytes, index);
    } else {
      _callGroq(prompt, index);
    }
  }

  void _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_farm_chat');
    await prefs.remove('chat_context_sent');
    setState(() {
      _messages = [
        {
          'role': 'bot',
          'text': _language == 'Kiswahili'
              ? 'Mazungumzo mapya yameanza. Ninawezaje kukusaidia?'
              : 'New conversation started. How can I help you?',
        }
      ];
    });
  }

  // ── UI Helpers ───────────────────────────────────────────────
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
    if (msg['isLoading'] == true) return _typingBubble();
    if (msg['isError'] == true) {
      return GestureDetector(
        onTap: () => _retryMessage(index),
        child: _bubble(
          msg['text'],
          isUser: false,
          isError: true,
          imageBytes: msg['imageBytes'],
          imageUrl: msg['imageUrl'],
        ),
      );
    }
    return _bubble(
      msg['text'],
      isUser: msg['role'] == 'user',
      imageBytes: msg['imageBytes'],
      imageUrl: msg['imageUrl'],
    );
  }

  Widget _bubble(String text, {required bool isUser, bool isError = false, String? imageBytes, String? imageUrl}) {
    String? generatedImageUrl;
    String displayText = text;
    
    final RegExp generateRegex = RegExp(r'\[GENERATE_IMAGE:\s*(.*?)\]');
    final match = generateRegex.firstMatch(text);
    if (match != null) {
      final prompt = match.group(1);
      if (prompt != null && prompt.isNotEmpty) {
        generatedImageUrl = 'https://image.pollinations.ai/prompt/${Uri.encodeComponent(prompt)}';
        displayText = text.replaceFirst(match.group(0)!, '').trim();
      }
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red.withOpacity(0.85)
              : isUser
                  ? leaf
                  : Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBytes != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(base64Decode(imageBytes), fit: BoxFit.cover),
                ),
              ),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: leaf));
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Failed to load generated image.', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    generatedImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: leaf));
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Failed to load generated image.', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ),
            if (displayText.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(displayText, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                  ),
                  if (!isUser) ...[
                    const SizedBox(width: 8),
                    _ttsButton(displayText),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _dot(i)),
        ),
      ),
    );
  }

  Widget _dot(int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + i * 150),
      builder: (_, v, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4 + v * 0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _messages.where((msg) {
      if (_searchQuery.isEmpty) return true;
      return (msg['text'] as String? ?? '')
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _language == 'Kiswahili' ? 'Msaidizi wa AI' : 'AI Assistant',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _language == 'Kiswahili' ? 'Anakujua — $_userName' : 'Knows your farm · $_userName',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            tooltip: 'Clear chat',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/bg-assistant.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 40),

            // ── Search bar ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: AgriSearchBar(
                hintText: _language == 'Kiswahili'
                    ? 'Tafuta mazungumzo...'
                    : 'Search chat history...',
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // ── Messages ───────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) => _buildMessage(filtered[i], i),
              ),
            ),

            // ── Quick prompts (show when idle) ─────────────
            if (!_isLoading && _messages.length <= 1)
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _quickPrompts.length,
                  itemBuilder: (ctx, i) => GestureDetector(
                    onTap: () => _sendMessage(_quickPrompts[i]),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        _quickPrompts[i],
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Input bar ──────────────────────────────────
            Column(
              children: [
                if (_selectedImage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white38),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FutureBuilder<Uint8List>(
                              future: _selectedImage!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                                }
                                return const Center(child: CircularProgressIndicator());
                              }
                            ),
                          ),
                        ),
                        Positioned(
                          right: -10,
                          top: -10,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white70),
                        onPressed: _isLoading ? null : _showImageSourceOptions,
                      ),
                      IconButton(
                        icon: const Icon(Icons.image_outlined, color: Colors.white70),
                        tooltip: 'Generate image with Gemini',
                        onPressed: _isLoading ? null : _generateImageFromPrompt,
                      ),
                      // Mic Button
                      IconButton(
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none, 
                          color: _isListening ? Colors.red : leaf),
                        tooltip: _language == 'Kiswahili' ? 'Amri kwa sauti' : 'Voice command',
                        onPressed: _listen,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: leaf,
                          decoration: InputDecoration(
                            hintText: _language == 'Kiswahili'
                                ? 'Andika swali lako au amri ya sauti...'
                                : 'Ask your farming question or command...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : _sendMessage,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isLoading ? Colors.grey : leaf,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _sendSuggestion,
                  icon: const Icon(Icons.feedback_outlined, size: 16, color: Colors.white54),
                  label: const Text('Send suggestion to developers', 
                    style: TextStyle(fontSize: 11, color: Colors.white54)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Speech Output Toggle for messages ────────────────────────
  Widget _ttsButton(String text) {
    return IconButton(
      icon: const Icon(Icons.volume_up, size: 18, color: leaf),
      onPressed: () => _speak(text),
    );
  }
}
