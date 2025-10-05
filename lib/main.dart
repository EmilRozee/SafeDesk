import 'package:flutter/material.dart';
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
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/submit': (context) => const SubmitReportScreen(),
        '/confirmation': (context) => const ConfirmationScreen(),
        '/track': (context) => const TrackReportScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
