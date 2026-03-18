import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cities_screen.dart';
import 'email_auth_screen.dart';


class AuthGate extends StatefulWidget {
  AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _continueAsGuest = false;

  @override
  Widget build(BuildContext context) {
    // 👤 Gast → direkt App
    if (_continueAsGuest) {
      return const CitiesScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔐 Eingeloggt → App
        if (snapshot.data != null) {
          return const CitiesScreen();
        }

        // 🔓 Nicht eingeloggt → Auth Screen
        return EmailAuthScreen(
          onContinueAsGuest: () {
            setState(() {
              _continueAsGuest = true;
            });
          },
        );
      },
    );
  }
}
