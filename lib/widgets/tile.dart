import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  const Tile({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.color, this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: child,
    );
  }
}
