import 'dart:convert';
import 'package:family_tailor_frontend/admin/DaftarPelanggan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormTambahPelangganPage extends StatefulWidget {
  @override
  _FormTambahPelangganPageState createState() => _FormTambahPelangganPageState();
}

class _FormTambahPelangganPageState extends State<FormTambahPelangganPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('http://192.168.100.65:8000/api/customer/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': _namaController.text,
          'email': _emailController.text,
          'no_hp': _noHpController.text,
          'alamat': _alamatController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pelanggan berhasil ditambahkan')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=> DaftarPelangganPage())); // Kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan pelanggan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Pelanggan'),
        backgroundColor: Color(0xFF270650),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email wajib diisi' : null,
              ),
              TextFormField(
                controller: _noHpController,
                decoration: InputDecoration(labelText: 'No HP'),
                validator: (value) => value!.isEmpty ? 'No HP wajib diisi' : null,
              ),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
                validator: (value) => value!.isEmpty ? 'Alamat wajib diisi' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF270650),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
