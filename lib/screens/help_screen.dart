import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../widgets/phone_shell.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedFaq;
  bool _showTutorials = false;
  bool _showPrivacy = false;

  final String supportEmail = 'agriconnect@gmail.com';
  final String supportPhone = '+255766999725';

  static const _faqs = [
    {
      'q': 'How do I edit my farm details?',
      'a': 'Go to Profile → Farm Settings. You can edit your farm type, acreage, and number of animals there.',
    },
    {
      'q': 'Does the app work without internet?',
      'a': 'Yes! Enable Offline Mode in your Profile. Cached data (weather, market prices, AI responses) will remain available.',
    },
    {
      'q': 'How do I change the app language?',
      'a': 'Go to Profile → Language. You can switch between English and Kiswahili at any time.',
    },
    {
      'q': 'Can the AI assistant help with livestock diseases?',
      'a': 'Absolutely. The AI assistant is trained on agricultural topics including livestock health, crop diseases, and market guidance. Describe your issue and it will give practical advice.',
    },
    {
      'q': 'How do I book a vet visit?',
      'a': 'Tap "Vets" on the home screen. You can browse available vets, view their specialties, and request a visit.',
    },
  ];

  static const _tutorials = [
    {
      'title': 'Adding Livestock',
      'desc': 'Go to the Livestock screen and tap the + button to add a new category of cattle. You can edit health and vaccination stats anytime.',
    },
    {
      'title': 'Using the AI Coach',
      'desc': 'Tap the AI icon on the home screen. You can type questions or upload pictures (using the camera icon) of sick crops/animals for analysis.',
    },
    {
      'title': 'Setting Task Reminders',
      'desc': 'Go to Reminders and tap +. Add your task, set the time, and the app will notify you when it\'s due.',
    },
  ];

  static const _emergencies = [
    {'name': 'National Vet Emergency Hotline', 'phone': '0800 110 110'},
    {'name': 'Agricultural Extension Services', 'phone': '0800 110 111'},
  ];

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchEmail(String email, {String subject = 'AgriConnect Pro Support Request'}) async {
    final uri = Uri(scheme: 'mailto', path: email, queryParameters: {
      'subject': subject,
    });
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/${phone.replaceAll('+', '')}?text=Hello%2C%20I%20need%20help%20with%20AgriConnect%20Pro.');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: leaf, size: 22),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PhoneShell(
      title: 'Help & Support',
      showBack: true,
      showThemeToggle: true,
      bgImage: 'assets/backgrounds/bg-home.jpg',
      bgImageDark: 'assets/backgrounds/bg-home-dark.jpg',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // ── 1. FAQs ─────────────────────────────────────────────
          _buildSectionHeader('FAQs', Icons.question_answer_outlined),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: List.generate(_faqs.length, (i) {
                final faq = _faqs[i];
                final isExpanded = _expandedFaq == i;
                return Column(
                  children: [
                    if (i > 0) const Divider(height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(faq['q']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      trailing: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                      onTap: () => setState(() => _expandedFaq = isExpanded ? null : i),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(faq['a']!, style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor, height: 1.5)),
                      ),
                      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ],
                );
              }),
            ),
          ),

          // ── 2. Tutorials & Guides ────────────────────────────────
          _buildSectionHeader('Tutorials & Guides', Icons.menu_book_outlined),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('View App Tutorials', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: AnimatedRotation(
                    turns: _showTutorials ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                  onTap: () => setState(() => _showTutorials = !_showTutorials),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _tutorials.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(t['desc']!, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  crossFadeState: _showTutorials ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),

          // ── 3. Contact Support ───────────────────────────────────
          _buildSectionHeader('Contact Support', Icons.support_agent),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                const Text('Reach out if you have any issues or feedback. We are here to help!', 
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _contactBtn(Icons.call, 'Call', Colors.green, () => _launchPhone(supportPhone)),
                    const SizedBox(width: 8),
                    _contactBtn(Icons.chat, 'WhatsApp', const Color(0xFF25D366), () => _launchWhatsApp(supportPhone)),
                    const SizedBox(width: 8),
                    _contactBtn(Icons.email_outlined, 'Email', Colors.blue, () => _launchEmail(supportEmail)),
                  ],
                ),
              ],
            ),
          ),

          // ── 4 & 5. Report a Problem & Feedback ───────────────────
          _buildSectionHeader('Help Improve the App', Icons.bug_report_outlined),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.report_problem_outlined, color: Colors.orange),
                  title: const Text('Report a Problem', style: TextStyle(fontSize: 14)),
                  subtitle: Text('Found a bug? Let us know.', style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _launchEmail(supportEmail, subject: 'Bug Report: AgriConnect Pro'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined, color: Colors.blue),
                  title: const Text('Feedback & Suggestions', style: TextStyle(fontSize: 14)),
                  subtitle: Text('Share your ideas with us.', style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _launchEmail(supportEmail, subject: 'App Feedback: AgriConnect Pro'),
                ),
              ],
            ),
          ),

          // ── 6. Emergency Contacts ────────────────────────────────
          _buildSectionHeader('Emergency Contacts', Icons.local_hospital_outlined),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: List.generate(_emergencies.length, (i) {
                final em = _emergencies[i];
                return Column(
                  children: [
                    if (i > 0) const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.phone_in_talk, color: Colors.redAccent),
                      title: Text(em['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      subtitle: Text(em['phone']!, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _launchPhone(em['phone']!),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          // ── 7 & 8. Privacy Policy & About App ────────────────────
          _buildSectionHeader('Legal & Info', Icons.info_outline),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Privacy Policy & Terms', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: AnimatedRotation(
                    turns: _showPrivacy ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                  onTap: () => setState(() => _showPrivacy = !_showPrivacy),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'Your data is stored securely and used only to improve your farming experience. '
                      'We do not share your location or farm details with third parties without your consent.\n\n'
                      'For inquiries regarding our policy, please contact us at:\n'
                      'Email: $supportEmail\n'
                      'Phone: $supportPhone',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor, height: 1.4),
                    ),
                  ),
                  crossFadeState: _showPrivacy ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // ── Footer / About App ───────────────────────────────────
          Center(
            child: Column(
              children: [
                Image.asset('assets/backgrounds/casual_farm_bg.png', height: 40, width: 40, fit: BoxFit.cover),
                const SizedBox(height: 8),
                const Text('AgriConnect Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Version 1.0.0\nBuilt to empower modern farmers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _contactBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
