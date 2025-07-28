import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LimitPageAdmin extends StatefulWidget {
  const LimitPageAdmin({Key? key}) : super(key: key);

  @override
  State<LimitPageAdmin> createState() => _LimitPageAdminState();
}

class _LimitPageAdminState extends State<LimitPageAdmin> {
  List<dynamic> limitList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLimit();
  }

  Future<void> fetchLimit() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse("http://192.168.100.65:8000/api/limit-produksi"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          limitList = data;
          isLoading = false;
        });
      } else {
        print("Gagal ambil data limit: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> tambahAtauEditLimit({int? id}) async {
    TextEditingController bulanController = TextEditingController();
    TextEditingController tahunController = TextEditingController();
    TextEditingController limitController = TextEditingController();

    if (id != null) {
      // Saat edit, isi data lama ke dalam TextField
      final item = limitList.firstWhere((e) => e['id'] == id);
      bulanController.text = item['bulan'].toString();
      tahunController.text = item['tahun'].toString();
      limitController.text = item['jumlah_limit'].toString();
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(id == null ? "Tambah Limit Baru" : "Edit Limit"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: bulanController,
                  decoration: const InputDecoration(labelText: "Bulan (1-12)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: tahunController,
                  decoration: const InputDecoration(labelText: "Tahun (yyyy)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: limitController,
                  decoration:
                      const InputDecoration(labelText: "Limit Produksi"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (bulanController.text.isEmpty ||
                    tahunController.text.isEmpty ||
                    limitController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semua field wajib diisi!")),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final body = {
                  "bulan": bulanController.text,
                  "tahun": tahunController.text,
                  "jumlah_limit": limitController.text,
                };

                try {
                  final url = id == null
                      ? "http://192.168.100.65:8000/api/limit-produksi"
                      : "http://192.168.100.65:8000/api/limit-produksi/$id";

                  final response = await (id == null
                      ? http.post(
                          Uri.parse(url),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(body),
                        )
                      : http.put(
                          Uri.parse(url),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(body),
                        ));

                  print("Status: ${response.statusCode}");
                  print("Response: ${response.body}");

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(id == null
                              ? "Limit berhasil ditambahkan"
                              : "Limit berhasil diupdate")),
                    );
                    fetchLimit();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal menyimpan limit")),
                    );
                  }
                } catch (e) {
                  print("Error tambah/edit: $e");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: Text(id == null ? "Simpan" : "Update"),
            ),
          ],
        );
      },
    );
  }

  Future<void> hapusLimit(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("http://192.168.100.65:8000/api/limit-produksi/$id"),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Limit berhasil dihapus")),
        );
        fetchLimit();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus limit")),
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
        title:
            const Text("Limit Produksi", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF270650), Color(0xFFFF30BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : limitList.isEmpty
              ? const Center(child: Text("Belum ada limit"))
              : ListView.builder(
                  itemCount: limitList.length,
                  itemBuilder: (context, index) {
                    final limit = limitList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          "${limit['bulan']} - ${limit['tahun']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text("Limit: ${limit['jumlah_limit']} pesanan"),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              tambahAtauEditLimit(id: limit['id']);
                            } else if (value == 'hapus') {
                              hapusLimit(limit['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.pink),
                                  SizedBox(width: 8),
                                  Text("Edit"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'hapus',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.redAccent),
                                  SizedBox(width: 8),
                                  Text("Hapus"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFF30BA),
        child: const Icon(Icons.add, color: Color(0xFF270650),),
        onPressed: () {
          tambahAtauEditLimit();
        },
      ),
    );
  }
}
