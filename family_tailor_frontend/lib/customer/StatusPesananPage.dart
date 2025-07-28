import 'package:family_tailor_frontend/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:family_tailor_frontend/model/OrderKatalogModel.dart';
import 'package:family_tailor_frontend/model/OrderProdukRilisModel.dart';
import 'package:intl/intl.dart';

class StatusPesananPage extends StatefulWidget {
  final int customerId;

  const StatusPesananPage({super.key, required this.customerId});

  @override
  _StatusPesananPageState createState() => _StatusPesananPageState();
}

class _StatusPesananPageState extends State<StatusPesananPage> {
  late Future<Map<String, List>> _futurePesanan;
  final NumberFormat currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
  final DateFormat dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _futurePesanan = OrderService.fetchPesananByCustomer(widget.customerId);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'diantrian':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'dikirim':
      case 'diambil':
        return Colors.deepPurple;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _fixImageUrl(String? gambar) {
    if (gambar == null || gambar.isEmpty) {
      return '';
    }
    if (gambar.startsWith('http')) {
      return gambar;
    }
    return 'http://192.168.100.65:8000/storage/$gambar';
  }

  String _fixProductName(String? namaProduk) {
    return (namaProduk == null || namaProduk.isEmpty)
        ? "Produk Tidak Diketahui"
        : namaProduk;
  }

  Widget _buildOrderCard({
    required String produk,
    required String gambar,
    required String status,
    required String totalHarga,
    String? estimasiText,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (gambar.isNotEmpty)
                      ? Image.network(
                          gambar,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 80),
                        )
                      : const Icon(Icons.image_not_supported,
                          size: 80, color: Colors.grey),
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
                        'Total: Rp${currencyFormatter.format(int.tryParse(totalHarga) ?? double.tryParse(totalHarga) ?? 0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (estimasiText != null &&
                estimasiText.isNotEmpty &&
                estimasiText != "-")
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time,
                        size: 13, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      estimasiText,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatEstimasiTiba(OrderProdukRilis order) {
    if (order.estimasiTibaMin == null && order.estimasiTibaMax == null) {
      return "-";
    }
    String min = order.estimasiTibaMin != null
        ? dateFormatter.format(order.estimasiTibaMin!)
        : "";
    String max = order.estimasiTibaMax != null
        ? dateFormatter.format(order.estimasiTibaMax!)
        : "";
    if (min.isNotEmpty && max.isNotEmpty) {
      return "Estimasi Tiba: $min - $max";
    } else if (min.isNotEmpty) {
      return "Estimasi Tiba: $min";
    } else {
      return "Estimasi Tiba: $max";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Status Pesanan", style: TextStyle(color: Colors.white)),
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
        future: _futurePesanan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              (snapshot.data!['order_katalog']!.isEmpty &&
                  snapshot.data!['order_produk_rilis']!.isEmpty)) {
            return const Center(
              child: Text(
                'Belum ada pesanan.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final katalogOrders =
              snapshot.data!['order_katalog'] as List<OrderKatalog>;
          final produkRilisOrders =
              snapshot.data!['order_produk_rilis'] as List<OrderProdukRilis>;

          return ListView(
            children: [
              if (katalogOrders.isNotEmpty)
                ...katalogOrders.map(
                  (order) => _buildOrderCard(
                    produk: _fixProductName(order.namaProduk),
                    gambar: _fixImageUrl(order.gambar),
                    status: order.status,
                    totalHarga: order.totalHarga,
                    estimasiText: order.estimasiSelesai != '-'
                        ? "Estimasi Tiba: ${order.estimasiSelesai}"
                        : null,
                  ),
                ),
              if (produkRilisOrders.isNotEmpty)
                ...produkRilisOrders.map(
                  (order) => _buildOrderCard(
                    produk: _fixProductName(order.namaProduk),
                    gambar: _fixImageUrl(order.gambar),
                    status: order.status,
                    totalHarga: order.totalHarga.toString(),
                    estimasiText: _formatEstimasiTiba(order),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
