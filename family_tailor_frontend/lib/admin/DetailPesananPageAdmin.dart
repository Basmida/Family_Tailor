import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:family_tailor_frontend/admin/PesananPageAdmin.dart';
import 'package:family_tailor_frontend/model/OrderDetailModel.dart';

enum StatusPesanan { dikirim, selesai }

class DetailPesananPageAdmin extends StatefulWidget {
  final OrderDetailModel orderDetail;

  const DetailPesananPageAdmin({Key? key, required this.orderDetail})
      : super(key: key);

  @override
  State<DetailPesananPageAdmin> createState() => _DetailPesananPageAdminState();
}

class _DetailPesananPageAdminState extends State<DetailPesananPageAdmin> {
  late OrderDetailModel orderDetail;

  @override
  void initState() {
    super.initState();
    // Menyalin data dari widget ke variabel lokal agar bisa diubah
    orderDetail = widget.orderDetail;
  }

  String _formatEstimasi(String? min, String? max) {
    try {
      if (min == null || max == null) return "Estimasi tiba: -";

      final minDate = DateTime.parse(min);
      final maxDate = DateTime.parse(max);
      final formatter = DateFormat("d MMMM", "id_ID");

      final sameMonth = minDate.month == maxDate.month;
      if (sameMonth) {
        return "Estimasi tiba: ${minDate.day} - ${formatter.format(maxDate)}";
      } else {
        return "Estimasi tiba: ${formatter.format(minDate)} - ${formatter.format(maxDate)}";
      }
    } catch (e) {
      return "Estimasi tiba: -";
    }
  }

  Future<void> updateStatusPembayaran(BuildContext context, int orderId) async {
    final url = Uri.parse(
        'http://192.168.100.65:8000/api/order-produk-rilis/$orderId/update-pembayaran');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status_pembayaran': 'lunas'}),
      );

      if (response.statusCode == 200) {
        // ✅ Perbarui UI karena sudah Stateful
        setState(() {
          orderDetail.statusPembayaran = 'lunas';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status pembayaran berhasil diupdate")),
        );

        // Refresh halaman pesanan
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PesananPageAdmin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update status pembayaran")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  Future<void> updateStatusOrder(
      BuildContext context, int orderId, StatusPesanan status) async {
    final url = Uri.parse(
        'http://192.168.100.65:8000/api/order-produk-rilis/$orderId/status');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status.name.toLowerCase()}),
      );

      if (response.statusCode == 200) {
        setState(() {
          orderDetail.status = status.name.toLowerCase();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> _cancelOrder(BuildContext context, int orderId) async {
    final url = Uri.parse(
        'http://192.168.100.65:8000/api/order-produk-rilis/$orderId/cancel');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pesanan berhasil dibatalkan")),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membatalkan pesanan")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  Future<void> _showConfirmDialog(
      BuildContext context, String title, VoidCallback onConfirm) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content:
              Text("Apakah Anda yakin ingin mengubah status menjadi $title?"),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Ya"),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Batalkan Pesanan"),
          content: Text("Apakah Anda yakin ingin membatalkan pesanan ini?"),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Ya"),
              onPressed: () async {
                await _cancelOrder(context, orderDetail.id);
                Navigator.of(context).pop('refresh');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _detailText(String label, String value) {
    return Text(
      "$label : $value",
      style: GoogleFonts.poppins(fontSize: 13),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onPressed,
      {bool enabled = true}) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: enabled ? const Color(0xFF5A0FC8) : Colors.grey,
            child: Icon(icon, color: enabled ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = orderDetail.customer;
    final produk = orderDetail.detailOrders[0].produkRilis;

    return Scaffold(
      appBar: AppBar(
        title:
            Text("Detail Order Produk", style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Estimasi + Alamat
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatEstimasi(orderDetail.estimasiTibaMin,
                        orderDetail.estimasiTibaMax),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Text("Alamat",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        const Icon(Icons.location_on, color: Color(0xFF5A0FC8)),
                    title: Row(
                      children: [
                        Text(
                          customer.nama ?? '',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10),
                        Text("(${customer.no_hp ?? ''})",
                            style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                    ),
                    subtitle: Text(customer.alamat ?? '',
                        style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),

            // Produk
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBEAFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(16)),
                        child: Image.network(
                          'http://192.168.100.65:8000/storage/${produk?.gambar}',
                          width: 110,
                          height: 170,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("DRESS PESTA",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      "x${orderDetail.detailOrders[0].jumlahItem}",
                                      style: GoogleFonts.poppins()),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _detailText("Pengiriman",
                                  orderDetail.metodePengiriman ?? ''),
                              _detailText("Pembayaran",
                                  orderDetail.metodePembayaran ?? ''),
                              _detailText("Status", orderDetail.status ?? ''),
                              _detailText("Zona", orderDetail.zona ?? ''),
                              _detailText(
                                  "Ongkir",
                                  NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 0)
                                      .format(
                                          double.parse(orderDetail.ongkir))),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 0)
                                      .format(double.parse(orderDetail
                                          .detailOrders[0].hargaPerItem)),
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Total Harga: ",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600)),
                            Text(
                              NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 0)
                                  .format(double.parse(orderDetail.totalHarga)),
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            orderDetail.statusPembayaran,
                            style: GoogleFonts.poppins(
                              color:
                                  orderDetail.statusPembayaran.toLowerCase() ==
                                          "lunas"
                                      ? Colors.green
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Status Order & Tombol
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text("Status Order",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    "Saat ini pesanan masih diantrian,\nsilahkan klik dikirim jika produk sudah dikirim",
                    style: GoogleFonts.poppins(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton(Icons.sync_alt, "Dikirim", () async {
                        if (orderDetail.status == "dikirim") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Pesanan sudah dikirim")),
                          );
                        } else {
                          await _showConfirmDialog(context, "Dikirim",
                              () async {
                            await updateStatusOrder(
                                context, orderDetail.id, StatusPesanan.dikirim);
                          });
                        }
                      },
                          enabled: orderDetail.status != "dikirim" &&
                              orderDetail.status != "selesai"),
                      const SizedBox(width: 20),
                      _actionButton(Icons.check_circle, "Selesai", () async {
                        if (orderDetail.status == "selesai") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Pesanan sudah selesai")),
                          );
                        } else {
                          await _showConfirmDialog(context, "Selesai",
                              () async {
                            await updateStatusOrder(
                                context, orderDetail.id, StatusPesanan.selesai);
                          });
                        }
                      }, enabled: orderDetail.status != "selesai"),
                    ],
                  ),
                ],
              ),
            ),
           
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await _showCancelDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Batalkan Pesanan",
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await _showConfirmDialog(
                    context,
                    "Konfirmasi Pembayaran",
                    () async {
                      await updateStatusPembayaran(context, orderDetail.id);
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Konfirmasi Pembayaran",
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
