import 'dart:convert';
import 'package:family_tailor_frontend/customer/DetailProdukRilis.dart';
import 'package:family_tailor_frontend/customer/FavoritePage.dart';
import 'package:family_tailor_frontend/customer/NotifikasiPage.dart';
import 'package:family_tailor_frontend/customer/ProfilePage.dart';
import 'package:family_tailor_frontend/customer/StatusPesananPage.dart';
import 'package:family_tailor_frontend/customer/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:family_tailor_frontend/customer/DetailProdukKatalogPage.dart';
import 'package:intl/intl.dart';

class Homepagecustomer extends StatefulWidget {
  @override
  _HomepagecustomerState createState() => _HomepagecustomerState();
}

class _HomepagecustomerState extends State<Homepagecustomer> {
  List<dynamic> produkRilis = [];
  List<dynamic> produkKatalog = [];
  String? userName;
  String _selectedCategory = 'produk_rilis';
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  int cartCount = 0;
  int notificationCount = 0; // ✅ Tambahan
  int? loggedInCustomerId;

  @override
  void initState() {
    super.initState();
    fetchProdukRilis();
    fetchProdukKatalog();
    loadUserName();
    loadCartCount();
    loadCustomerId();
  }

  Future<void> loadCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInCustomerId = prefs.getInt('id_customer') ?? 0;
    });
    print("DEBUG loggedInCustomerId: $loggedInCustomerId");
    if (loggedInCustomerId != null && loggedInCustomerId != 0) {
      fetchOrderNotifications(); // ✅ Panggil setelah ID customer ter-load
    }
  }

  Future<void> loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id_customer') ?? 0;
    final cartItems = prefs.getStringList('cart_$userId') ?? [];

    setState(() {
      cartCount = cartItems.length;
    });

    print("DEBUG loadCartCount() - Key: cart_$userId, Count: $cartCount");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadCartCount();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Pelanggan';
    });
  }

  Future<void> fetchProdukRilis() async {
    final response = await http
        .get(Uri.parse('http://192.168.100.65:8000/api/produk-rilis'));
    if (response.statusCode == 200) {
      setState(() {
        produkRilis = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data produk rilis')),
      );
    }
  }

  Future<void> fetchProdukKatalog() async {
    final response =
        await http.get(Uri.parse('http://192.168.100.65:8000/api/katalog'));
    if (response.statusCode == 200) {
      setState(() {
        produkKatalog = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data produk katalog')),
      );
    }
  }

  /// ✅ Fungsi ambil notifikasi berbasis status order
  Future<void> fetchOrderNotifications() async {
    if (loggedInCustomerId == null || loggedInCustomerId == 0) return;

    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(
      Uri.parse('http://192.168.100.65:8000/api/orders/$loggedInCustomerId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      int count = 0;

      for (var order in data) {
        final id = order['id'].toString();
        final currentStatus = order['status'];
        final lastStatus = prefs.getString('status_order_$id');

        // Cek apakah status berubah
        if (lastStatus != null && lastStatus != currentStatus) {
          count++;
        }

        // Simpan status terbaru ke SharedPreferences
        await prefs.setString('status_order_$id', currentStatus);
      }

      setState(() {
        notificationCount = count;
      });

      print("DEBUG Notif Count: $notificationCount");
    } else {
      print("Gagal mengambil data order untuk notifikasi");
    }
  }

  void _hubungiAdmin() async {
    const phone = '6281372114967';
    final message = Uri.encodeComponent("Halo Admin, saya ingin bertanya.");
    final whatsappUrl = Uri.parse("whatsapp://send?phone=$phone&text=$message");
    final fallbackUrl = Uri.parse("https://wa.me/$phone?text=$message");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tidak dapat membuka WhatsApp.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final produkList =
        _selectedCategory == 'produk_rilis' ? produkRilis : produkKatalog;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(8),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF270650), Color(0xFFFF30BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: Text(
              "Family Tailor",
              style: GoogleFonts.pacifico(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.notifications_none, color: Color(0xFF270650)),
                  if (notificationCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints:
                            BoxConstraints(minWidth: 12, minHeight: 12),
                        child: Text(
                          '$notificationCount',
                          style: TextStyle(color: Colors.white, fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () async {
                if (loggedInCustomerId != null && loggedInCustomerId != 0) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NotifikasiPage(customerId: loggedInCustomerId!),
                    ),
                  );
                  setState(() {
                    notificationCount = 0; // ✅ Reset setelah dibaca
                  });
                }
              }),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF5B6E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/admin.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Butuh informasi lebih lanjut?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF270650),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _hubungiAdmin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF53C0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            'Hubungi Admin',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16),
            Text("Kategori",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _selectedCategory = 'produk_rilis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory == 'produk_rilis'
                          ? Color.fromARGB(255, 240, 114, 198)
                          : Colors.grey[300],
                    ),
                    child: Text(
                      'Produk Rilis',
                      style: TextStyle(
                        color: _selectedCategory == 'produk_rilis'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _selectedCategory = 'produk_katalog'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory == 'produk_katalog'
                          ? Color.fromARGB(255, 240, 114, 198)
                          : Colors.grey[300],
                    ),
                    child: Text(
                      'Produk Katalog',
                      style: TextStyle(
                        color: _selectedCategory == 'produk_katalog'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text("Silahkan di Order",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                itemCount: produkList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final item = produkList[index];
                  final imageUrl = item['gambar'] != null
                      ? 'http://192.168.100.65:8000/storage/${item['gambar']}'
                      : null;

                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            if (_selectedCategory == 'produk_rilis') {
                              return DetailProdukRilisPage(id: item['id']);
                            } else {
                              return DetailProdukKatalogPage(id: item['id']);
                            }
                          },
                        ),
                      );
                      if (result == true) {
                        loadCartCount();
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Icon(Icons.image),
                                    )
                                  : Icon(Icons.image),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['nama_produk'] ?? 'Tanpa Nama',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text(
                                  "${item['deskripsi_produk'] ?? ''}",
                                  style: TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _selectedCategory == 'produk_rilis'
                                      ? currencyFormatter.format(
                                          double.tryParse(
                                                  item['harga'].toString()) ??
                                              0)
                                      : "${currencyFormatter.format(double.tryParse(item['harga_minimum'].toString()))} - ${currencyFormatter.format(double.tryParse(item['harga_maksimum'].toString()) ?? 0)}",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Color(0xFF270650),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CartPage()),
            ).then((_) => loadCartCount());
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavoritePage()),
            );
          } else if (index == 3) {
            if (loggedInCustomerId != null && loggedInCustomerId != 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StatusPesananPage(customerId: loggedInCustomerId!),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("ID Customer belum ditemukan!")),
              );
            }
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilePage()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart_outlined),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        '$cartCount',
                        style: TextStyle(color: Colors.white, fontSize: 6),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline), label: 'Favorite'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined), label: 'Status'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined), label: 'Profil'),
        ],
      ),
    );
  }
}
