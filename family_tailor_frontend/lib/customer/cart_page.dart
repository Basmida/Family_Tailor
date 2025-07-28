import 'dart:convert';
import 'package:family_tailor_frontend/customer/CheckoutPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  List<bool> selectedItems = [];
  bool selectAll = false;

  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  /// ✅ Ambil keranjang per user dari SharedPreferences
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id_customer') ?? 0;

    final cartData = prefs.getStringList('cart_$userId') ?? [];

    print("DEBUG loadCart() - Key: cart_$userId, Data: $cartData");

    setState(() {
      cartItems = cartData
          .map((item) => jsonDecode(item))
          .toList()
          .cast<Map<String, dynamic>>();

      /// Pastikan quantity minimal 1
      for (var item in cartItems) {
        if (item['quantity'] == null || item['quantity'] <= 0) {
          item['quantity'] = 1;
        }
      }

      selectedItems = List.generate(cartItems.length, (index) => false);
      selectAll = false;
    });
  }

  /// ✅ Simpan keranjang per user ke SharedPreferences
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id_customer') ?? 0;

    await prefs.setStringList(
      'cart_$userId',
      cartItems.map((item) => jsonEncode(item)).toList(),
    );

    print("DEBUG saveCart() - Key: cart_$userId, Data: $cartItems");
  }

  /// ✅ Update jumlah item (tambah/kurang)
  Future<void> updateQuantity(int index, int change) async {
    setState(() {
      cartItems[index]['quantity'] =
          (int.tryParse(cartItems[index]['quantity'].toString()) ?? 1) + change;

      if (cartItems[index]['quantity'] <= 0) {
        cartItems.removeAt(index);
        selectedItems.removeAt(index);
      }
    });
    await saveCart();
  }

  /// ✅ Hitung total harga dari item yang dipilih
  int getSelectedTotal() {
    int total = 0;
    for (int i = 0; i < cartItems.length; i++) {
      if (selectedItems[i]) {
        final int harga = int.tryParse(cartItems[i]['harga'].toString()) ?? 0;
        final int quantity =
            int.tryParse(cartItems[i]['quantity'].toString()) ?? 1;
        total += harga * quantity;
      }
    }
    return total;
  }

  /// ✅ Fungsi "Pilih Semua"
  void toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      for (int i = 0; i < selectedItems.length; i++) {
        selectedItems[i] = selectAll;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keranjang", style: TextStyle(color: Colors.white)),
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
      body: cartItems.isEmpty
          ? Center(child: Text("Keranjang kosong"))
          : Column(
              children: [
                /// ✅ Checkbox "Pilih Semua"
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selectAll,
                        onChanged: toggleSelectAll,
                      ),
                      Text("Pilih Semua",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                /// ✅ List produk di keranjang
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final int harga =
                          int.tryParse(item['harga'].toString()) ?? 0;
                      final int quantity =
                          int.tryParse(item['quantity'].toString()) ?? 1;

                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// ✅ Checkbox per item
                              Checkbox(
                                value: selectedItems[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedItems[index] = value ?? false;
                                    selectAll = selectedItems
                                        .every((element) => element == true);
                                  });
                                },
                              ),
                              Image.network(
                                item['gambar'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama_produk'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5),

                                    /// ✅ Harga & Jumlah
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          currencyFormatter.format(harga),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.red),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                  Icons.remove_circle_outline,
                                                  size: 18,
                                                  color: Colors.grey),
                                              onPressed: () =>
                                                  updateQuantity(index, -1),
                                            ),
                                            Text(
                                              "$quantity",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                  Icons.add_circle_outline,
                                                  size: 18,
                                                  color: Colors.grey),
                                              onPressed: () =>
                                                  updateQuantity(index, 1),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total: ${currencyFormatter.format(getSelectedTotal())}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () async {
                final List<Map<String, dynamic>> selectedForCheckout = [];
                for (int i = 0; i < cartItems.length; i++) {
                  if (selectedItems[i]) {
                    selectedForCheckout.add(cartItems[i]);
                  }
                }

                if (selectedForCheckout.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Pilih produk yang ingin di-checkout")),
                  );
                } else {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(
                        produkList: selectedForCheckout,
                      ),
                    ),
                  );

                  /// ✅ Refresh keranjang setelah checkout
                  if (result == true) {
                    await loadCart();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF270650),
              ),
              child: Text("Checkout", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
