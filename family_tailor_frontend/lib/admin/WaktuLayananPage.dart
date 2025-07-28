import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'TambahUkuranBadanPage.dart';
import 'package:family_tailor_frontend/model/Customer.dart';

class PilihWaktuLayananPage extends StatefulWidget {
  final Customer customer;
  final String jenisLayanan;

  PilihWaktuLayananPage({required this.customer, required this.jenisLayanan});

  @override
  _PilihWaktuLayananPageState createState() => _PilihWaktuLayananPageState();
}

class _PilihWaktuLayananPageState extends State<PilihWaktuLayananPage> {
  final List<int> durasiOptions = [2, 4, 7];
  int? selectedDurasi;

  Future<void> createLayanan(BuildContext context) async {
    if (selectedDurasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silakan pilih durasi layanan terlebih dahulu")),
      );
      return;
    }

    final url = Uri.parse('http://192.168.100.65:8000/api/layanan');
    final harga = widget.jenisLayanan == 'custom' ? 50000 : 30000;

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "customer_id": widget.customer.id,
        "jenis_layanan": widget.jenisLayanan,
        "harga": harga,
        "waktu_layanan": selectedDurasi
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      if (widget.jenisLayanan == 'custom') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TambahUkuranBadanPage(order: data),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Layanan berhasil disimpan")),
        );
        Navigator.pop(context); // kembali ke halaman sebelumnya
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan layanan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pilih Waktu Layanan Jahit"),
        backgroundColor: Colors.purple[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Anda perlu menentukan waktu layanan jahit ${widget.jenisLayanan.toUpperCase()} sesuai keinginan pelanggan",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 24),
            ...durasiOptions.map((durasi) {
              final isSelected = selectedDurasi == durasi;
              return Card(
                color: isSelected ? Colors.green[100] : null,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text("${widget.jenisLayanan.toUpperCase()} $durasi HARI"),
                  trailing: ElevatedButton(
                    child: Text("PILIH"),
                    onPressed: () {
                      setState(() {
                        selectedDurasi = durasi;
                      });

                      // Jika custom, langsung simpan dan lanjut ke TambahUkuranBadan
                      if (widget.jenisLayanan == 'custom') {
                        createLayanan(context);
                      }
                    },
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: widget.jenisLayanan != 'custom'
              ? () => createLayanan(context)
              : null, // nonaktifkan jika custom
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.jenisLayanan != 'custom'
                ? Colors.green
                : Colors.grey,
            minimumSize: Size(double.infinity, 48),
          ),
          child: Text("Simpan", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
