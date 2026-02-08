import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bgColor;
  final Color iconColor;

  const SocialIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.bgColor = Colors.white,
    this.iconColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FaIcon(icon, size: 32, color: iconColor),
        ),
      ),
    );
  }
}
