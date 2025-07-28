import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TambahUkuranBadanPage extends StatefulWidget {
  final dynamic order;

  const TambahUkuranBadanPage({super.key, required this.order});

  @override
  State<TambahUkuranBadanPage> createState() => _TambahUkuranBadanPageState();
}

class _TambahUkuranBadanPageState extends State<TambahUkuranBadanPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'lingkar_dada': TextEditingController(),
    'lebar_depan': TextEditingController(),
    'lebar_pundak': TextEditingController(),
    'panjang_depan': TextEditingController(),
    'lingkar_panggul': TextEditingController(),
    'tinggi_nat': TextEditingController(),
    'lebar_nat': TextEditingController(),
    'panjang_baju': TextEditingController(),
    'lingkar_pinggang': TextEditingController(),
    'panjang_lengan': TextEditingController(),
    'lingkar_tangan': TextEditingController(),
    'panjang_rok': TextEditingController(),
  };

  final TextEditingController durasiController = TextEditingController();

  Future<void> submitUkuran() async {
    final id = widget.order['id'];
    final url = Uri.parse('http://192.168.100.65:8000/api/order-katalog/$id/ukuran-badan');

    Map<String, dynamic> body = {
      'durasi_estimasi': int.tryParse(durasiController.text) ?? 7,
    };

    for (var entry in controllers.entries) {
      body[entry.key] = double.tryParse(entry.value.text) ?? 0.0;
    }

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ukuran badan berhasil disimpan")),
      );
      Navigator.pop(context); // kembali ke halaman sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan ukuran")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Ukuran Badan"),
        backgroundColor: Colors.purple[300],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ...controllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: entry.key.replaceAll('_', ' ').toUpperCase(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
              }).toList(),

              TextFormField(
                controller: durasiController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Durasi Estimasi (hari)',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitUkuran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[300],
                  minimumSize: Size(double.infinity, 45),
                ),
                child: Text("Simpan Ukuran"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
