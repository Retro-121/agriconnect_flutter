import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../services/email_service.dart';
import '../widgets/phone_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _loadingText = 'Creating account...';

  void _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack('Please fill all fields');
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

      // 2. Simulate signup logic
      final prefs = await SharedPreferences.getInstance();
      
      setState(() => _loadingText = 'Sending welcome email...');
      await EmailService.sendWelcomeEmail(email, name);

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', name);
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      
      // Save to registered emails list and store name mapping
      List<String> registeredEmails = prefs.getStringList('registered_emails') ?? [];
      if (!registeredEmails.contains(email)) {
        registeredEmails.add(email);
        await prefs.setStringList('registered_emails', registeredEmails);
      }
      await prefs.setString('user_name_$email', name);
      
      if (!mounted) return;
      
      // After signup, take user to onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
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
                      const Text('Create Account',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: leaf)),
                      const SizedBox(height: 8),
                      const Text('Join AgriConnect Pro today', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          onPressed: _isLoading ? null : _signup,
                          child: const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Already have an account? Login', style: TextStyle(color: leaf)),
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

