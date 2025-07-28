import 'dart:convert';
import 'package:family_tailor_frontend/customer/CheckoutPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailProdukRilisPage extends StatefulWidget {
  final int id;

  DetailProdukRilisPage({required this.id});

  @override
  _DetailProdukPageState createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukRilisPage> {
  Map<String, dynamic>? produk;

  @override
  void initState() {
    super.initState();
    fetchDetailProduk();
  }

  Future<void> fetchDetailProduk() async {
    final response = await http.get(
      Uri.parse('http://192.168.100.65:8000/api/produk-rilis/${widget.id}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        produk = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail produk')),
      );
    }
  }

  //keranjang

  Future<void> addToCart() async {
    final prefs = await SharedPreferences.getInstance();

    //Pakai ID customer agar sama dengan CartPage
    final userId = prefs.getInt('id_customer') ?? 0;
    final cartKey = 'cart_$userId';

    List<String> cartItems = prefs.getStringList(cartKey) ?? [];

    List<Map<String, dynamic>> cartList = cartItems
        .map((item) => jsonDecode(item))
        .toList()
        .cast<Map<String, dynamic>>();

    // ✅ Samakan tipe data saat membandingkan (pakai toString())
    final index = cartList.indexWhere(
        (item) => item['id'].toString() == produk!['id'].toString());

    final int harga =
        double.tryParse(produk!['harga'].toString())?.toInt() ?? 0;

    if (index != -1) {
      cartList[index]['quantity'] =
          (int.tryParse(cartList[index]['quantity'].toString()) ?? 0) + 1;
    } else {
      cartList.add({
        'id': produk!['id'].toString(),
        'nama_produk': produk!['nama_produk'],
        'gambar': 'http://192.168.100.65:8000/storage/${produk!['gambar']}',
        'harga': harga,
        'quantity': 1,
      });
    }

    await prefs.setStringList(
      cartKey,
      cartList.map((item) => jsonEncode(item)).toList(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Produk berhasil dimasukkan ke keranjang")),
    );

     Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Detail Produk Rilis", style: TextStyle(color: Colors.white)),
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
      body: produk == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  produk!['gambar'] != null
                      ? Image.network(
                          'http://192.168.100.65:8000/storage/${produk!['gambar']}',
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, size: 100),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rp ${NumberFormat("#,###", "id_ID").format(double.parse(produk!['harga'].toString()).toInt())}",
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
                              child: Text(produk!['nama_produk'] ?? '',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(produk!['deskripsi_produk'] ?? '',
                            style: TextStyle(fontSize: 14)),
                        SizedBox(height: 16),
                        Text("Ukuran: ${produk!['ukuran'] ?? '-'}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 16),
                        Text("Spesifikasi:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 4),
                        Text(produk!['spesifikasi'] ?? '-',
                            style: TextStyle(fontSize: 14)),
                        SizedBox(height: 16),
                        Text("Keterangan:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 4),
                        Text(produk!['keterangan'] ?? '-'),
                        SizedBox(height: 100),
                      ],
                    ),
                  )
                ],
              ),
            ),
      bottomNavigationBar: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () {
                if (produk != null) {
                  addToCart();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 118, 184, 144),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text("Masukkan Keranjang",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () {
                if (produk != null) {
                  final produkCheckout = {
                    'id': produk!['id'],
                    'nama_produk': produk!['nama_produk'],
                    'gambar':
                        'http://192.168.100.65:8000/storage/${produk!['gambar']}',
                    'harga': produk!['harga'],
                    'deskripsi': produk!['deskripsi_produk'],
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CheckoutPage(produkList: [produkCheckout]),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 60, 143, 70),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child:
                  Text("Beli Sekarang", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
