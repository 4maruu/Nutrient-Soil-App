import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  bool isCalibrating = false;

  // FUNGSI UNTUK LOGIN & KALIBRASI
  void _runCalibration() async {
    setState(() {
      isCalibrating = true;
    });

    try {
      // 1. PROSES LOGIN ANONYMOUS (PENTING UNTUK PERMISSION)
      // Kita tunggu (await) sehingga login berjaya
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Login Berjaya: ${userCredential.user?.uid}");

      // 2. DELAY SIMULASI KALIBRASI (2 saat)
      await Future.delayed(const Duration(seconds: 2));

      // 3. PINDAH KE RESULT SCREEN
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/result');
      }
    } catch (e) {
      // JIKA GAGAL (Contoh: Tiada Internet)
      setState(() {
        isCalibrating = false;
      });
      
      print("Ralat Login/Kalibrasi: $e");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensor Calibration"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings_input_component, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Prepare for Analysis",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ensure the sensor is clean and inserted into the soil sample. Click below to calibrate and process final data.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            // Menunjukkan loading jika sedang login/kalibrasi
            isCalibrating
                ? Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.green),
                      const SizedBox(height: 15),
                      Text(
                        "Authenticating & Calibrating...",
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                      )
                    ],
                  )
                : ElevatedButton.icon(
                    onPressed: _runCalibration,
                    icon: const Icon(Icons.check_circle),
                    label: const Text("CALIBRATE & VIEW RESULTS"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}