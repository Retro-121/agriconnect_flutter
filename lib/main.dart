import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme.dart';

import 'screens/home_screen.dart';
import 'screens/vets_screen.dart';
import 'screens/suppliers_screen.dart';
import 'screens/market_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/livestock_screen.dart';
import 'screens/community_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/help_screen.dart';
import 'screens/service_provider_home.dart';
import 'screens/provider_type_selection_screen.dart';
import 'services/connectivity_service.dart';

/// 🌍 Global Supabase client
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔐 Supabase initialization (SECURE PATTERN)
  await Supabase.initialize(
    url: 'https://twtfbjkjqckkwhpkyohn.supabase.co',
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  /// 📦 Local storage
  final prefs = await SharedPreferences.getInstance();
  final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
  final userRole = prefs.getString('userRole') ?? 'Farmer';

  /// 🔐 Auth state
  final session = supabase.auth.currentSession;
  final isLoggedIn = session != null;

  /// 🚦 Decide first screen
  String initialRoute;

  if (!isLoggedIn) {
    initialRoute = '/login';
  } else if (!hasOnboarded) {
    initialRoute = '/onboarding';
  } else {
    initialRoute = userRole == 'Service Provider'
        ? '/service-provider-home'
        : '/';
  }

  runApp(AgriConnectApp(initialRoute: initialRoute));
}

class AgriConnectApp extends StatefulWidget {
  final String initialRoute;

  const AgriConnectApp({
    super.key,
    required this.initialRoute,
  });

  @override
  State<AgriConnectApp> createState() => _AgriConnectAppState();
}

class _AgriConnectAppState extends State<AgriConnectApp> {
  ThemeMode _mode = ThemeMode.system;

  final ConnectivityService _connectivityService = ConnectivityService();

  void toggleTheme() {
    setState(() {
      _mode =
          _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _connectivityService,
      builder: (context, child) {
        return ThemeScope(
          mode: _mode,
          toggle: toggleTheme,
          child: child!,
        );
      },
      child: MaterialApp(
        title: 'AgriConnect Pro',
        debugShowCheckedModeBanner: false,

        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: _mode,

        /// 🚀 Startup route
        initialRoute: widget.initialRoute,

        /// 🧭 Routes
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/onboarding': (_) => const OnboardingScreen(),

          '/provider-type-selection': (_) =>
              const ProviderTypeSelectionScreen(),

          '/': (_) => const HomeScreen(),
          '/service-provider-home': (_) =>
              const ServiceProviderHomeScreen(),
          '/service-provider-profile': (_) => const ServiceProviderProfileScreen(),

          '/vets': (_) => const VetsScreen(),
          '/suppliers': (_) => const SuppliersScreen(),
          '/market': (_) => const MarketScreen(),
          '/assistant': (_) => const AiChatPage(),
          '/reminders': (_) => const RemindersScreen(),
          '/weather': (_) => const WeatherScreen(),
          '/livestock': (_) => const LivestockScreen(),
          '/community': (_) => const CommunityScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/help': (_) => const HelpScreen(),
        },
      ),
    );
  }
}

/// 🎨 Theme state sharing
class ThemeScope extends InheritedWidget {
  final ThemeMode mode;
  final VoidCallback toggle;

  const ThemeScope({
    super.key,
    required this.mode,
    required this.toggle,
    required super.child,
  });

  static ThemeScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeScope>()!;
  }

  @override
  bool updateShouldNotify(ThemeScope oldWidget) =>
      oldWidget.mode != mode;
}