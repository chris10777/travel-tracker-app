import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/city_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/global_places_provider.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 ENV laden (optional – darf die App NICHT crashen)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ dotenv not loaded: $e');
  }

  // 🔥 Firebase INIT
  await Firebase.initializeApp();

  // 📦 Cities laden
  final cityProvider = CityProvider();
  await cityProvider.loadCities();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: cityProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        // 🌍 OSM Places Provider (GLOBAL, WICHTIG)
        ChangeNotifierProvider(
          create: (_) => GlobalPlacesProvider.instance,
        ),
      ],
      child: const TravelTrackerApp(),
    ),
  );
}

class TravelTrackerApp extends StatelessWidget {
  const TravelTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Favorite Place',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: AuthGate(),
    );
  }
}
