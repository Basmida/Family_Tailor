// Tambahkan package ini di paling atas:
import 'dart:convert';
import 'package:family_tailor_frontend/admin/DetailPesananCustom.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:family_tailor_frontend/admin/DaftarPelanggan.dart';
import 'package:family_tailor_frontend/admin/KatalogPageAdmin.dart';
import 'package:family_tailor_frontend/admin/MenuPageAdmin.dart';
import 'package:family_tailor_frontend/admin/PesananPageAdmin.dart';
import 'package:family_tailor_frontend/pages/login_page.dart';
import 'package:family_tailor_frontend/services/auth_service.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  int selectedFilter = 0;
  int tappedIndex = -1;

  List<dynamic> orders = [];
  bool isLoading = true;

  Future<void> fetchOrders() async {
    final response = await http
        .get(Uri.parse('http://192.168.100.65:8000/api/order-katalog'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        orders = data;
        isLoading = false;
      });
    } else {
      throw Exception('Gagal mengambil data order');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Color(0xFF270650), Color(0XffFF30BA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        child: Text(
                          "Family Tailor",
                          style: GoogleFonts.pacifico(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: Text("Konfirmasi Logout"),
                            content: Text("Anda yakin ingin keluar?"),
                            actions: [
                              TextButton(
                                child: Text("Tidak"),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                              ),
                              TextButton(
                                child: Text("Ya"),
                                onPressed: () async {
                                  Navigator.of(dialogContext).pop();
                                  final message = await AuthService.logout();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)));
                                  if (message == "Logout berhasil") {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.logout),
                  ),
                ],
              ),
            ),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Nama atau no.handphone',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),

            // FILTER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ["Di Antrian", "Diproses", "Siap Diambil"]
                    .asMap()
                    .entries
                    .map((entry) {
                  final idx = entry.key;
                  final label = entry.value;
                  final isSelected = idx == selectedFilter;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedFilter = idx),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.pink[300] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // LIST PESANAN
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Builder(
                      builder: (context) {
                        List<dynamic> filteredOrders = orders.where((order) {
                          String status = order['status'];
                          if (selectedFilter == 0) return status == 'diantrian';
                          if (selectedFilter == 1) return status == 'diproses';
                          if (selectedFilter == 2)
                            return status == 'diambil' || status == 'selesai';
                          return false;
                        }).toList();

                        if (filteredOrders.isEmpty) {
                          return Center(
                            child: Text(
                              "Tidak ada data",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredOrders.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];

                            return Column(
                              children: [
                                ListTile(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailPesananCustom(order: order),
                                      ),
                                    );

                                    if (result == true) {
                                      await fetchOrders(); // Refresh data

                                      // Atur filter ke status baru
                                      final updatedOrder = orders.firstWhere(
                                          (o) => o['id'] == order['id'],
                                          orElse: () => null);
                                      if (updatedOrder != null) {
                                        String newStatus =
                                            updatedOrder['status'];
                                        setState(() {
                                          if (newStatus == 'diantrian')
                                            selectedFilter = 0;
                                          else if (newStatus == 'diproses')
                                            selectedFilter = 1;
                                          else if (newStatus == 'diambil' ||
                                              newStatus == 'selesai')
                                            selectedFilter = 2;
                                        });
                                      }
                                    }
                                  },
                                  title: Text(order['customer']['nama'] ?? '-'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(order['katalog']['nama_produk'] ??
                                          '-'),
                                      Text(
                                          "Est. Selesai Tgl ${order['estimasi_selesai'] ?? '-'}"),
                                    ],
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Rp ${order['total_harga']}",
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          order['status_pembayaran'] ??
                                              'Belum Lunas',
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    ],
                                  ),
                                ),
                                const Divider(),
                              ],
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(Icons.storefront, "Produksi", 0, HomePageAdmin()),
              buildNavItem(Icons.shopping_cart_checkout_outlined, "Pesanan", 1,
                  PesananPageAdmin()),
              buildNavItem(Icons.menu, "Menu", 2, MenuPageAdmin()),
            ],
          ),
        ),
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[300],
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DaftarPelangganPage()));
        },
        shape: CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildNavItem(IconData icon, String label, int index, Widget page) {
    return InkWell(
      onTap: () {
        setState(() => tappedIndex = index);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: tappedIndex == index ? Colors.grey : Colors.black),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
