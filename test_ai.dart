import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final _geminiApiKey = const String.fromEnvironment('GEMINI_KEY', defaultValue: '');
  if (_geminiApiKey.isEmpty) {
    print('Missing GEMINI_KEY. Set with --dart-define=GEMINI_KEY=...');
    return;
  }
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey');
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "contents": [{
        "parts": [
          {"text": "Hello"}
        ]
      }]
    })
  );
  
  print("Gemini Code: \${response.statusCode}");
  print("Gemini Body: \${response.body}");

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
      "Authorization": "Bearer \$groqKey"
    },
    body: jsonEncode({
      "model": "llama-3.3-70b-versatile",
      "messages": [{"role": "user", "content": "Hello"}]
    })
  );

  print("Groq Code: \${groqRes.statusCode}");
  print("Groq Body: \${groqRes.body}");
}
