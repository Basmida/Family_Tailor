import 'dart:convert';
import 'package:family_tailor_frontend/customer/thank_you_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:family_tailor_frontend/customer/MidtransPayment.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> produkList;

  CheckoutPage({required this.produkList});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _metodePengiriman = 'ambil di tempat';
  String _metodePembayaran = 'bayar ditempat';
  String _zona = 'dalam kota';

  Map<String, dynamic>? _customerData;
  late List<int> _jumlahItemList;

  @override
  void initState() {
    super.initState();
    //Ambil quantity langsung dari produkList yang dikirim CartPage
    _jumlahItemList = widget.produkList.map<int>((produk) {
      final qty = int.tryParse(produk['quantity'].toString()) ?? 1;
      return qty;
    }).toList();

    _getCustomerProfile();
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

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _customerData = jsonData['customer'];
        });
      }
    }
  }

  int _hargaPerItem(int index) {
    final harga = widget.produkList[index]['harga'];
    if (harga is int) return harga;
    if (harga is double) return harga.toInt();
    return double.tryParse(harga.toString())?.toInt() ?? 0;
  }

  int get _subtotal {
    int total = 0;
    for (int i = 0; i < widget.produkList.length; i++) {
      total += _hargaPerItem(i) * _jumlahItemList[i];
    }
    return total;
  }

  int get _ongkir {
    if (_metodePengiriman == 'ambil di tempat') {
      return 0;
    } else {
      return (_zona == 'dalam kota') ? 15000 : 25000;
    }
  }

  int get _totalBayar => _subtotal + _ongkir;

  String formatRupiah(int number) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(number);
  }

  Future<void> _checkout() async {
    final prefs = await SharedPreferences.getInstance();
    final idCustomer = prefs.getInt('id_customer');
    final token = prefs.getString('token');

    if (idCustomer == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal checkout, silakan login ulang.')),
      );
      return;
    }

    final items = widget.produkList.asMap().entries.map((entry) {
      final index = entry.key;
      final produk = entry.value;
      return {
        "produk_rilis_id": produk["id"],
        "jumlah_item": _jumlahItemList[index],
      };
    }).toList();

    final response = await http.post(
      Uri.parse('http://192.168.100.65:8000/api/checkout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "id_customer": idCustomer,
        "metode_pengiriman": _metodePengiriman,
        "metode_pembayaran": _metodePembayaran,
        "zona": _metodePengiriman == "ambil di tempat" ? "dalam kota" : _zona,
        "items": items,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final orderId = body["order"]["id"].toString();

      /// ✅ Hapus item yang sudah di-checkout dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      List<String> savedCart = prefs.getStringList('cart') ?? [];
      savedCart.removeWhere((item) {
        final decoded = jsonDecode(item);
        return widget.produkList.any((checkoutItem) =>
            checkoutItem['id'].toString() == decoded['id'].toString());
      });
      await prefs.setStringList('cart', savedCart);

      if (_metodePembayaran == 'transfer') {
        /// ✅ Midtrans Payment
        final tokenMidtransResponse = await http.post(
          Uri.parse('http://192.168.100.65:8000/api/midtrans'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({"order_id": orderId}),
        );

        print("MIDTRANS STATUS: ${tokenMidtransResponse.statusCode}");
        print("MIDTRANS BODY: ${tokenMidtransResponse.body}");

        if (tokenMidtransResponse.statusCode == 200) {
          final tokenBody = json.decode(tokenMidtransResponse.body);
          final snapToken = tokenBody['token'];

          if (snapToken != null && snapToken.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MidtransPaymentPage(token: snapToken),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Token pembayaran kosong')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mendapatkan token pembayaran')),
          );
        }
      } else {
        /// ✅ Checkout selesai, kembali ke CartPage dengan refresh
        Navigator.pop(context, true);

        /// ✅ Tampilkan Thank You Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ThankYouPage(message: "Pesanan anda akan segera diproses."),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Alamat Customer
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.location_pin, color: Colors.pink),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _customerData != null
                                ? '${_customerData!['nama']}  ${_customerData!['no_hp']}'
                                : 'Memuat data...',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_customerData?['alamat'] ?? ''),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            /// ✅ List Produk
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.produkList.length,
              itemBuilder: (context, index) {
                final produk = widget.produkList[index];
                return Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        produk['gambar'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 60),
                      ),
                    ),
                    title: Text(produk['nama_produk'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatRupiah(_hargaPerItem(index)),
                            style: TextStyle(color: Colors.red, fontSize: 16)),
                        Text(
                          "x${_jumlahItemList[index]}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),

            /// ✅ Metode Pengiriman
            Text("Metode Pengiriman",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            DropdownButtonFormField<String>(
              value: _metodePengiriman,
              items: ['ambil di tempat', 'diantar ke alamat']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _metodePengiriman = value!;
                  _zona = 'dalam kota';
                  if (_metodePengiriman == 'ambil di tempat') {
                    _metodePembayaran = 'bayar ditempat';
                  }
                });
              },
            ),
            SizedBox(height: 16),

            if (_metodePengiriman == 'diantar ke alamat') ...[
              Text("Zona Pengiriman",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              DropdownButtonFormField<String>(
                value: _zona,
                items: ['dalam kota', 'luar kota']
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _zona = value!;
                    if (_zona == 'luar kota') {
                      _metodePembayaran = 'transfer';
                    }
                  });
                },
              ),
              SizedBox(height: 16),
            ],

            Text("Metode Pembayaran",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            DropdownButtonFormField<String>(
              value: _metodePembayaran,
              items: [
                DropdownMenuItem(
                  value: 'bayar ditempat',
                  child: Text('Bayar di Tempat'),
                  enabled: _metodePengiriman == 'ambil di tempat' ||
                      (_metodePengiriman == 'diantar ke alamat' &&
                          _zona == 'dalam kota'),
                ),
                DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
              ],
              onChanged: (value) {
                if (_metodePengiriman == 'diantar ke alamat' &&
                    _zona == 'luar kota' &&
                    value == 'bayar ditempat') {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Luar kota hanya bisa transfer.')));
                  return;
                }
                setState(() => _metodePembayaran = value!);
              },
            ),
            SizedBox(height: 24),

            Card(
              child: ListTile(
                title: Text("Total Pembayaran",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(formatRupiah(_totalBayar),
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 48, 168, 88),
                ),
                child: Text("Checkout",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
