import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PelangganPage extends StatefulWidget {
  const PelangganPage({Key? key}) : super(key: key);

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  List<dynamic> pelangganList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  Future<void> fetchPelanggan() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse("http://192.168.100.65:8000/api/customer/getAll"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("DEBUG API RESPONSE: $data");
        setState(() {
          pelangganList =
              data; // pastikan API mengembalikan array list pelanggan
          isLoading = false;
        });
      } else {
        print("Gagal ambil data pelanggan: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> hapusPelanggan(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("http://192.168.100.65:8000/api/customer/delete/$id"),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pelanggan berhasil dihapus")),
        );
        fetchPelanggan(); // refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus pelanggan")),
        );
      }
    } catch (e) {
      print("Error hapus: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Pelanggan", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF270650), Color(0xFFFF30BA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pelangganList.isEmpty
              ? const Center(child: Text("Belum ada pelanggan"))
              : ListView.builder(
                  itemCount: pelangganList.length,
                  itemBuilder: (context, index) {
                    final pelanggan = pelangganList[index];
                    return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: const Icon(Icons.person,
                              color: Color(0xFFFF30BA)),
                          title: Text(
                            pelanggan['nama'] ?? 'Tanpa Nama',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "No HP: ${pelanggan['no_hp'] ?? '-'}\n"
                            "Alamat: ${pelanggan['alamat'] ?? '-'}",
                          ),
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text("Hapus Pelanggan"),
                                  content: Text(
                                      "Yakin ingin menghapus ${pelanggan['nama']}?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("Batal"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        hapusPelanggan(pelanggan['id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: const Text("Hapus"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ));
                  },
                ),
    );
  }
}
