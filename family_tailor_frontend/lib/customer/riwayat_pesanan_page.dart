import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:family_tailor_frontend/model/OrderKatalogModel.dart';
import 'package:family_tailor_frontend/model/OrderProdukRilisModel.dart';
import 'package:family_tailor_frontend/services/order_service.dart';

class RiwayatPesananPage extends StatefulWidget {
  final int customerId; // Ambil dari login

  const RiwayatPesananPage({super.key, required this.customerId});

  @override
  _RiwayatPesananPageState createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  late Future<Map<String, List>> _futureRiwayat;
  final NumberFormat currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _futureRiwayat = OrderService.fetchPesananByCustomer(widget.customerId);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _fixImageUrl(String? gambar) {
    if (gambar == null || gambar.isEmpty) return '';
    if (gambar.startsWith('http')) return gambar;
    return 'http://192.168.100.65:8000/storage/$gambar';
  }

  String _fixProductName(String? namaProduk) {
    return (namaProduk == null || namaProduk.isEmpty)
        ? "Produk Tidak Diketahui"
        : namaProduk;
  }

  /// ✅ Perbaikan: `totalHarga` langsung diterima sebagai `double`
  Widget _buildRiwayatCard({
    required String produk,
    required String gambar,
    required String status,
    required double totalHarga,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (gambar.isNotEmpty)
                  ? Image.network(
                      gambar,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 70),
                    )
                  : const Icon(Icons.image_not_supported,
                      size: 70, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Status: ${status.toString()}",
                    style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Total: Rp${currencyFormatter.format(totalHarga)}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Pesanan",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF270650), Color(0xFFFF30BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, List>>(
        future: _futureRiwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Belum ada riwayat pesanan"));
          }

          final katalogOrders =
              snapshot.data!['order_katalog'] as List<OrderKatalog>;
          final produkRilisOrders =
              snapshot.data!['order_produk_rilis'] as List<OrderProdukRilis>;

          final allOrders = [
            ...katalogOrders.where(
                (o) => o.status == 'selesai' || o.status == 'dibatalkan'),
            ...produkRilisOrders.where(
                (o) => o.status == 'selesai' || o.status == 'dibatalkan'),
          ];

          if (allOrders.isEmpty) {
            return const Center(child: Text("Belum ada riwayat pesanan"));
          }

          return ListView(
            children: [
              ...katalogOrders
                  .where(
                      (o) => o.status == 'selesai' || o.status == 'dibatalkan')
                  .map((o) => _buildRiwayatCard(
                        produk: _fixProductName(o.namaProduk),
                        gambar: _fixImageUrl(o.gambar),
                        status: o.status,
                        totalHarga: double.tryParse(o.totalHarga) ??
                            0.0, // ✅ Perbaikan di sini
                      )),
              ...produkRilisOrders
                  .where(
                      (o) => o.status == 'selesai' || o.status == 'dibatalkan')
                  .map((o) => _buildRiwayatCard(
                        produk: _fixProductName(o.namaProduk),
                        gambar: _fixImageUrl(o.gambar),
                        status: o.status,
                        totalHarga: o.totalHarga, // ✅ Sudah double di model
                      )),
            ],
          );
        },
      ),
    );
  }
}
