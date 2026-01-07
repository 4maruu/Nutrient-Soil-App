import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import this
import 'package:nutrien_soil_app/screens/history_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/testing_screen.dart';
import 'screens/calibration_screen.dart';
import 'screens/result_screen.dart';


void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Initialize Firebase
  await Firebase.initializeApp(); 
  
  runApp(const MyApp());
}

// ... Keep the rest of MyApp class exactly the same ...
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nutrien Soil App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/pin': (context) => const PinScreen(),
        '/testing': (context) => const TestingScreen(),
        '/calibration': (context) => const CalibrationScreen(),
        '/result': (context) => const ResultScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}