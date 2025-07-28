import 'dart:convert';
import 'package:family_tailor_frontend/admin/FormTambahPelanggan.dart';
import 'package:family_tailor_frontend/admin/JenisLayanan.dart';
import 'package:family_tailor_frontend/model/Customer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DaftarPelangganPage extends StatefulWidget {
  @override
  _DaftarPelangganPageState createState() => _DaftarPelangganPageState();
}

class _DaftarPelangganPageState extends State<DaftarPelangganPage> {
  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    _searchController.addListener(_searchCustomer);
  }

  Future<void> fetchCustomers() async {
    final response = await http.get(Uri.parse('http://192.168.100.65:8000/api/customer/getAll'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      setState(() {
        _allCustomers = jsonData.map((e) => Customer.fromJson(e)).toList();
        _filteredCustomers = _allCustomers;
      });
    } else {
      throw Exception('Gagal mengambil data pelanggan');
    }
  }

  void _searchCustomer() {
    String keyword = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _allCustomers.where((c) {
        return c.nama.toLowerCase().contains(keyword) ||
            c.noHp.contains(keyword);
      }).toList();
    });
  }

  Future<void> deleteCustomer(int customerId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.100.65:8000/api/customer/delete/$customerId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _allCustomers.removeWhere((c) => c.id == customerId);
        _filteredCustomers.removeWhere((c) => c.id == customerId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pelanggan berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus pelanggan')),
      );
    }
  }

  void _showDeleteConfirmationDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Pelanggan"),
        content: Text("Apakah kamu yakin ingin menghapus '${customer.nama}'?"),
        actions: [
          TextButton(
            child: Text("Batal"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Hapus", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              deleteCustomer(customer.id);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Pelanggan", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF270650), Color(0xFFFF30BA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
        ),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nama atau no. handphone',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FormTambahPelangganPage()),
                    );
                  },
                ),
                filled: true,
                fillColor: Colors.purple.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: _filteredCustomers.isEmpty
                ? Center(child: Text("Tidak ada pelanggan"))
                : ListView.builder(
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.pink.shade100,
                            child: Text(
                              customer.nama[0].toUpperCase(),
                              style: TextStyle(color: Color(0xFFFF30BA)),
                            ),
                          ),
                          title: Text(customer.nama),
                          subtitle: Text(customer.noHp),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      JenisLayananPage(customer: customer),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Color(0xFFFF30BA),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Color(0xFFFF30BA)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Pilih'),
                          ),
                          onLongPress: () =>
                              _showDeleteConfirmationDialog(customer),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
