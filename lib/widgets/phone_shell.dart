import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/connectivity_service.dart';

class PhoneShell extends StatefulWidget {
  final String? title;
  final Widget child;
  final bool showBack;
  final bool hideTabs;
  final String? bgImage;
  final String? bgImageDark;
  final bool showThemeToggle;
  final Widget? floatingActionButton;

  const PhoneShell({
    super.key,
    this.bgImage,
    this.bgImageDark,
    this.title,
    required this.child,
    this.showBack = false,
    this.hideTabs = false,
    this.showThemeToggle = false,
    this.floatingActionButton,
  });

  @override
  State<PhoneShell> createState() => _PhoneShellState();
}

class _PhoneShellState extends State<PhoneShell> {
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? 'English';
    if (mounted) {
      setState(() {
        _language = language;
      });
    }
  }

  String t(String en, String sw) => _language == 'Kiswahili' ? sw : en;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = widget.bgImage != null
        ? (isDark && widget.bgImageDark != null ? widget.bgImageDark! : widget.bgImage!)
        : (isDark ? 'assets/backgrounds/bg-home-dark.jpg' : 'assets/backgrounds/bg-home.jpg');
    final scheme = Theme.of(context).colorScheme;
    final connectivity = ConnectivityService();

    return Scaffold(
      floatingActionButton: widget.floatingActionButton,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(activeBg, fit: BoxFit.cover),
            ),
          ),
          const Positioned.fill(child: DynamicBackgroundOverlay()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.surface.withOpacity(isDark ? 0.3 : 0.5),
                    scheme.surface.withOpacity(0.8),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: connectivity,
                  builder: (context, _) {
                    if (connectivity.isOnline) return const SizedBox.shrink();
                    return Container(
                      width: double.infinity,
                      color: Colors.redAccent.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off, color: Colors.white, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            t('Offline Mode - Progress saved locally', 'Hali ya Nje ya Mtandao - Maendeleo yamehifadhiwa ndani'),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (widget.title != null || widget.showBack || widget.showThemeToggle)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Row(
                      children: [
                        if (widget.showBack)
                          _circleBtn(
                            context,
                            Icons.arrow_back,
                            () => Navigator.of(context).maybePop(),
                          ),
                        if (widget.showBack) const SizedBox(width: 12),
                        if (widget.title != null)
                          Expanded(
                            child: Text(
                              widget.title!,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        if (widget.showThemeToggle)
                          _circleBtn(
                            context,
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            () => ThemeScope.of(context).toggle(),
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.hideTabs ? null : _buildTabs(context),
    );
  }

  Widget _circleBtn(BuildContext c, IconData icon, VoidCallback onTap) {
    return Material(
      color: Theme.of(c).colorScheme.surface.withOpacity(0.8),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '/';
    final tabs = [
      _Tab('/', Icons.home_outlined, t('Home', 'Nyumbani')),
      _Tab('/market', Icons.bar_chart, t('Market', 'Soko')),
      _Tab('/reminders', Icons.notifications_outlined, t('Tasks', 'Kazi')),
      _Tab('/community', Icons.chat_bubble_outline, t('Talk', 'Ongea')),
      _Tab('/profile', Icons.person_outline, t('Me', 'Mimi')),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        border: const Border(top: BorderSide(color: Colors.black12)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((t) {
          final active = route == t.route;
          return Expanded(
            child: InkWell(
              onTap: () {
                if (!active) {
                  Navigator.of(context).pushReplacementNamed(t.route);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 36,
                    width: 48,
                    decoration: BoxDecoration(
                      color: active ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      t.icon,
                      size: 18,
                      color: active ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(t.label, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Tab {
  final String route;
  final IconData icon;
  final String label;

  const _Tab(this.route, this.icon, this.label);
}

class DynamicBackgroundOverlay extends StatefulWidget {
  const DynamicBackgroundOverlay({super.key});

  @override
  State<DynamicBackgroundOverlay> createState() => _DynamicBackgroundOverlayState();
}

class _DynamicBackgroundOverlayState extends State<DynamicBackgroundOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = List.generate(15, (i) => Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particles, _controller.value),
        );
      },
    );
  }
}

class Particle {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double size = Random().nextDouble() * 5 + 2;
  double speed = Random().nextDouble() * 0.02 + 0.01;
  double opacity = Random().nextDouble() * 0.3 + 0.1;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var p in particles) {
      final currentY = (p.y + progress * p.speed) % 1.0;
      final offset = Offset(p.x * size.width, currentY * size.height);
      canvas.drawCircle(offset, p.size, paint..color = Colors.white.withOpacity(p.opacity));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}