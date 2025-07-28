import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TambahStokBahanBakuPage extends StatefulWidget {
  final Map<String, dynamic>?
      stokBahan; // Menambahkan parameter stokBahan untuk Edit

  const TambahStokBahanBakuPage({super.key, this.stokBahan});

  @override
  _TambahStokBahanBakuPageState createState() =>
      _TambahStokBahanBakuPageState();
}

class _TambahStokBahanBakuPageState extends State<TambahStokBahanBakuPage> {
  final _formKey = GlobalKey<FormState>();
  final namaBahanController = TextEditingController();
  final tanggalMasukController = TextEditingController();
  final jumlahController = TextEditingController();
  String selectedSatuan = 'meter'; // Default value for Satuan
  final hargaBeliController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Jika ada stok bahan yang diterima untuk edit, kita isi data di form
    if (widget.stokBahan != null) {
      final stokBahan = widget.stokBahan!;
      namaBahanController.text = stokBahan['nama_bahan'];
      tanggalMasukController.text = stokBahan['tanggal_masuk'];
      jumlahController.text = stokBahan['jumlah'].toString();
      selectedSatuan = stokBahan['satuan'];
      hargaBeliController.text = stokBahan['harga_beli'].toString();
    }
  }

  // Fungsi untuk menyimpan atau mengupdate stok bahan baku

  void simpanStok() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => isLoading = true);

        final response = widget.stokBahan ==
                null // Jika stokBahan null, artinya ini mode tambah
            ? await http.post(
                Uri.parse('http://192.168.100.65:8000/api/stok'),
                headers: {"Content-Type": "application/json"},
                body: json.encode({
                  'nama_bahan': namaBahanController.text,
                  'tanggal_masuk': tanggalMasukController.text,
                  'jumlah': int.parse(jumlahController.text),
                  'satuan': selectedSatuan,
                  'harga_beli': double.parse(hargaBeliController.text).round(),
                }),
              )
            : await http.put(
                Uri.parse(
                    'http://192.168.100.65:8000/api/stok/${widget.stokBahan!['id']}'),
                headers: {"Content-Type": "application/json"},
                body: json.encode({
                  'nama_bahan': namaBahanController.text,
                  'tanggal_masuk': tanggalMasukController.text,
                  'jumlah': int.parse(jumlahController.text),
                  'satuan': selectedSatuan,
                  'harga_beli': double.parse(hargaBeliController.text).round(),
                }),
              );

        setState(() => isLoading = false);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.stokBahan == null
                ? 'Stok Bahan Berhasil Ditambahkan'
                : 'Stok Bahan Berhasil Diperbarui'),
          ));
          Navigator.pop(context,
              true); // Mengirimkan true untuk menunjukkan bahwa data berhasil disimpan atau diperbarui
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal menambahkan stok bahan: ${response.body}'),
          ));
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  // Fungsi untuk memilih tanggal dengan showDatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        tanggalMasukController.text =
            "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.stokBahan == null ? "Tambah Stok Bahan" : "Edit Stok Bahan",
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
                  end: Alignment.bottomRight)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Produk
                TextFormField(
                  controller: namaBahanController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Produk tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Tanggal Masuk - Calendar Picker
                TextFormField(
                  controller: tanggalMasukController,
                  readOnly: true, // Membuat field hanya bisa dibaca
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Masuk',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tanggal Masuk tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Jumlah
                TextFormField(
                  controller: jumlahController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Dropdown Satuan (meter, pcs, lusin)
                DropdownButtonFormField<String>(
                  value: selectedSatuan,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSatuan = newValue!;
                    });
                  },
                  items: <String>['meter', 'pcs', 'lusin']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Satuan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Harga Beli
                TextFormField(
                  controller: hargaBeliController,
                  decoration: const InputDecoration(
                    labelText: 'Harga Beli',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga Beli tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Tombol Simpan
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : simpanStok,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Simpan',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
