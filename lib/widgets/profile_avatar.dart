import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final Color backgroundColor;
  final Color iconColor;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 24,
    this.backgroundColor = const Color(0xFF2E7D32),
    this.iconColor = Colors.white,
  });

  Widget _buildFallback(BuildContext context) {
    final displayText = (initials ?? '').trim();
    if (displayText.isNotEmpty) {
      return Text(
        displayText,
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      );
    }

    return Icon(
      Icons.person,
      color: iconColor,
      size: radius * 0.9,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: ClipOval(
          child: Image.network(
            imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: radius * 0.8,
                  height: radius * 0.8,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: iconColor,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(child: _buildFallback(context));
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: _buildFallback(context),
    );
  }
}
