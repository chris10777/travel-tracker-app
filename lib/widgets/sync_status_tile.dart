import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/city_provider.dart';
import '../utils/time_formatter.dart';

class SyncStatusTile extends StatelessWidget {
  const SyncStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CityProvider>(context);

    // 🔓 Nicht eingeloggt
    if (!provider.isLoggedIn) {
      return const ListTile(
        leading: Icon(Icons.cloud_off, color: Colors.grey),
        title: Text('Cloud sync disabled'),
        subtitle: Text('Sign in to enable cloud backup'),
      );
    }

    // 🔄 Sync läuft
    if (provider.syncing) {
      return const ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Syncing…'),
        subtitle: Text('Uploading your cities'),
      );
    }

    // ❌ Fehler
    if (provider.lastSyncError != null) {
      return ListTile(
        leading: const Icon(Icons.cloud_off, color: Colors.red),
        title: const Text('Sync failed'),
        subtitle: Text(provider.lastSyncError!),
      );
    }

    // ✅ Erfolgreich
    if (provider.lastSync != null) {
      return ListTile(
        leading: const Icon(Icons.cloud_done, color: Colors.green),
        title: const Text('Cloud sync active'),
        subtitle: Text(
          'Last synced ${formatLastSync(provider.lastSync!)}',
        ),
      );
    }

    // 🟢 Bereit, aber noch kein Sync
    return const ListTile(
      leading: Icon(Icons.cloud_queue),
      title: Text('Cloud sync ready'),
      subtitle: Text('Waiting for changes'),
    );
  }
}
