import 'dart:convert';
import 'package:family_tailor_frontend/customer/MidtransPayment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutKatalogPage extends StatefulWidget {
  final Map<String, dynamic> produk;

  CheckoutKatalogPage({required this.produk});

  @override
  _CheckoutKatalogPageState createState() => _CheckoutKatalogPageState();
}

class _CheckoutKatalogPageState extends State<CheckoutKatalogPage> {
  String? sumberBahan = 'pelanggan';
  String? metodePembayaran = 'transfer';
  DateTime? selectedDate;
  Map<String, dynamic>? customerData;

  @override
  void initState() {
    super.initState();
    _getCustomerProfile();
    print("Data Produk: ${widget.produk}");
  }

  Future<void> _getCustomerProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idCustomer = prefs.getInt('id_customer');

    if (token != null && idCustomer != null) {
      final response = await http.get(
        Uri.parse('http://192.168.100.65:8000/api/customer/$idCustomer'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        setState(() {
          customerData = jsonData['customer'];
        });
      } else {
        print('Gagal memuat data customer');
      }
    }
  }

  String formatRupiah(double value) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  double get hargaMin =>
      double.tryParse(widget.produk['harga_minimum'].toString()) ?? 0.0;
  double get hargaMax =>
      double.tryParse(widget.produk['harga_maksimum'].toString()) ?? 0.0;
  double get hargaFinal => sumberBahan == 'penjahit' ? hargaMax : hargaMin;

  Future<void> _buatPesanan() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silakan isi tanggal ukur badan")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idCustomer = prefs.getInt('id_customer');

    if (token == null || idCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login tidak valid")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("http://192.168.100.65:8000/api/order-katalog"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "id_customer": idCustomer,
        "id_produk_katalog": widget.produk['id'],
        "sumber_bahan": sumberBahan,
        "metode_pembayaran": metodePembayaran,
        "jadwal_ukur_badan": selectedDate!.toIso8601String(),
        "total_harga": hargaFinal
      }),
    );

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];

        if (metodePembayaran == 'transfer') {
          final idOrderKatalog = data['id'];

          final midtransResponse = await http.post(
            Uri.parse("http://192.168.100.65:8000/api/midtrans"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json"
            },
            body: jsonEncode({"order_id": idOrderKatalog}),
          );

          print("Midtrans Response: ${midtransResponse.body}");

          if (midtransResponse.statusCode == 200) {
            final midtransData = jsonDecode(midtransResponse.body);
            final snapToken = midtransData['token'];

            if (snapToken != null && snapToken != '') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MidtransPaymentPage(token: snapToken),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Token pembayaran kosong")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal mengambil token pembayaran")),
            );
          }
        } else {
          // Kalau COD, langsung berhasil
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Pesanan berhasil dibuat (COD)")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print("Terjadi kesalahan parsing response: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan saat memproses pesanan")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat pesanan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pesan Sekarang", style: TextStyle(color: Colors.white)),
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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Informasi customer
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.location_pin, color: Colors.purple),
                  SizedBox(width: 10),
                  Expanded(
                    child: customerData != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${customerData!['nama']} - ${customerData!['no_hp']}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text("${customerData!['alamat']}",
                                  style: TextStyle(color: Colors.blue)),
                            ],
                          )
                        : Text("Memuat data customer..."),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Informasi produk
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.produk['gambar'],
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.produk['deskripsi'], maxLines: 3),
                    SizedBox(height: 8),
                    Text(
                      formatRupiah(hargaFinal),
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Tanggal ukur badan
          Text("Jadwal Ukur Badan",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(border: OutlineInputBorder()),
              child: Text(
                selectedDate == null
                    ? 'Pilih Tanggal'
                    : DateFormat('dd/MM/yyyy').format(selectedDate!),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Sumber bahan
          Text("Sumber Bahan Jahit",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: Text("Bahan dari pelanggan"),
            leading: Radio<String>(
              value: 'pelanggan',
              groupValue: sumberBahan,
              onChanged: (value) => setState(() => sumberBahan = value),
            ),
          ),
          ListTile(
            title: Text("Bahan dari penjahit"),
            leading: Radio<String>(
              value: 'penjahit',
              groupValue: sumberBahan,
              onChanged: (value) => setState(() => sumberBahan = value),
            ),
          ),
          SizedBox(height: 8),

          // Metode pembayaran
          Text("Metode Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: Text("Bayar di tempat"),
            leading: Radio<String>(
              value: 'bayar_ditempat',
              groupValue: metodePembayaran,
              onChanged: (value) => setState(() => metodePembayaran = value),
            ),
          ),
          ListTile(
            title: Text("Transfer"),
            leading: Radio<String>(
              value: 'transfer',
              groupValue: metodePembayaran,
              onChanged: (value) => setState(() => metodePembayaran = value),
            ),
          ),
          SizedBox(height: 16),
          Divider(),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(formatRupiah(hargaFinal), style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(height: 80),
        ],
      ),

      // Tombol bawah
      bottomNavigationBar: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text("Batalkan", style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: _buatPesanan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child:
                  Text("Buat Pesanan", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
