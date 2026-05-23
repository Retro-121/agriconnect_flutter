import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import '../widgets/phone_shell.dart';

final supabase = Supabase.instance.client;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _loadingText = 'Logging in...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuthState();
    }
  }

  Future<void> _checkAuthState() async {
    final session = supabase.auth.currentSession;
    final user = session?.user;

    if (user != null && user.emailConfirmedAt != null) {
      final prefs = await SharedPreferences.getInstance();
      final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
      final userRole = prefs.getString('userRole') ?? 'Farmer';

      if (!mounted) return;

      if (!hasOnboarded) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else if (userRole == 'Service Provider') {
        Navigator.pushReplacementNamed(context, '/service-provider-home');
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please enter email and password');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showSnack('Enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingText = 'Signing you in...';
    });

    try {
      /// 🔐 REAL SUPABASE LOGIN
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        _showSnack('Invalid login credentials');
        return;
      }

      /// 🔐 CHECK EMAIL VERIFICATION
      if (user.emailConfirmedAt == null) {
        await supabase.auth.signOut();
        _showSnack('Please verify your email before logging in');
        return;
      }

      /// 💾 Save minimal local UI state (NO PASSWORD STORAGE)
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString('userName') ?? prefs.getString('user_name');
      final displayName = cachedName?.isNotEmpty == true ? cachedName! : (user.email?.split('@').first ?? email);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('saved_email', email);
      await prefs.setString('userName', displayName);

      if (!mounted) return;

      /// 🚦 ROUTING LOGIC (your existing system)
      final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
      final userRole = prefs.getString('userRole') ?? 'Farmer';

      if (!hasOnboarded) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        if (userRole == 'Service Provider') {
          Navigator.pushReplacementNamed(
              context, '/service-provider-home');
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } on AuthException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Login failed. Try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PhoneShell(
      hideTabs: true,
      bgImage: 'assets/backgrounds/bg_field.jpg',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'AgriConnect Pro',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: leaf,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Smart Farming Ecosystem',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      /// EMAIL
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// PASSWORD
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: leaf,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// SIGNUP LINK
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          'Don’t have an account? Sign Up',
                          style: TextStyle(color: leaf),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isLoading) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  _loadingText,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}