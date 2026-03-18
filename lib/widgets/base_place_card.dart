import 'package:flutter/material.dart';

class BasePlaceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const BasePlaceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: Icon(
            isActive ? Icons.check : Icons.add,
            color: isActive ? Colors.green : null,
          ),
          onPressed: onToggle,
        ),
        onTap: onTap,
      ),
    );
  }
}
