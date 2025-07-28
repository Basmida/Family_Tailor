import 'dart:convert';
import 'package:family_tailor_frontend/customer/riwayat_pesanan_page.dart';
import 'package:family_tailor_frontend/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? customerData;
  bool isLoading = true;
  int? customerId; // ✅ Tambahan

  @override
  void initState() {
    super.initState();
    _fetchCustomerData();
  }

  Future<void> _fetchCustomerData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse("http://192.168.100.65:8000/api/customer/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        customerData = data['customer'];
        customerId = customerData?['id']; // ✅ Ambil ID customer
        isLoading = false;
      });

      // ✅ Simpan ke SharedPreferences (sekali fetch biar bisa dipakai halaman lain)
      if (customerId != null) {
        prefs.setInt('customer_id', customerId!);
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data profil")),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("Konfirmasi Logout"),
        content: Text("Apakah Anda yakin ingin keluar dari akun ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.post(
      Uri.parse("http://192.168.100.65:8000/api/customer/logout"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      await prefs.remove('token');
      await prefs.remove('name');
      await prefs.remove('id_customer');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal logout")),
      );
    }
  }

  Widget _buildProfileItem(String title, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          Text(value.isNotEmpty ? value : "-",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple[700]),
            SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text("Profil Saya", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : customerData == null
              ? Center(child: Text("Data tidak tersedia"))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.purple[100],
                          child: Icon(Icons.person_2_rounded,
                              size: 70, color: Colors.purple[700]),
                        ),
                        SizedBox(height: 20),

                        /// ✅ Data profil
                        _buildProfileItem("Nama", customerData!['nama'] ?? '-'),
                        _buildProfileItem(
                            "Email", customerData!['email'] ?? '-'),
                        _buildProfileItem(
                            "No. Handphone", customerData!['no_hp'] ?? '-'),
                        _buildProfileItem(
                            "Alamat", customerData!['alamat'] ?? '-'),

                        SizedBox(height: 20),

                        /// ✅ Menu Riwayat Pesanan
                        _buildMenuItem(
                          title: "Riwayat Pesanan",
                          icon: Icons.history_rounded,
                          onTap: () {
                            if (customerId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RiwayatPesananPage(
                                    customerId: customerId!, // ✅ Kirim ID
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("ID Customer tidak ditemukan")),
                              );
                            }
                          },
                        ),

                        SizedBox(height: 30),

                        /// ✅ Tombol Logout
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: Icon(Icons.logout, color: Colors.white),
                            label: Text("Logout",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
