import 'package:flutter/material.dart';
import 'dart:async';


class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  String statusText = "Connecting to Sensors...";
  double progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    startSimulation();
  }

  void startSimulation() {
    // Simulate a 5-second process of reading NPK sensors
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        progressValue += 0.2;
        if (progressValue >= 0.4) statusText = "Reading NPK Values...";
        if (progressValue >= 0.7) statusText = "Analyzing Soil Moisture...";
        if (progressValue >= 1.0) {
          timer.cancel();
          Navigator.pushReplacementNamed(context, '/calibration');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network('https://cdn-icons-png.flaticon.com/512/2823/2823521.png', height: 150), // Soil Icon
            const SizedBox(height: 30),
            Text(statusText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: LinearProgressIndicator(
                value: progressValue,
                color: Colors.green,
                backgroundColor: Colors.green[100],
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}