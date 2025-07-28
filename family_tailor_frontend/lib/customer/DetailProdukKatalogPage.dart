import 'dart:convert';
import 'package:family_tailor_frontend/customer/CheckoutKatalogPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailProdukKatalogPage extends StatefulWidget {
  final int id;

  DetailProdukKatalogPage({required this.id});

  @override
  _DetailProdukKatalogPageState createState() =>
      _DetailProdukKatalogPageState();
}

class _DetailProdukKatalogPageState extends State<DetailProdukKatalogPage> {
  Map<String, dynamic>? katalog;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    fetchDetailKatalog();
  }

  /// ✅ Ambil detail produk dari API
  Future<void> fetchDetailKatalog() async {
    final response = await http.get(
      Uri.parse('http://192.168.100.65:8000/api/katalog/${widget.id}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        katalog = json.decode(response.body);
      });

      checkIfFavorite();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail katalog')),
      );
    }
  }

  /// Cek apakah produk sudah ada di favorite user login
  Future<void> checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id_customer') ?? 0; // pakai ID user
    final favData = prefs.getStringList('favorite_$userId') ?? [];

    final existing = favData
        .map((item) => jsonDecode(item))
        .cast<Map<String, dynamic>>()
        .where((fav) => fav['id'] == widget.id)
        .toList();

    setState(() {
      isFavorite = existing.isNotEmpty;
    });
  }

  //Tambah atau hapus favorite (toggle)
  Future<void> toggleFavorite() async {
    if (katalog == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id_customer') ?? 0; // pakai ID user
    List<String> favData = prefs.getStringList('favorite_$userId') ?? [];

    List<Map<String, dynamic>> favorites = favData
        .map((item) => jsonDecode(item))
        .cast<Map<String, dynamic>>()
        .toList();

    if (isFavorite) {
      favorites.removeWhere((fav) => fav['id'] == widget.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dihapus dari Favorite")),
      );
    } else {
      favorites.add({
        'id': katalog!['id'],
        'nama_produk': katalog!['nama_produk'] ?? '-',
        'gambar': 'http://192.168.100.65:8000/storage/${katalog!['gambar']}',
        'deskripsi_produk': katalog!['deskripsi_produk'] ?? '-',
        'spesifikasi': katalog!['spesifikasi'] ?? '-',
        'keterangan': katalog!['keterangan'] ?? '-',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ditambahkan ke Favorite")),
      );
    }

    List<String> updatedFav =
        favorites.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(
        'favorite_$userId', updatedFav); //pakai ID user

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (katalog == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Detail Produk Katalog",
              style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF270650), Color(0XffFF30BA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double hargaMin =
        double.tryParse(katalog!['harga_minimum'].toString()) ?? 0.0;
    double hargaMax =
        double.tryParse(katalog!['harga_maksimum'].toString()) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Produk Katalog",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF270650), Color(0XffFF30BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Gambar Produk
            katalog!['gambar'] != null
                ? Image.network(
                    'http://192.168.100.65:8000/storage/${katalog!['gambar']}',
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 100),
                  ),

            /// ✅ Informasi Produk
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rp ${NumberFormat("#,###", "id_ID").format(hargaMin)} - Rp ${NumberFormat("#,###", "id_ID").format(hargaMax)}",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          katalog!['nama_produk'] ?? '',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: toggleFavorite,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(katalog!['deskripsi_produk'] ?? '',
                      style: TextStyle(fontSize: 14)),
                  SizedBox(height: 16),
                  Text("Spesifikasi:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(katalog!['spesifikasi'] ?? '-',
                      style: TextStyle(fontSize: 14)),
                  SizedBox(height: 16),
                  Text("Keterangan:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(katalog!['keterangan'] ?? '-'),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      /// ✅ Tombol Bawah (Full Lebar)
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (katalog != null) {
              final produkCheckout = {
                'id': katalog!['id'],
                'nama_produk': katalog!['nama_produk'],
                'gambar':
                    'http://192.168.100.65:8000/storage/${katalog!['gambar']}',
                'harga_minimum': katalog!['harga_minimum'],
                'harga_maksimum': katalog!['harga_maksimum'],
                'deskripsi': katalog!['deskripsi_produk'],
              };

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutKatalogPage(produk: produkCheckout),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 60, 143, 70),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text("Pesan Sekarang", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
