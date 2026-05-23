class ApiConfig {
  
  static String get groqKey => const String.fromEnvironment('GROQ_KEY', defaultValue: '');
  static const String groqModel = 'llama-3.3-70b-versatile';
  static const String systemInstruction =
      "You are 'Agriconnect Pro AI', a professional farming assistant. "
      "Provide expert advice on crops, livestock, and sustainable farming. "
      "Keep answers helpful, accurate, and very concise.";
  static String get geminiKey => const String.fromEnvironment('GEMINI_KEY', defaultValue: '');
  static String get weatherApiKey => const String.fromEnvironment('OPENWEATHER_KEY', defaultValue: '');

  // Validation methods
  static bool get hasValidGroqKey => groqKey.isNotEmpty;
  static bool get hasValidGeminiKey => geminiKey.isNotEmpty;
  static bool get hasValidWeatherKey => weatherApiKey.isNotEmpty;

  static String validateKey(String key, String keyName) {
    if (key.isEmpty) {
      throw Exception('Missing API key: $keyName. Please set --dart-define=$keyName=your_key_here');
    }
    return key;
  }
}
