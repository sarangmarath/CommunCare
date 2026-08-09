import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fqvgavskxzvqfihzzdlz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxdmdhdnNreHp2cWZpaHp6ZGx6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUxNDkxNTgsImV4cCI6MjEwMDcyNTE1OH0.EOzWZdTz3Y96GnTXjZlOQITYqtISGi6L3SN6gp2yr_A',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

// Forest green palette
const kForestGreen = Color(0xFF1B4332);
const kMidGreen = Color(0xFF2D6A4F);
const kLightGreen = Color(0xFF95D5B2);
const kBackground = Color(0xFFF4F7F5);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CommunCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kForestGreen,
          primary: kForestGreen,
          secondary: kMidGreen,
        ),
        scaffoldBackgroundColor: kBackground,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: kForestGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kForestGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}