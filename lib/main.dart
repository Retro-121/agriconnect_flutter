import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Supabase FIRST
  await Supabase.initialize(
    url: 'https://rgessxgffhvlfjgfaymm.supabase.co',
    anonKey: 'sb_publishable_n-otmGKdzflvIvnKe24QCQ_RcW7IOS8',
  );

  // 📦 Then SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;

  String initialRoute = '/login';
  if (isLoggedIn) {
    if (hasOnboarded) {
      initialRoute = '/';
    } else {
      initialRoute = '/onboarding';
    }
  }

  runApp(AgriConnectApp(initialRoute: initialRoute));
}

class AgriConnectApp extends StatefulWidget {
  final String initialRoute;
  const AgriConnectApp({super.key, required this.initialRoute});

  @override
  State<AgriConnectApp> createState() => _AgriConnectAppState();
}

class _AgriConnectAppState extends State<AgriConnectApp> {
  ThemeMode _mode = ThemeMode.system;

  void toggle() => setState(() =>
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      mode: _mode,
      toggle: toggle,
      child: MaterialApp(
        title: 'AgriConnect Pro',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: _mode,
        initialRoute: widget.initialRoute,
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/': (_) => const HomeScreen(),
          '/vets': (_) => const VetsScreen(),
          '/suppliers': (_) => const SuppliersScreen(),
          '/market': (_) => const MarketScreen(),
          '/assistant': (_) => const AiChatPage(),
          '/reminders': (_) => const RemindersScreen(),
          '/weather': (_) => const WeatherScreen(),
          '/livestock': (_) => const LivestockScreen(),
          '/community': (_) => const CommunityScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}

class ThemeScope extends InheritedWidget {
  final ThemeMode mode;
  final VoidCallback toggle;

  const ThemeScope({
    super.key,
    required this.mode,
    required this.toggle,
    required super.child,
  });

  static ThemeScope of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<ThemeScope>()!;

  @override
  bool updateShouldNotify(ThemeScope old) => old.mode != mode;
}