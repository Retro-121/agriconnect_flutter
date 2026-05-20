import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../services/email_service.dart';
import '../widgets/phone_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _loadingText = 'Logging in...';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
      });
    }
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please enter both email and password');
      return;
    }

    // Email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showSnack('Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingText = 'Verifying email existence...';
    });

    try {
      // 1. Verify if Gmail exists (Simulation)
      final exists = await EmailService.verifyEmailExists(email);
      if (!exists) {
        setState(() => _isLoading = false);
        _showSnack('This email does not seem to exist. Please use a real Gmail.');
        return;
      }

      // 2. Check registration in local storage
      final prefs = await SharedPreferences.getInstance();
      List<String> registeredEmails = prefs.getStringList('registered_emails') ?? [];
      if (!registeredEmails.contains(email)) {
        setState(() => _isLoading = false);
        _showSnack('Email not registered. Please sign up first.');
        return;
      }

      setState(() => _loadingText = 'Sending login notification...');
      
      // 3. Send Login Notification (Simulation)
      await EmailService.sendLoginNotification(email);

      // 4. Save credentials for persistence
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      
      final storedName = prefs.getString('user_name_$email');
      await prefs.setString('userName', storedName ?? email);
      
      if (!mounted) return;
      
      // Check if onboarded
      final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
      if (hasOnboarded) {
        // If they changed their role in a previous session, we might want to route differently
        // For now, let's go to role selection or home based on saved role
        final savedRole = prefs.getString('userRole');
        if (savedRole == 'Service Provider') {
          Navigator.pushReplacementNamed(context, '/service-provider-home');
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (e) {
      _showSnack('An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PhoneShell(
      hideTabs: true,
      bgImage: 'assets/backgrounds/bg_field.jpg',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('AgriConnect Pro',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: leaf)),
                      const SizedBox(height: 8),
                      const Text('Smart Farming Ecosystem', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: leaf,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isLoading ? null : _login,
                          child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account?'),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/signup'),
                            child: const Text('Sign Up', style: TextStyle(color: leaf, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 8),
                Text(_loadingText, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

