class ApiConfig {
  // --- AI CONFIGURATION ---
  // Provide your API keys using dart-define at runtime.
  // Example: flutter run --dart-define=GROQ_KEY=... --dart-define=GEMINI_KEY=... --dart-define=OPENWEATHER_KEY=...
  static String get groqKey => const String.fromEnvironment('GROQ_KEY', defaultValue: '');
  static const String groqModel = 'llama-3.3-70b-versatile';
  static const String systemInstruction =
      "You are 'Agriconnect Pro AI', a professional farming assistant. "
      "Provide expert advice on crops, livestock, and sustainable farming. "
      "Keep answers helpful, accurate, and very concise.";
  static String get geminiKey => const String.fromEnvironment('GEMINI_KEY', defaultValue: '');

  // --- WEATHER CONFIGURATION ---
  // 1. Go to https://home.openweathermap.org/api_keys
  // 2. Supply the key with dart-define.
  static String get weatherApiKey => const String.fromEnvironment('OPENWEATHER_KEY', defaultValue: '');
}
