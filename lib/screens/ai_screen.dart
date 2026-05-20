import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  final String apiKey;

  AIService(this.apiKey);

  Future<String> sendMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final livestockSummary = prefs.getString('livestock_summary') ?? 'No livestock data available.';

    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
                "You are an expert agricultural assistant helping farming experts in Tanzania. Give clear, practical farming, vaccination and marketing advice and have a bit of sense of humor. Here is the farmer's current livestock data: $livestockSummary"
          },
          {
            "role": "user",
            "content": message
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      return "Error: ${response.body}";
    }
  }
}