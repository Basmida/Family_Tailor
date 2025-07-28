import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:family_tailor_frontend/model/ProdukRilisModel.dart';

class EditProdukRilis extends StatefulWidget {
  final ProdukRilis produkRilis;

  const EditProdukRilis({Key? key, required this.produkRilis})
      : super(key: key);

  @override
  State<EditProdukRilis> createState() => _EditProdukRilisState();
}

class _EditProdukRilisState extends State<EditProdukRilis> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController namaController;
  late TextEditingController hargaController;
  late TextEditingController ukuranController;
  late TextEditingController spesifikasiController;
  late TextEditingController deskripsiController;
  late TextEditingController keteranganController;

  Uint8List? _imageBytes;
  String? _fileName;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.produkRilis.namaProduk);
    hargaController =
        TextEditingController(text: widget.produkRilis.harga.toString());
    ukuranController = TextEditingController(text: widget.produkRilis.ukuran);
    spesifikasiController =
        TextEditingController(text: widget.produkRilis.spesifikasi);
    deskripsiController =
        TextEditingController(text: widget.produkRilis.deskripsiProduk);
    keteranganController =
        TextEditingController(text: widget.produkRilis.keterangan ?? '');
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
    final uri = Uri.parse(
        'http://192.168.100.65:8000/api/produk-rilis/${widget.produkRilis.id}');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    request.fields['_method'] = 'PUT'; // Laravel override method untuk edit

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
      final responseString = await response.stream.bytesToString();
      print("Status: ${response.statusCode}, Body: $responseString");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk rilis berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui produk rilis')),
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
    final imageUrl =
        'http://192.168.100.65:8000/storage/produk_rilis/${widget.produkRilis.gambar ?? ""}';

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Produk Rilis", style: TextStyle(color: Colors.white)),
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
              _buildInputField(namaController, "Nama Produk", true),
              _buildInputField(hargaController, "Harga", true,
                  keyboardType: TextInputType.number),
              _buildInputField(ukuranController, "Ukuran", true),
              _buildInputField(spesifikasiController, "Spesifikasi", true),
              _buildInputField(deskripsiController, "Deskripsi Produk", true),
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
