import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DetailProdukKatalogPage.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> favoriteList = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  /// ✅ Ambil data favorite berdasarkan user login
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id_customer') ?? 0;
       

    final favData = prefs.getStringList('favorite_$userId') ?? [];
//debugging
    print("DEBUG loadCart() - Key: cart_$userId, Data: $favData");

    setState(() {
      favoriteList = favData
          .map((item) => jsonDecode(item))
          .toList()
          .cast<Map<String, dynamic>>();
    });
  }

  /// ✅ Hapus favorite khusus user login
  Future<void> removeFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id_customer') ?? 'guest';

    favoriteList.removeWhere((item) => item['id'] == id);

    final updatedFav = favoriteList.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('favorite_$userId', updatedFav);

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Dihapus dari Favorite")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorite",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: favoriteList.isEmpty
          ? Center(child: Text("Belum ada produk favorite"))
          : ListView.builder(
              itemCount: favoriteList.length,
              itemBuilder: (context, index) {
                final item = favoriteList[index];

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(
                      item['gambar'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      item['nama_produk'] ?? '-',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      (item['deskripsi_produk']?.toString().isNotEmpty == true
                              ? item['deskripsi_produk']
                              : item['spesifikasi'] ?? '-')
                          .toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeFavorite(item['id']),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailProdukKatalogPage(id: item['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
