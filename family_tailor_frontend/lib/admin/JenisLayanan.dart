import 'package:flutter/material.dart';
import 'package:family_tailor_frontend/model/Customer.dart';
import 'package:family_tailor_frontend/admin/WaktuLayananPage.dart'; // Pastikan ini sudah ada

class JenisLayananPage extends StatelessWidget {
  final Customer customer;

  const JenisLayananPage({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> layananList = [
      {
        'title': 'Custom',
        'subtitle': 'Layanan',
        'icon': Icons.design_services,
      },
      {
        'title': 'Perbaikan',
        'subtitle': 'Layanan',
        'icon': Icons.content_cut,
      },
      {
        'title': 'Modifikasi',
        'subtitle': 'Layanan',
        'icon': Icons.edit,
      },
      {
        'title': 'Aksesoris',
        'subtitle': 'Layanan',
        'icon': Icons.style,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Layanan", style: TextStyle(color: Colors.white)),
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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.grey.shade300,
            child: Center(
              child: Text(
                'Jenis Layanan Jahit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF270650),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Text(
                  'Anda perlu menentukan jenis layanan jahit sesuai keinginan pelanggan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pelanggan: ${customer.nama} (${customer.noHp})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF270650),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: layananList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemBuilder: (context, index) {
                final layanan = layananList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PilihWaktuLayananPage(
                          customer: customer,
                          jenisLayanan: layanan['title'].toLowerCase(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(layanan['icon'],
                                  size: 30, color: Color(0xFF270650)),
                              Text(
                                layanan['subtitle'],
                                style: TextStyle(color: Color(0xFF270650)),
                              ),
                              SizedBox(height: 5),
                              Text(
                                layanan['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF270650),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF270650)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
