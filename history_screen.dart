import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; 

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sejarah & Trend Analisis"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        // Mengambil data dari Firestore collection 'history'
        stream: FirebaseFirestore.instance
            .collection('history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tiada rekod sejarah dijumpai."));
          }

          var docs = snapshot.data!.docs;

          // Sediakan data untuk Graf pH
          List<FlSpot> phSpots = [];
          for (int i = 0; i < docs.length; i++) {
            // Kita terbalikkan index supaya data lama di kiri, data baru di kanan
            int reverseIndex = (docs.length - 1) - i; 
            double val = (docs[reverseIndex]['ph'] as num).toDouble();
            phSpots.add(FlSpot(i.toDouble(), val));
          }

          return Column(
            children: [
              const SizedBox(height: 10),
              const Text("Trend pH Tanah (Masa ke Semasa)", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              
              // BAHAGIAN GRAF
              Container(
                height: 250,
                padding: const EdgeInsets.all(20),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: phSpots,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 4,
                        belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1)),
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Rekod Terperinci", style: TextStyle(fontWeight: FontWeight.bold)),
              ),

              // SENARAI REKOD
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    // Ambil data secara selamat
                    Map<String, dynamic> data = docs[index].data() as Map<String, dynamic>;
                    
                    var timestamp = data['timestamp'] as Timestamp?;
                    DateTime date = timestamp != null ? timestamp.toDate() : DateTime.now();
                    String formattedDate = DateFormat('dd/MM/yyyy, hh:mm a').format(date);

                    return Card(
                      child: ListTile(
                        title: Text("pH: ${data['ph']} | N: ${data['nitrogen']}"), // Gunakan 'ph' (kecil)
                        subtitle: Text(formattedDate),
                      ),
                    );
                  }
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}