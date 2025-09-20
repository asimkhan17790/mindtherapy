import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/mood_provider.dart';
import 'providers/affirmation_provider.dart';
import 'providers/task_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mood_screen.dart';
import 'screens/suggestions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/mood_trends_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // For demo: Skip Firebase and notification setup
  print('🚀 Starting MindTherapy Demo App');
  
  runApp(const MindTherapyApp());
}

class MindTherapyApp extends StatelessWidget {
  const MindTherapyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => AffirmationProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'MindTherapy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          primaryColor: const Color(0xFF6B46C1),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B46C1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/mood': (context) => const MoodScreen(),
          '/suggestions': (context) => const SuggestionsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/trends': (context) => const MoodTrendsScreen(),
        },
      ),
    );
  }
}