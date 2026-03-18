import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../providers/city_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final cityProvider = Provider.of<CityProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text('Email: ${user.email}', style: const TextStyle(fontSize: 16)),
              Text('Provider: ${user.providerData.first.providerId}'),
              const SizedBox(height: 12),
              Text('Last Sync: ${cityProvider.lastSync ?? 'never'}'),
              if (cityProvider.lastSyncError != null)
                Text('Sync Error: ${cityProvider.lastSyncError}', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
                child: const Text('Logout'),
              ),
            ] else ...[
              const Text('You are using the app without login.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Login now'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
