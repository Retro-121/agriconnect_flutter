import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing Groq directly...');
  try {
    final groqKey = const String.fromEnvironment('GROQ_KEY', defaultValue: '');
    if (groqKey.isEmpty) {
      print('Missing GROQ_KEY. Set with --dart-define=GROQ_KEY=...');
      return;
    }
    final groqUrl = Uri.parse("https://api.groq.com/openai/v1/chat/completions");
    final groqRes = await http.post(
      groqUrl,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $groqKey"
      },
      body: jsonEncode({
        "model": "llama-3.3-70b-versatile",
        "messages": [{"role": "user", "content": "Hello"}],
        "temperature": 0.7
      })
    );
    print("Groq Code: \${groqRes.statusCode}");
    print("Groq Body: \${groqRes.body}");
  } catch(e) {
    print('Groq Error: \$e');
  }

  print('Testing Gemini directly...');
  try {
    final geminiKey = const String.fromEnvironment('GEMINI_KEY', defaultValue: '');
    if (geminiKey.isEmpty) {
      print('Missing GEMINI_KEY. Set with --dart-define=GEMINI_KEY=...');
      return;
    }
    final geminiUrl = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$geminiKey');
    final geminiRes = await http.post(
      geminiUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [{
          "parts": [
            {"text": "Hello"}
          ]
        }]
      })
    );
    print("Gemini Code: \${geminiRes.statusCode}");
    if (geminiRes.statusCode != 200) {
      print("Gemini Body: \${geminiRes.body}");
    } else {
      print("Gemini Success!");
    }
  } catch(e) {
    print('Gemini Error: \$e');
  }
}
