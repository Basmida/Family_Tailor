import 'dart:convert';
import 'package:family_tailor_frontend/CreateData/TambahStokBahan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StokBahanBakuPage extends StatefulWidget {
  const StokBahanBakuPage({super.key});

  @override
  _StokBahanBakuPageState createState() => _StokBahanBakuPageState();
}

class _StokBahanBakuPageState extends State<StokBahanBakuPage> {
  List stokBahanList = [];
  bool isLoading = false;

  // Fetch the data
  void fetchStokBahan() async {
    setState(() => isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('http://192.168.100.65:8000/api/stok'));
      if (response.statusCode == 200) {
        setState(() {
          stokBahanList = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Fungsi untuk hapus stok bahan
  Future<void> hapusStok(int id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.100.65:8000/api/stok/$id'),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok bahan berhasil dihapus')),
      );
      fetchStokBahan(); // Refresh data setelah hapus
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus stok bahan: ${response.body}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStokBahan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stok Bahan Baku", style: TextStyle(color: Colors.white)),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: stokBahanList.length,
                itemBuilder: (context, index) {
                  final bahan = stokBahanList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(bahan['nama_bahan']),
                      subtitle: Text(
                          '${bahan['tanggal_masuk']} | Stok: ${bahan['jumlah']} ${bahan['satuan']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // Menampilkan menu aksi untuk Edit dan Hapus
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text("Edit Stok Bahan"),
                                      onTap: () {
                                        Navigator.pop(
                                            context); // Menutup bottom sheet
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TambahStokBahanBakuPage(
                                              stokBahan:
                                                  bahan, // Kirim data untuk di-edit
                                            ),
                                          ),
                                        ).then(
                                          (value) {
                                            if (value != null && value) {
                                              fetchStokBahan(); // Refresh data after editing
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text("Hapus Stok Bahan"),
                                      onTap: () {
                                        Navigator.pop(
                                            context); // Menutup bottom sheet
                                        hapusStok(bahan[
                                            'id']); // Panggil fungsi hapus
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () async {
          // Navigate to the Add Stock page and refresh data after adding
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahStokBahanBakuPage(),
            ),
          );

          // Memastikan data di-refresh setelah berhasil ditambahkan atau diubah
          if (result != null && result) {
            print("Data berhasil ditambahkan, memuat ulang data...");
            fetchStokBahan(); // Refresh data after adding
          } else {
            print("Tidak ada perubahan data.");
          }
        },
        shape: CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
