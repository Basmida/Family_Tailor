import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:family_tailor_frontend/admin/TambahUkuranBadanPage.dart';

class DetailPesananCustom extends StatelessWidget {
  final dynamic order;

  const DetailPesananCustom({Key? key, required this.order}) : super(key: key);

  Future<void> updateStatus(BuildContext context, String status) async {
    final response = await http.put(
      Uri.parse('http://192.168.100.65:8000/api/order-katalog/${order['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"status": status}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status berhasil diperbarui!")),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui status")),

      );
    }
  }

  Future<void> updatePembayaran(BuildContext context) async {
    final response = await http.put(
      Uri.parse(
          'http://192.168.100.65:8000/api/order-katalog/${order['id']}/pembayaran'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"status_pembayaran": "lunas"}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status pembayaran berhasil diperbarui!")),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui status pembayaran")),
      );
    }
  }

  Future<void> _showConfirmDialog(BuildContext context, String statusLabel,
      Future<void> Function() onConfirm) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi"),
        content: Text(
            "Apakah Anda yakin ingin mengubah status menjadi '$statusLabel'?"),
        actions: [
          TextButton(
            child: Text("Tidak"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text("Ya"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await onConfirm();
    }
  }

  Widget _actionButton(
    IconData icon,
    String label,
    VoidCallback onPressed, {
    required bool enabled,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? Colors.green : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final katalog = order['katalog'];
    final customer = order['customer'];
    final ukuran = order['ukuran_badan'];
    final String status = order['status'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Produksi Jahit", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF270650), Color(0xFFFF30BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Produk
            Container(
              height: 190,
              decoration: BoxDecoration(
                color: Color(0xFFFBEAFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(16)),
                        child: Image.network(
                          'http://192.168.100.65:8000/storage/${katalog['gambar']}',
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer['nama'],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold)),
                              Text("${katalog['nama_produk']} / Full jahit",
                                  style: GoogleFonts.poppins()),
                              Text(
                                  "Est. Selesai Tgl ${order['estimasi_selesai']}",
                                  style: GoogleFonts.poppins(
                                      color: Colors.purple, fontSize: 13)),
                              const SizedBox(height: 8),
                              Text("Catatan:",
                                  style: GoogleFonts.poppins(fontSize: 13)),
                              Text(katalog['keterangan'] ?? "-",
                                  style: GoogleFonts.poppins(fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: Text(
                      order['status_pembayaran'] == 'belum_lunas'
                          ? "Belum Bayar"
                          : "Lunas",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: order['status_pembayaran'] == 'lunas'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ukuran Badan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ukuran Pelanggan:",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  if (ukuran == null)
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5A0FC8)),
                        onPressed: () {
                          // Paksa order ini dianggap sebagai custom
                          final modifiedOrder = {
                            ...order,
                            'jenis_layanan': 'custom',
                          };

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TambahUkuranBadanPage(order: modifiedOrder),
                            ),
                          );
                        },
                        child: Text("Tambah Ukuran Badan",
                            style: GoogleFonts.poppins()),
                      ),
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUkuranItem(
                                  "Lingkar Dada", ukuran['lingkar_dada']),
                              _buildUkuranItem(
                                  "Lebar Depan", ukuran['lebar_depan']),
                              _buildUkuranItem(
                                  "Lebar Pundak", ukuran['lebar_pundak']),
                              _buildUkuranItem(
                                  "Panjang Depan", ukuran['panjang_depan']),
                              _buildUkuranItem(
                                  "Lingkar Panggul", ukuran['lingkar_panggul']),
                              _buildUkuranItem(
                                  "Tinggi Nat", ukuran['tinggi_nat']),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUkuranItem(
                                  "Lebar Nat", ukuran['lebar_nat']),
                              _buildUkuranItem(
                                  "Panjang Baju", ukuran['panjang_baju']),
                              _buildUkuranItem("Lingkar Pinggang",
                                  ukuran['lingkar_pinggang']),
                              _buildUkuranItem(
                                  "Panjang Lengan", ukuran['panjang_lengan']),
                              _buildUkuranItem(
                                  "Lingkar Tangan", ukuran['lingkar_tangan']),
                              _buildUkuranItem(
                                  "Panjang Rok", ukuran['panjang_rok']),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status Produksi dan Tombol
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text("Status Produksi",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    "Saat ini order jahit masih ${order['status']},\nsilahkan klik tombol jika status ingin diperbarui.",
                    style: GoogleFonts.poppins(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton(Icons.sync_alt, "Diproses", () async {
                        if (status == "diproses" || status == "selesai") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("Pesanan sudah diproses/selesai")),
                          );
                          return;
                        }
                        await _showConfirmDialog(context, "Diproses", () async {
                          await updateStatus(context, "diproses");
                        });
                      }, enabled: status != "diproses" && status != "selesai"),
                      const SizedBox(width: 20),
                      _actionButton(Icons.check_circle, "Selesai", () async {
                        if (status == "selesai") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Pesanan sudah selesai")),
                          );
                          return;
                        }
                        await _showConfirmDialog(context, "Selesai", () async {
                          await updateStatus(context, "selesai");
                        });
                      }, enabled: status != "selesai"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // Bottom Bar
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
                onPressed: () {
                  // TODO: Batalkan pesanan
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
                onPressed: order['status_pembayaran'] == 'lunas'
                    ? null
                    : () {
                        _showConfirmDialog(context, "Pembayaran Lunas",
                            () async {
                          await updatePembayaran(context);
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: order['status_pembayaran'] == 'lunas'
                      ? Colors.grey
                      : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Konfirmasi Pembayaran",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUkuranItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(label, style: GoogleFonts.poppins(fontSize: 13)),
          ),
          Text(": ",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
            child: Text(
              "$value",
              style: GoogleFonts.poppins(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
