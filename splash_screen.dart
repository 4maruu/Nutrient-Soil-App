import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pergi ke PIN screen selepas 4 saat
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/pin');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Guna Gradient supaya nampak "Premium" macam kod HTML/CSS tadi
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade800, Colors.green.shade400],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- BAHAGIAN LOGO MELOMPAT ---
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.2), 
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco, // Icon seedling/daun
                size: 60,
                color: Colors.white,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true)) 
                .moveY(begin: 0, end: -30, duration: 600.ms, curve: Curves.easeInOut) // Melompat ke atas
                .then()
                .shake(hz: 2, curve: Curves.easeInOut), // Sedikit kesan goyang

            const SizedBox(height: 30),
            
            const Text(
              "NUTRIEN SOIL",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.5, end: 0),
            
            const Text(
              "Smart Classification System",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}