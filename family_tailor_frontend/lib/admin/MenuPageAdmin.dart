import 'package:family_tailor_frontend/admin/HomePageAdmin.dart';
import 'package:family_tailor_frontend/admin/KatalogPageAdmin.dart';
import 'package:family_tailor_frontend/admin/LimitPage.dart';
import 'package:family_tailor_frontend/admin/OperasionalPage.dart';
import 'package:family_tailor_frontend/admin/PelangganPage.dart';
import 'package:family_tailor_frontend/admin/ProdukRilisPage.dart';
import 'package:family_tailor_frontend/admin/StokBahan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuPageAdmin extends StatefulWidget {
  const MenuPageAdmin({super.key});

  @override
  State<MenuPageAdmin> createState() => _MenuPageAdminState();
}

class _MenuPageAdminState extends State<MenuPageAdmin> {
  // Tambahkan state untuk filter dan total
  String selectedFilter = "Hari ini";
  int pemasukan = 0;
  int pengeluaran = 0;
  int tappedIndex = -1; // Untuk lacak index tombol yang ditekan

  @override
  void initState() {
    super.initState();
    // Jalankan filter pertama kali saat halaman dimuat
    filterData(selectedFilter);
  }

  //Fungsi untuk memfilter data dummy
  Future<void> filterData(String filter) async {
    final url =
        Uri.parse('http://192.168.100.65:8000/api/omset?filter=$filter');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pemasukan = data['pemasukan'];
          pengeluaran = data['pengeluaran'];
        });
      } else {
        print('Gagal memuat data omset: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat ambil data omset: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(10),
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
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Omset Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Omset Bisnis",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                // Tambahkan Dropdown untuk filter
                DropdownButton<String>(
                  value: selectedFilter,
                  items: const [
                    DropdownMenuItem(
                        value: "Hari ini", child: Text("Hari ini")),
                    DropdownMenuItem(
                        value: "Minggu ini", child: Text("Minggu ini")),
                    DropdownMenuItem(
                        value: "Bulan ini", child: Text("Bulan ini")),
                    DropdownMenuItem(
                        value: "Tahun ini",
                        child: Text("Tahun ini")), // Tambahan
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                      filterData(selectedFilter);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Optional Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200], // warna shape
                borderRadius: BorderRadius.circular(40), // bentuk oval
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    label: const Text("Semua"),
                    selected: selectedFilter == "Semua",
                    selectedColor: Colors.grey[400],
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(), // bentuk oval juga
                    onSelected: (_) {
                      setState(() {
                        // selectedFilter = "Semua";
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Transaksi"),
                    selected: selectedFilter == "Transaksi",
                    selectedColor: Colors.grey[400],
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(), // bentuk oval juga
                    onSelected: (_) {
                      setState(() {
                        // selectedFilter = "Semua";
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Lain-lain"),
                    selected: selectedFilter == "Lain-lain",
                    selectedColor: Colors.grey[400],
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(), // bentuk oval juga
                    onSelected: (_) {
                      setState(() {
                        // selectedFilter = "Semua";
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Container Omset Pemasukan dan Pengeluaran
            Container(
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text("Pemasukan",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.trending_up,
                          size: 20, color: Colors.pink),
                      Text("Rp. ${pemasukan.toString()}",
                          style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Pengeluaran",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.trending_down,
                          size: 20, color: Colors.pink),
                      Text(
                        "Rp. ${pengeluaran.toString()}",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            //berbagai fitur
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Menu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8)),
              child: SizedBox(
                height: 170,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MenuItem(
                          icon: Icons.shopping_bag,
                          label: "Katalog",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => KatalogPage()));
                          },
                        ),
                        MenuItem(
                          icon: Icons.inventory,
                          label: "Stok Bahan",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StokBahanBakuPage()));
                          },
                        ),
                        MenuItem(
                          icon: Icons.settings,
                          label: "Operasional",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OperasionalPage()));
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MenuItem(
                          icon: Icons.star,
                          label: "Produk Rilis",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProdukRilisPage()));
                          },
                        ),
                        MenuItem(
                          icon: Icons.bar_chart,
                          label: "Limit",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LimitPageAdmin()),
                            );
                          },
                        ),
                        MenuItem(
                          icon: Icons.people,
                          label: "Pelanggan",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PelangganPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePageAdmin()));
                },
                onHighlightChanged: (isHighlighted) {
                  setState(() {
                    tappedIndex = isHighlighted ? 0 : -1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront,
                      color: tappedIndex == 0 ? Colors.grey : Colors.black,
                    ),
                    const Text("Produksi", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    tappedIndex = 1;
                  });
                },
                onHighlightChanged: (isHighlighted) {
                  setState(() {
                    tappedIndex = isHighlighted ? 1 : -1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_checkout_outlined,
                      color: tappedIndex == 1 ? Colors.grey : Colors.black,
                    ),
                    const Text("Pesanan", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    tappedIndex = 2;
                  });
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MenuPageAdmin()));
                },
                onHighlightChanged: (isHighlighted) {
                  setState(() {
                    tappedIndex = isHighlighted ? 2 : -1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu,
                      color: tappedIndex == 2 ? Colors.grey : Colors.black,
                    ),
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

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const MenuItem({
    Key? key,
    required this.icon,
    required this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.pink[300],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 25, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
