import 'package:family_tailor_frontend/admin/DetailPesananPageAdmin.dart';
import 'package:family_tailor_frontend/model/OrderDetailModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../model/OrderProdukRilisModel.dart';
import '../services/order_service.dart';
import 'HomePageAdmin.dart';
import 'MenuPageAdmin.dart';

class PesananPageAdmin extends StatefulWidget {
  const PesananPageAdmin({super.key});

  @override
  State<PesananPageAdmin> createState() => _PesananPageAdminState();
}

class _PesananPageAdminState extends State<PesananPageAdmin> {
  late Future<List<OrderProdukRilis>> futureOrders;
  int selectedFilter = 0;
  int tappedIndex = 1;

  final List<String> statusFilter = [
    'diantrian',
    'dikirim',
    'selesai',
    'dibatalkan'
  ];

  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureOrders = OrderService.fetchOrders();
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF270650), Color(0xFFFF30BA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
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
                  const Spacer(),
                  const Icon(Icons.shopping_cart_checkout_outlined),
                ],
              ),
            ),

            // Kolom pencarian
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama/zona/status',
                  prefixIcon: const Icon(Icons.search),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),

            // Tab Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: statusFilter.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final label = entry.value;
                  final isSelected = idx == selectedFilter;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = idx;
                        });
                      },
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
                            capitalize(label),
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

            // Daftar Pesanan
            Expanded(
              child: FutureBuilder<List<OrderProdukRilis>>(
                future: futureOrders,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text("Terjadi kesalahan: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Belum ada pesanan."));
                  }

                  final orders = snapshot.data!.where((order) {
                    final statusMatch = order.status.toLowerCase().trim() ==
                        statusFilter[selectedFilter].toLowerCase().trim();

                    final matchesSearch = searchQuery.isEmpty ||
                        order.zona.toLowerCase().contains(searchQuery) ||
                        order.status.toLowerCase().contains(searchQuery) ||
                        order.status_pembayaran
                            .toLowerCase()
                            .contains(searchQuery) ||
                        (order.idCustomer?.toString() ?? '').contains(
                            searchQuery); // jika mau cari pakai ID customer

                    return statusMatch && matchesSearch;
                  }).toList();

                  if (orders.isEmpty) {
                    return const Center(
                        child: Text("Tidak ada pesanan dengan status ini."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              try {
                                OrderDetailModel orderDetail =
                                    await OrderService.fetchOrderDetailModel(
                                        order.id);

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPesananPageAdmin(
                                            orderDetail: orderDetail),
                                  ),
                                );

                                if (result == 'refresh') {
                                  setState(() {
                                    futureOrders = OrderService
                                        .fetchOrders(); // fetch ulang data
                                  });
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Gagal memuat detail pesanan: $e')),
                                );
                              }
                            },
                            child: ListTile(
                              title: Text("Customer Id: ${order.idCustomer}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Zona: ${order.zona}"),
                                  Text("Pengiriman: ${order.metodePengiriman}"),
                                  Text("Pembayaran: ${order.metodePembayaran}"),
                                ],
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'id_ID',
                                            symbol: 'Rp ',
                                            decimalDigits: 0)
                                        .format(double.parse(order.totalHarga
                                            .toStringAsFixed(0))),
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${order.status_pembayaran}",
                                    style: TextStyle(
                                      color: order.status_pembayaran == 'lunas'
                                          ? Colors.green
                                          : (order.status == 'dibatalkan'
                                              ? Colors.grey
                                              : Colors.red),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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

      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    tappedIndex = 0;
                  });
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePageAdmin()));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront,
                        color: tappedIndex == 0 ? Colors.grey : Colors.black),
                    const Text("Produksi", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_checkout_outlined,
                        color: tappedIndex == 1 ? Colors.grey : Colors.black),
                    const Text("Pesanan", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    tappedIndex = 2;
                  });
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MenuPageAdmin()));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu,
                        color: tappedIndex == 2 ? Colors.grey : Colors.black),
                    const Text("Menu", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
