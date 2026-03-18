import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/sync_status_tile.dart';

import 'auth_gate.dart';
import 'imprint_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ─────────────────────────────────────
        // TITLE
        // ─────────────────────────────────────
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // ─────────────────────────────────────
        // ☁️ SYNC STATUS
        // ─────────────────────────────────────
        const Card(
          child: SyncStatusTile(),
        ),

        const SizedBox(height: 24),

        // ─────────────────────────────────────
        // 🌗 Appearance
        // ─────────────────────────────────────
        Card(
          child: ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Appearance'),
            subtitle: Text('Theme: ${themeProvider.themeLabel}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openThemeSheet(context),
          ),
        ),

        const SizedBox(height: 12),

        // ─────────────────────────────────────
        // 🔐 Account (AUTH GATE!)
        // ─────────────────────────────────────
        Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account'),
            subtitle: const Text('Login & security'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AuthGate(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // ─────────────────────────────────────
        // 📄 Legal
        // ─────────────────────────────────────
        const Text(
          'Legal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Imprint'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ImprintScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
        ),

        // ─────────────────────────────────────
        // VERSION
        // ─────────────────────────────────────
        const SizedBox(height: 32),

        Center(
          child: Text(
            'Version v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade500
                  : Colors.grey.shade600,
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // THEME BOTTOM SHEET
  // ─────────────────────────────────────────────

  void _openThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _themeOption(
                context,
                icon: Icons.settings,
                label: 'System',
                onTap: () {
                  themeProvider.setTheme(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              _themeOption(
                context,
                icon: Icons.light_mode,
                label: 'Light',
                onTap: () {
                  themeProvider.setTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              _themeOption(
                context,
                icon: Icons.dark_mode,
                label: 'Dark',
                onTap: () {
                  themeProvider.setTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _themeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
