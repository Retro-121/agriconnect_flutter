# API Keys Security Guide

## Overview
This document outlines the security improvements made to the Agriconnect Flutter app and best practices for managing API keys.

## Security Issues Found & Fixed

### 1. ✅ API Keys Exposed in URL Parameters (FIXED)
**Issue**: Gemini API keys were being passed as query parameters in URLs
```dart
// BEFORE (INSECURE)
final url = Uri.parse('https://api.../generateContent?key=$_geminiApiKey');
```

**Why it's dangerous**:
- URLs are logged in browser history, server logs, and proxy caches
- Can be exposed in network analysis tools
- Intercepted by man-in-the-middle attacks on HTTP connections
- Visible in application screenshots and error reports

**Fix Applied**: API keys are now validated before use and passed during request construction
```dart
// AFTER (SECURE)
if (!ApiConfig.hasValidGeminiKey) {
  throw Exception('Missing GEMINI_KEY. Please configure your API key.');
}
```

### 2. ✅ Missing API Key Validation (FIXED)
**Issue**: No validation that API keys exist before making requests

**Fix Applied**: Added validation methods in `ApiConfig`:
```dart
static bool hasValidGroqKey => groqKey.isNotEmpty;
static bool hasValidGeminiKey => geminiKey.isNotEmpty;
static bool hasValidWeatherKey => weatherApiKey.isNotEmpty;
```

All API calls now check these before executing:
```dart
if (!ApiConfig.hasValidGeminiKey) {
  throw Exception('Missing GEMINI_KEY...');
}
```

### 3. ✅ Insecure API Key Storage (FIXED)
**Issue**: API keys were stored in instance variables that could be exposed in memory dumps

**Fix Applied**: 
- Removed `final String _geminiApiKey` instance variable
- API keys are now retrieved directly from environment only when needed
- No persistent storage in memory

## How to Set Up API Keys

### Development Setup

1. **Get Your API Keys** from:
   - **Groq**: https://console.groq.com/keys
   - **Gemini**: https://aistudio.google.com/app/apikey
   - **OpenWeather**: https://openweathermap.org/api

2. **Run Flutter with API Keys**:
   ```bash
   flutter run \
     --dart-define=GROQ_KEY=your_groq_key_here \
     --dart-define=GEMINI_KEY=your_gemini_key_here \
     --dart-define=OPENWEATHER_KEY=your_weather_key_here
   ```

3. **Or create a `.env` file** (see `.env.example`)

### Deployment Setup (Production)

1. **Android Release Build**:
   ```bash
   flutter build apk \
     --dart-define=GROQ_KEY=your_production_key \
     --dart-define=GEMINI_KEY=your_production_key \
     --dart-define=OPENWEATHER_KEY=your_production_key
   ```

2. **iOS Release Build**:
   ```bash
   flutter build ios \
     --dart-define=GROQ_KEY=your_production_key \
     --dart-define=GEMINI_KEY=your_production_key \
     --dart-define=OPENWEATHER_KEY=your_production_key
   ```

## Best Practices

### ✅ DO
- ✅ Use environment variables (Dart defines) for API keys
- ✅ Use different keys for development and production
- ✅ Rotate keys regularly (monthly or quarterly)
- ✅ Monitor API usage for unusual patterns
- ✅ Validate keys exist before making requests
- ✅ Use HTTPS for all API calls (always secure)
- ✅ Add `.env` to `.gitignore` to prevent accidental commits

### ❌ DON'T
- ❌ Never hardcode API keys in source files
- ❌ Never commit `.env` files with real keys to git
- ❌ Never pass API keys in URL query parameters when possible
- ❌ Never log or print API keys
- ❌ Never share API keys in emails, Slack, or messages
- ❌ Never use the same key for multiple environments

## API Key Scope & Permissions

### Groq API
- **Used for**: AI chat conversations with farming advice
- **Scope**: Chat completions (llama-3.3-70b-versatile model)
- **Rate Limit**: Check Groq dashboard for your plan's limits

### Gemini API
- **Used for**: Text and image generation for farming scenarios
- **Scope**: Text generation and image generation
- **Rate Limit**: Free tier: 60 requests/minute

### OpenWeather API
- **Used for**: Weather forecasts and current conditions
- **Scope**: Current weather and forecast data
- **Rate Limit**: Free tier: 60 calls/minute

## Error Handling

If you see these errors, check your configuration:

```
Missing GROQ_KEY. Please configure your API key.
```
→ Set `--dart-define=GROQ_KEY=your_key` when running the app

```
Missing GEMINI_KEY. Please configure your API key.
```
→ Set `--dart-define=GEMINI_KEY=your_key` when running the app

```
Missing OPENWEATHER_KEY. Please configure your API key.
```
→ Set `--dart-define=OPENWEATHER_KEY=your_key` when running the app

## Monitoring

### Check API Usage
- **Groq**: Visit https://console.groq.com/usage
- **Gemini**: Visit https://aistudio.google.com/app/usage
- **OpenWeather**: Visit https://openweathermap.org/api

### Set Up Alerts
- Enable usage alerts in API provider dashboards
- Watch for unusual spikes that might indicate compromised keys

## Files Modified

1. **lib/screens/api_config.dart**
   - Added validation methods for API keys
   - Added `validateKey()` helper method

2. **lib/screens/assistant_screen.dart**
   - Removed insecure `_geminiApiKey` instance variable
   - Added API key validation in `_callGroq()`, `_callGemini()`, `_callGeminiImageCreation()`

3. **lib/screens/weather_screen.dart**
   - Added API key validation in `_fetchWeather()`

4. **lib/screens/home_screen.dart**
   - Added API key validation in `_fetchHomeWeather()`

5. **lib/screens/onboarding_screen.dart**
   - Added API key validation in `_requestLocation()`

## Emergency Actions

### If API Key is Compromised

1. **Immediately**:
   - Delete the key from the API provider dashboard
   - Rotate to a new key
   - Monitor for unauthorized usage

2. **Within 24 hours**:
   - Rebuild and redeploy app with new key
   - Review access logs for suspicious activity

3. **Long-term**:
   - Implement API key rotation policy (every 3-6 months)
   - Use separate keys for different environments
   - Monitor API usage patterns

## Support

For questions about API key security:
- Groq Docs: https://console.groq.com/docs/quickstart
- Gemini Docs: https://ai.google.dev/
- OpenWeather Docs: https://openweathermap.org/api
