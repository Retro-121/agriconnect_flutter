import 'dart:async';

class EmailService {
  /// Simulates verifying if a Gmail address actually exists.
  /// In a real app, this would call an API or use SMTP VRFY.
  static Future<bool> verifyEmailExists(String email) async {
    // Artificial delay to simulate network request
    await Future.delayed(const Duration(seconds: 2));

    // For this simulation:
    // 1. Must be a valid format (handled by regex in UI)
    // 2. We'll reject common "fake" strings for demo purposes
    final lowercaseEmail = email.toLowerCase();
    if (lowercaseEmail.contains('test@') || 
        lowercaseEmail.contains('fake') || 
        lowercaseEmail.startsWith('abc@')) {
      return false;
    }

    // Treat all other well-formatted gmails as "existing"
    return true;
  }

  /// Simulates sending a login notification email.
  static Future<void> sendLoginNotification(String email) async {
    // Artificial delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // In a real app, you'd use a service like SendGrid, Mailgun, or Firebase Functions.
    print('DEBUG: Sending login notification to $email...');
    print('DEBUG: Content: "Hello! A new login was detected on your AgriConnect Pro account."');
  }

  /// Simulates sending a welcome email after signup.
  static Future<void> sendWelcomeEmail(String email, String name) async {
    await Future.delayed(const Duration(seconds: 2));
    print('DEBUG: Sending welcome email to $email...');
    print('DEBUG: Content: "Welcome $name to AgriConnect Pro! We are glad to have you."');
  }
}
