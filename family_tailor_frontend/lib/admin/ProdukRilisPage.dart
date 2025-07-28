import 'package:family_tailor_frontend/CreateData/EditProdukRilis.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:family_tailor_frontend/model/ProdukRilisModel.dart';
import 'package:family_tailor_frontend/CreateData/TambahProdukRilis.dart';

class ProdukRilisPage extends StatefulWidget {
  const ProdukRilisPage({super.key});

  @override
  State<ProdukRilisPage> createState() => _ProdukRilisPageState();
}

class _ProdukRilisPageState extends State<ProdukRilisPage> {
  late Future<List<ProdukRilis>> futureProduk;

  Future<List<ProdukRilis>> fetchProdukRilis() async {
    final response =
        await http.get(Uri.parse('http://192.168.100.65:8000/api/produk-rilis'));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ProdukRilis.fromJson(item)).toList();
      } catch (e) {
        throw Exception('Error parsing JSON: $e');
      }
    } else {
      throw Exception('Failed to load produk rilis');
    }
  }

  @override
  void initState() {
    super.initState();
    futureProduk = fetchProdukRilis();
  }

  Future<void> deleteProduk(int id) async {
    final response = await http
        .delete(Uri.parse('http://192.168.100.65:8000/api/produk-rilis/$id'));
    if (response.statusCode == 200) {
      setState(() {
        futureProduk = fetchProdukRilis();
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
        title: Text("Produk Rilis", style: TextStyle(color: Colors.white)),
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
      body: FutureBuilder<List<ProdukRilis>>(
        future: futureProduk,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada produk rilis'));
          } else {
            final produkList = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: produkList.length,
              itemBuilder: (context, index) {
                final item = produkList[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
                    title: Text(item.namaProduk,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ukuran: ${item.ukuran}"),
                        /*     Text("Spesifikasi: ${item.spesifikasi}"), */
                        Text("${item.deskripsiProduk}"),
                        if (item.keterangan != null)
                          Text("Keterangan: ${item.keterangan}"),
                        SizedBox(height: 5),
                        Text(
                          "Rp ${item.harga.toStringAsFixed(0)}",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                     trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                 EditProdukRilis(produkRilis: item)
                            ),
                          ).then((result) {
                            if (result == true) {
                              setState(() {
                                futureProduk = fetchProdukRilis();
                              });
                            }
                          });
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Konfirmasi Hapus'),
                                content:
                                    Text('Apakah Anda yakin ingin menghapus produk ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteProduk(item.id);
                                      Navigator.of(context).pop();
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
            MaterialPageRoute(builder: (context) => TambahProdukRilis()),
          );
          if (result == true) {
            setState(() {
              futureProduk = fetchProdukRilis();
            });
          }
        },
        shape: CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
