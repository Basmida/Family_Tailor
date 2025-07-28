import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahProdukRilis extends StatefulWidget {
  final Map<String, dynamic>? produk; // mode edit

  const TambahProdukRilis({super.key, this.produk});

  @override
  State<TambahProdukRilis> createState() => _TambahProdukRilisState();
}

class _TambahProdukRilisState extends State<TambahProdukRilis> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final ukuranController = TextEditingController();
  final spesifikasiController = TextEditingController();
  final deskripsiController = TextEditingController();
  final keteranganController = TextEditingController();

  Uint8List? _imageBytes;
  String? _fileName;

  bool get isEdit => widget.produk != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      namaController.text = widget.produk!['nama_produk'] ?? '';
      hargaController.text = widget.produk!['harga'].toString();
      ukuranController.text = widget.produk!['ukuran'] ?? '';
      spesifikasiController.text = widget.produk!['spesifikasi'] ?? '';
      deskripsiController.text = widget.produk!['deskripsi_produk'] ?? '';
      keteranganController.text = widget.produk!['keterangan'] ?? '';
    }
  }

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
    final url = isEdit
        ? Uri.parse('http://192.168.100.65:8000/api/produk-rilis/${widget.produk!['id']}')
        : Uri.parse('http://192.168.100.65:8000/api/produk-rilis');

    http.MultipartRequest request = http.MultipartRequest('POST', url);

    if (isEdit) {
      request.fields['_method'] = 'PUT';
    }

    request.headers['Accept'] = 'application/json';

    request.fields.addAll({
      'nama_produk': namaController.text,
      'harga': hargaController.text,
      'ukuran': ukuranController.text,
      'spesifikasi': spesifikasiController.text,
      'deskripsi_produk': deskripsiController.text,
      'keterangan': keteranganController.text,
    });

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
      final status = response.statusCode;

      print("Status: $status, Body: $respStr");

      if (status == 200 || status == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit
              ? 'Produk berhasil diperbarui'
              : 'Produk berhasil ditambahkan'),
        ));
        Navigator.pop(context, true);
      } else {
        final error = json.decode(respStr);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal: ${error['message'] ?? respStr}'),
        ));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $e'),
      ));
    }
  }

  Widget _buildInputField(TextEditingController controller, String label,
      bool requiredField,
      {int maxLength = 255,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        keyboardType: keyboardType,
        validator: requiredField
            ? (value) =>
                (value == null || value.isEmpty) ? 'Wajib diisi' : null
            : null,
        decoration: InputDecoration(
          labelText: label + (requiredField ? " *" : ""),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Produk Rilis" : "Tambah Produk Rilis",
          style: TextStyle(color: Colors.white),
        ),
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
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                      : widget.produk != null &&
                              widget.produk!['gambar'] != null
                          ? Image.network(
                              'http://192.168.100.65:8000/storage/${widget.produk!['gambar']}',
                              fit: BoxFit.cover)
                          : Icon(Icons.add_a_photo, size: 50),
                ),
              ),
              SizedBox(height: 16),
              _buildInputField(namaController, "Nama Produk", true,
                  maxLength: 25),
              _buildInputField(hargaController, "Harga", true,
                  keyboardType: TextInputType.number),
              _buildInputField(ukuranController, "Ukuran (S/M/L/XL)", true),
              _buildInputField(spesifikasiController, "Spesifikasi", true),
              _buildInputField(deskripsiController, "Deskripsi Produk", true),
              _buildInputField(keteranganController, "Keterangan", false),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitData();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: isEdit ? Colors.orange : Colors.green),
                child: Text(isEdit ? "Perbarui" : "Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
