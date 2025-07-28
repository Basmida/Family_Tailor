import 'dart:async';
import 'package:family_tailor_frontend/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:family_tailor_frontend/customer/StatusPesananPage.dart';
import 'package:family_tailor_frontend/model/OrderKatalogModel.dart';
import 'package:family_tailor_frontend/model/OrderProdukRilisModel.dart';

class NotifikasiPage extends StatefulWidget {
  final int customerId;
  NotifikasiPage({required this.customerId});

  @override
  _NotifikasiPageState createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  List<Map<String, dynamic>> notifikasiList = [];
  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  Timer? _timer; // ✅ untuk auto-refresh

  @override
  void initState() {
    super.initState();
    loadNotifikasi();

    // ✅ Auto refresh tiap 30 detik
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      loadNotifikasi();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ Hentikan timer saat keluar dari page
    super.dispose();
  }

  Future<void> loadNotifikasi() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final data =
          await OrderService.fetchPesananByCustomer(widget.customerId);

      final List<OrderKatalog> katalogOrders =
          data["order_katalog"] as List<OrderKatalog>;
      final List<OrderProdukRilis> produkRilisOrders =
          data["order_produk_rilis"] as List<OrderProdukRilis>;

      List<Map<String, dynamic>> tempList = [];

      final allOrders = [...katalogOrders, ...produkRilisOrders];

      for (var order in allOrders) {
        if (order is OrderKatalog) {
          final id = order.id.toString();
          final currentStatus = order.status;
          final lastStatus = prefs.getString('status_order_$id');

          if (lastStatus == null) {
            await prefs.setString('status_order_$id', currentStatus);
          } else if (lastStatus != currentStatus) {
            tempList.add({
              'id': order.id,
              'status': currentStatus,
              'total_harga': double.tryParse(order.totalHarga) ?? 0.0,
              'updated_at': '',
            });

            await prefs.setString('status_order_$id', currentStatus);
          }
        } else if (order is OrderProdukRilis) {
          final id = order.id.toString();
          final currentStatus = order.status;
          final lastStatus = prefs.getString('status_order_$id');

          if (lastStatus == null) {
            await prefs.setString('status_order_$id', currentStatus);
          } else if (lastStatus != currentStatus) {
            tempList.add({
              'id': order.id,
              'status': currentStatus,
              'total_harga': order.totalHarga,
              'updated_at': order.updatedAt.toIso8601String(),
            });

            await prefs.setString('status_order_$id', currentStatus);
          }
        }
      }

      setState(() {
        notifikasiList = tempList;
      });

      print("DEBUG Notifikasi: $notifikasiList");
    } catch (e) {
      print("ERROR loadNotifikasi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(color: Colors.white)),
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
      body: notifikasiList.isEmpty
          ? Center(child: Text("Tidak ada notifikasi baru"))
          : ListView.builder(
              itemCount: notifikasiList.length,
              itemBuilder: (context, index) {
                final notif = notifikasiList[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.pink),
                    title: Text(
                      "Pesanan #${notif['id']} status: ${notif['status']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Total: ${currencyFormatter.format(notif['total_harga'])}\n"
                      "Update: ${notif['updated_at']}",
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StatusPesananPage(customerId: widget.customerId),
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
