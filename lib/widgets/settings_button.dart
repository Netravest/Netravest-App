import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final Color iconColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SettingsButton({
    super.key,
    required this.color,
    required this.textColor,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 100),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
