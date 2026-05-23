import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import '../widgets/phone_shell.dart';

final supabase = Supabase.instance.client;

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

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack('Please fill all fields');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showSnack('Enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingText = 'Creating account...';
    });

    try {
      /// 🔐 REAL SUPABASE SIGNUP
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        _showSnack('Signup failed');
        return;
      }

      setState(() {
        _loadingText = 'Sending verification email...';
      });

      /// 💾 Save minimal local data (NO PASSWORDS)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
      await prefs.setString('user_name', name);
      await prefs.setString('userName', name);
      await prefs.setBool('isLoggedIn', false);

      /// 🚦 Optional: store role placeholder
      await prefs.setString('userRole', 'Farmer');

      if (!mounted) return;

      /// 📩 Inform user to verify email
      _showSnack('Check your email to verify your account');

      /// 👉 Send them to login page
      Navigator.pushReplacementNamed(context, '/login');
    } on AuthException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Signup failed. Try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: leaf,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join AgriConnect Pro today',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      /// NAME
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

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

                      /// SIGNUP BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
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
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Already have an account? Login',
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