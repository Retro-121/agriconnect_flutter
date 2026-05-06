import 'package:flutter/material.dart';
import '../main.dart';

class PhoneShell extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool showBack;
  final bool hideTabs;
  final String bgImage; // light asset path
  final String? bgImageDark;
  final bool showThemeToggle;

  const PhoneShell({
    super.key,
    required this.bgImage,
    this.bgImageDark,
    this.title,
    required this.child,
    this.showBack = false,
    this.hideTabs = false,
    this.showThemeToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark && bgImageDark != null ? bgImageDark! : bgImage;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(activeBg, fit: BoxFit.cover),
            ),
          ),
          // Gradient overlay for readability
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
                if (title != null || showBack || showThemeToggle)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Row(
                      children: [
                        if (showBack)
                          _circleBtn(context, Icons.arrow_back,
                              () => Navigator.of(context).maybePop()),
                        if (showBack) const SizedBox(width: 12),
                        if (title != null)
                          Expanded(
                            child: Text(title!,
                                style: Theme.of(context).textTheme.headlineMedium),
                          ),
                        if (showThemeToggle)
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
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: hideTabs ? null : _buildTabs(context),
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
          height: 40, width: 40,
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '/';
    final tabs = const [
      _Tab('/', Icons.home_outlined, 'Home'),
      _Tab('/market', Icons.bar_chart, 'Market'),
      _Tab('/reminders', Icons.notifications_outlined, 'Tasks'),
      _Tab('/community', Icons.chat_bubble_outline, 'Talk'),
      _Tab('/profile', Icons.person_outline, 'Me'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((t) {
          final active = route == t.route;
          return Expanded(
            child: InkWell(
              onTap: () {
                if (!active) Navigator.of(context).pushReplacementNamed(t.route);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 36, width: 48,
                    decoration: BoxDecoration(
                      color: active ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(t.icon,
                        size: 18,
                        color: active
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).hintColor),
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
