import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Tambahkatalog extends StatefulWidget {
  const Tambahkatalog({super.key});

  @override
  State<Tambahkatalog> createState() => _TambahkatalogState();
}

class _TambahkatalogState extends State<Tambahkatalog> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final spesifikasiController = TextEditingController();
  final hargaMinController = TextEditingController();
  final hargaMaxController = TextEditingController();
  final keteranganController = TextEditingController();

  Uint8List? _imageBytes;
  String? _fileName;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _fileName = pickedFile.name;
      });
    }
  }

  Future<void> _submitData() async {
    final uri = Uri.parse('http://192.168.100.65:8000/api/katalog');
    final request = http.MultipartRequest('POST', uri);

    // Jangan lupa header Accept agar Laravel tidak redirect
    request.headers['Accept'] = 'application/json';

    // Tambahkan data ke request
    request.fields.addAll({
      'nama_produk': namaController.text,
      'deskripsi_produk': deskripsiController.text,
      'spesifikasi': spesifikasiController.text,
      'harga_minimum': hargaMinController.text,
      'harga_maksimum': hargaMaxController.text,
      'keterangan': keteranganController.text,
    });

    // Tambahkan gambar ke request
    if (_imageBytes != null && _fileName != null) {
      final multipartFile = http.MultipartFile.fromBytes(
        'gambar',
        _imageBytes!,
        filename: _fileName!,
      );
      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print("Status: ${response.statusCode}, Body: $respStr");

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produk berhasil ditambahkan')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menambahkan produk')));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  Widget _buildInputField(
      TextEditingController controller, String label, bool required,
      {int maxLength = 1000, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        keyboardType: keyboardType,
        validator: required
            ? (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null
            : null,
        decoration: InputDecoration(
          labelText: label + (required ? " *" : ""),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Produk Katalog",
            style: TextStyle(color: Colors.white)),
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
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: _imageBytes == null
                      ? Icon(Icons.add_a_photo, size: 50)
                      : Image.memory(_imageBytes!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16),
              _buildInputField(namaController, "Nama Produk", true,
                  maxLength: 50),
              _buildInputField(deskripsiController, "Deskripsi Produk", true),
              _buildInputField(
                  spesifikasiController, "Spesifikasi Bahan", false),
              _buildInputField(hargaMinController, "Harga minimum", true,
                  keyboardType: TextInputType.number),
              _buildInputField(hargaMaxController, "Harga maximum", true,
                  keyboardType: TextInputType.number),
              _buildInputField(keteranganController, "Keterangan", false),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
