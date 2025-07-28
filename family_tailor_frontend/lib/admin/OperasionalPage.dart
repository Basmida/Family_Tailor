import 'package:family_tailor_frontend/CreateData/TambahOperasional.dart';
import 'package:family_tailor_frontend/model/operasionalModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OperasionalPage extends StatefulWidget {
  const OperasionalPage({Key? key}) : super(key: key);

  @override
  _OperasionalPageState createState() => _OperasionalPageState();
}

class _OperasionalPageState extends State<OperasionalPage> {
  late Future<List<Operasional>> operasionalList;

  @override
  void initState() {
    super.initState();
    operasionalList = fetchOperasional();
  }

  Future<List<Operasional>> fetchOperasional() async {
    final response = await http.get(Uri.parse('http://192.168.100.65:8000/api/operasional'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Operasional> allData = data.map((item) => Operasional.fromJson(item)).toList();

      // Urutkan berdasarkan tanggal terbaru
      allData.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return allData;
    } else {
      throw Exception('Gagal memuat data operasional');
    }
  }

  Widget buildOperasionalCard(String title, List<Operasional> items, Color color) {
    // Kelompokkan berdasarkan tanggal
    Map<String, List<Operasional>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.tanggal, () => []).add(item);
    }

    // Urutkan tanggal dari terbaru ke terlama
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // descending

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              const Divider(thickness: 1),

              // Tampilkan berdasarkan tanggal
              ...sortedDates.map((date) {
                final itemsByDate = grouped[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      date,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    ...itemsByDate.map((item) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.namaItem),
                        subtitle: item.keterangan != null ? Text(item.keterangan!) : null,
                        trailing: Text(
                          '${item.jenisOperasional == 'pemasukan' ? '+Rp' : '-Rp'}${item.nominal.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: item.jenisOperasional == 'pemasukan'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    const Divider(thickness: 1), // PEMISAH ANTAR TANGGAL
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Operasional", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF270650), Color(0XffFF30BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Operasional>>(
        future: operasionalList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data operasional.'));
          }

          final pemasukan = snapshot.data!
              .where((item) => item.jenisOperasional == 'pemasukan')
              .toList();
          final pengeluaran = snapshot.data!
              .where((item) => item.jenisOperasional == 'pengeluaran')
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                buildOperasionalCard("PEMASUKAN", pemasukan, Colors.green),
                buildOperasionalCard("PENGELUARAN", pengeluaran, Colors.red),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahOperasional()),
          );
          if (result != null) {
            setState(() {
              operasionalList = fetchOperasional(); // refresh data
            });
          }
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
