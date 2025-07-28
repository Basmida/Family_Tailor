import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahOperasional extends StatefulWidget {
  const TambahOperasional({Key? key}) : super(key: key);

  @override
  _TambahOperasionalState createState() => _TambahOperasionalState();
}

class _TambahOperasionalState extends State<TambahOperasional> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController namaItemController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  String jenisOperasional = 'pemasukan';

  /// Fungsi helper untuk membuat dua digit angka (contoh: 5 -> 05)
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// Fungsi kirim data ke backend
  Future<void> _submitData() async {
    final url = Uri.parse('http://192.168.100.65:8000/api/operasional');
    final data = {
      'tanggal': tanggalController.text,
      'nama_item': namaItemController.text,
      'jenis_operasional': jenisOperasional,
      'nominal': nominalController.text,
      'keterangan': keteranganController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('Response: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil disimpan')),
        );
        Navigator.pop(context); // kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Fungsi untuk memilih tanggal dari kalender
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // default hari ini
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate =
          "${picked.year}-${_twoDigits(picked.month)}-${_twoDigits(picked.day)}";
      setState(() {
        tanggalController.text = formattedDate; // format sesuai MySQL
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operasional', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF270650), Color(0XffFF30BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Field Tanggal dengan Date Picker
              TextFormField(
                controller: tanggalController,
                readOnly: true,
                onTap: () => _pickDate(context),
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  hintText: 'Pilih tanggal',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nama Item
              TextFormField(
                controller: namaItemController,
                decoration: const InputDecoration(
                  labelText: 'Nama Item',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama item harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Jenis Operasional (Dropdown)
              DropdownButtonFormField<String>(
                value: jenisOperasional,
                decoration: const InputDecoration(
                  labelText: 'Jenis Operasional',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'pemasukan',
                    child: Text('Pemasukan'),
                  ),
                  DropdownMenuItem(
                    value: 'pengeluaran',
                    child: Text('Pengeluaran'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    jenisOperasional = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis operasional harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nominal
              TextFormField(
                controller: nominalController,
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Keterangan
              TextFormField(
                controller: keteranganController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
