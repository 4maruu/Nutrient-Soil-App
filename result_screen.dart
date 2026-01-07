import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // --- PEMBETULAN 1: TUKAR PATH KE 'soil' ---
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref().child('soil');

  // 1. LOGIC CADANGAN TANAH
  Map<String, dynamic> getSoilAdvice(double n, double p, double k, double ph) {
    if (ph < 4.0) {
      return {
        "status": "TOO ACIDIC",
        "crop": "Pineapple / Rubber",
        "action": "Apply GML (Liming) to raise pH levels.",
        "color": Colors.red[800]
      };
    } else if (ph < 6.0) {
      return {
        "status": "ACIDIC SOIL",
        "crop": "Legumes (Beans/Peas)",
        "action": "Add Urea or organic compost to boost Nitrogen.",
        "color": Colors.red[800]
      };
    } else if (ph >= 6.0 && ph <= 7.0 && n >= 50) {
      return {
        "status": "IDEAL CONDITION",
        "crop": "Paddy / Corn",
        "action": "Soil is fertile. Maintain current irrigation.",
        "color": Colors.green[800]
      };
    } else {
      return {
        "status": "GENERAL FERTILE",
        "crop": "Leafy Vegetables",
        "action": "Standard fertilizer maintenance required.",
        "color": Colors.blue[800]
      };
    }
  }

  // 2. FUNGSI SIMPAN KE HISTORY
  Future<void> saveToHistory(double n, double p, double k, double ph) async {
    try {
      await FirebaseFirestore.instance.collection('history').add({
        'nitrogen': n,
        'phosphorus': p,
        'potassium': k,
        'ph': ph,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data saved to history!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soil Analysis Dashboard"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: _sensorRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          
          // Debugging: Papar Error jika ada
          if (snapshot.hasError) {
            return Center(child: Text("Firebase Error: ${snapshot.error}"));
          }

          // Check loading state
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Waiting for data from ESP32..."),
                  Text("(Checking path: /soil)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          }

          // Extracting data from Firebase
          final Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          // --- PEMBETULAN 2: PASTIKAN NAMA KEY SAMA DENGAN FIREBASE ---
          // Firebase Console anda tunjuk: N, P, K (Huruf Besar) & ph, moisture, temperature (Huruf Kecil)
          String nStr = data['N']?.toString() ?? "0"; 
          String pStr = data['P']?.toString() ?? "0";
          String kStr = data['K']?.toString() ?? "0";
          String phStr = data['ph']?.toString() ?? "0";
          String moistureStr = data['moisture']?.toString() ?? "0";
          String tempStr = data['temperature']?.toString() ?? "0";

          // Convert untuk logic
          double valN = double.tryParse(nStr) ?? 0;
          double valP = double.tryParse(pStr) ?? 0;
          double valK = double.tryParse(kStr) ?? 0;
          double valPH = double.tryParse(phStr) ?? 0;

          // Get recommendation based on logic
          final advice = getSoilAdvice(valN, valP, valK, valPH);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- DYNAMIC STATUS CARD ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: advice['color'], 
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        advice['status']!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 10),
                      const Text("Recommended Crop:", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(
                        advice['crop']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.white30, height: 25),
                      Text(
                        "Action: ${advice['action']!}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                
                const Text("Live Sensor Readings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // --- SENSOR GRID ---
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildNutrientCard("Nitrogen (N)", nStr, Icons.grass, Colors.blue),
                    _buildNutrientCard("Phosphorus (P)", pStr, Icons.scatter_plot, Colors.orange),
                    _buildNutrientCard("Potassium (K)", kStr, Icons.local_florist, Colors.purple),
                    _buildNutrientCard("pH Level", phStr, Icons.science, Colors.red),
                    _buildNutrientCard("Moisture", "$moistureStr%", Icons.water_drop, Colors.cyan),
                    _buildNutrientCard("Temperature", "$tempStr°C", Icons.thermostat, Colors.teal),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // --- BUTTONS ---
                ElevatedButton.icon(
                  onPressed: () => saveToHistory(valN, valP, valK, valPH),
                  icon: const Icon(Icons.save),
                  label: const Text("SAVE RECORD TO HISTORY"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Pastikan route '/history' wujud di main.dart
                      Navigator.pushNamed(context, '/history');
                    },
                    icon: const Icon(Icons.show_chart),
                    label: const Text("VIEW HISTORY & TRENDS"),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(15)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                       // Pastikan route '/testing' wujud jika mahu refresh
                       Navigator.pushReplacementNamed(context, '/testing');
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("START NEW TEST"),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // HELPER WIDGET FOR GRID CARDS
  Widget _buildNutrientCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}