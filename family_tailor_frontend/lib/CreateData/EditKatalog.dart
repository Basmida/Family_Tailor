import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:family_tailor_frontend/model/KatalogModel.dart';

class EditKatalog extends StatefulWidget {
  final Katalog katalog;

  const EditKatalog({Key? key, required this.katalog}) : super(key: key);

  @override
  State<EditKatalog> createState() => _EditKatalogState();
}

class _EditKatalogState extends State<EditKatalog> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final spesifikasiController = TextEditingController();
  final hargaMinController = TextEditingController();
  final hargaMaxController = TextEditingController();
  final keteranganController = TextEditingController();

  Uint8List? _imageBytes;
  String? _fileName;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    namaController.text = widget.katalog.namaProduk;
    deskripsiController.text = widget.katalog.deskripsiProduk;
    spesifikasiController.text = widget.katalog.spesifikasi;
    hargaMinController.text = widget.katalog.hargaMinimum.toString();
    hargaMaxController.text = widget.katalog.hargaMaksimum.toString();
    keteranganController.text = widget.katalog.keterangan;
  }

  Future<void> _pickImage() async {
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
    final uri =
        Uri.parse('http://192.168.100.65:8000/api/katalog/${widget.katalog.id}');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    request.fields['_method'] = 'PUT'; // Laravel override method untuk edit

    // Tambahkan field teks
    request.fields.addAll({
      'nama_produk': namaController.text,
      'deskripsi_produk': deskripsiController.text,
      'spesifikasi': spesifikasiController.text,
      'harga_minimum': hargaMinController.text,
      'harga_maksimum': hargaMaxController.text,
      'keterangan': keteranganController.text,
    });

    // Tambahkan file gambar jika ada perubahan
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
      final responseString = await response.stream.bytesToString();
      print("Status: ${response.statusCode}, Body: $responseString");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui produk')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    bool required, {
    int maxLength = 1000,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
    final imageUrl =
        'http://192.168.100.65:8000/storage/katalog/${widget.katalog.gambar}';

    return Scaffold(
      appBar: AppBar(
        title:
            Text("Edit Produk Katalog", style: TextStyle(color: Colors.white)),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Gambar Produk",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10),
              Center(
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, height: 180)
                    : Image.network(
                        imageUrl,
                        height: 180,
                        errorBuilder: (context, error, stackTrace) {
                          return Text("Gambar lama tidak tersedia");
                        },
                      ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text("Pilih Gambar Baru"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purple,
                ),
              ),
              SizedBox(height: 16),
              _buildInputField(namaController, "Nama Produk", true,
                  maxLength: 50),
              _buildInputField(deskripsiController, "Deskripsi Produk", true),
              _buildInputField(
                  spesifikasiController, "Spesifikasi Bahan", false),
              _buildInputField(hargaMinController, "Harga Minimum", true,
                  keyboardType: TextInputType.number),
              _buildInputField(hargaMaxController, "Harga Maksimum", true,
                  keyboardType: TextInputType.number),
              _buildInputField(keteranganController, "Keterangan", false),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _submitData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.all(12),
                ),
                child: Text("Simpan", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
