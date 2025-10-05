import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/submit_report_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/track_report_screen.dart';
import 'screens/about_screen.dart';

void main() {
  runApp(const SafeDeskApp());
}

class SafeDeskApp extends StatelessWidget {
  const SafeDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeDesk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ).copyWith(
          primary: Colors.red.shade800,
          secondary: Colors.pink.shade300,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.red.shade800,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade800,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/submit': (context) => const SubmitReportScreen(),
        '/confirmation': (context) => const ConfirmationScreen(),
        '/track': (context) => const TrackReportScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
