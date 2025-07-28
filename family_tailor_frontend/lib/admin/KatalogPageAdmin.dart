import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:family_tailor_frontend/model/KatalogModel.dart';
import 'package:family_tailor_frontend/CreateData/EditKatalog.dart';
import 'package:family_tailor_frontend/CreateData/TambahKatalog.dart';

class KatalogPage extends StatefulWidget {
  const KatalogPage({super.key});

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  // Variabel untuk menyimpan data katalog
  late Future<List<Katalog>> futureKatalog;

  // Fungsi untuk mengambil data katalog
  Future<List<Katalog>> fetchKatalog() async {
  final response = await http.get(Uri.parse('http://192.168.100.65:8000/api/katalog'));

  if (response.statusCode == 200) {
    print('Response body: ${response.body}');  // Tambahkan baris ini untuk memeriksa respons mentah
    try {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Katalog.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error parsing JSON: $e');
    }
  } else {
    throw Exception('Failed to load katalog');
  }
}

  // Inisialisasi future saat halaman pertama kali dimuat
  @override
  void initState() {
    super.initState();
    futureKatalog = fetchKatalog();
  }

  // Fungsi untuk menghapus produk dari katalog
  Future<void> deleteKatalog(int id) async {
    final response = await http.delete(Uri.parse('http://192.168.100.65:8000/api/katalog/$id'));
    if (response.statusCode == 200) {
      setState(() {
        futureKatalog = fetchKatalog(); // Refresh data setelah penghapusan
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produk Katalog", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF270650), Color(0XffFF30BA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
      ),
      // Menggunakan FutureBuilder untuk menangani loading dan data
      body: FutureBuilder<List<Katalog>>(
        future: futureKatalog,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Katalog Kosong'));
          } else {
            final katalogList = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: katalogList.length,
              itemBuilder: (context, index) {
                final item = katalogList[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.gambar != null && item.gambar!.isNotEmpty
                            ? 'http://192.168.100.65:8000/storage/${item.gambar}'
                            : 'https://via.placeholder.com/70',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    title: Text(item.namaProduk, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${item.deskripsiProduk}"),
                        SizedBox(height: 5),
                        Text(
                          "Rp ${item.hargaMinimum.toStringAsFixed(0)} - Rp ${item.hargaMaksimum.toStringAsFixed(0)}",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Navigasi ke halaman edit dengan data yang ada
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditKatalog(katalog: item),
                            ),
                          ).then((result) {
                            if (result == true) {
                              setState(() {
                                futureKatalog = fetchKatalog(); // Memperbarui daftar setelah edit
                              });
                            }
                          });
                        } else if (value == 'delete') {
                          // Menampilkan dialog konfirmasi sebelum menghapus
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Konfirmasi Hapus'),
                                content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Menutup dialog
                                    },
                                    child: Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteKatalog(item.id); // Menghapus produk
                                      Navigator.of(context).pop(); // Menutup dialog
                                    },
                                    child: Text('Hapus'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Tambahkatalog()),
          );
          if (result == true) {
            setState(() {
              futureKatalog = fetchKatalog(); // Memanggil fetchKatalog untuk memperbarui data
            });
          }
        },
        shape: CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
