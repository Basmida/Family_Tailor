import 'dart:convert';
import 'package:family_tailor_frontend/model/OrderDetailModel.dart';
import 'package:family_tailor_frontend/model/OrderProdukRilisModel.dart';
import 'package:family_tailor_frontend/model/OrderKatalogModel.dart';
import 'package:http/http.dart' as http;

class OrderService {
  // ✅ Lama (jika mau lihat semua pesanan produk rilis tanpa filter customer)
  static Future<List<OrderProdukRilis>> fetchOrders() async {
    final response = await http
        .get(Uri.parse('http://192.168.100.65:8000/api/order-produk-rilis'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderProdukRilis.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data pesanan');
    }
  }

  // ✅ Detail Produk Rilis
  static Future<OrderDetailModel> fetchOrderDetailModel(int id) async {
    final response = await http.get(
      Uri.parse('http://192.168.100.65:8000/api/order-produk-rilis/$id'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return OrderDetailModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail pesanan produk rilis');
    }
  }

  // ✅ Pesanan berdasarkan customer (gabungan katalog + produk rilis)
  static Future<Map<String, List>> fetchPesananByCustomer(
      int customerId) async {
    final response = await http.get(Uri.parse(
        'http://192.168.100.65:8000/api/pesanan?customer_id=$customerId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];

      List<OrderKatalog> katalogOrders = (data['order_katalog'] as List)
          .map((json) => OrderKatalog.fromJson(json))
          .toList();

      List<OrderProdukRilis> produkRilisOrders =
          (data['order_produk_rilis'] as List)
              .map((json) => OrderProdukRilis.fromJson(json))
              .toList();

      return {
        "order_katalog": katalogOrders,
        "order_produk_rilis": produkRilisOrders,
      };
    } else {
      throw Exception('Gagal memuat data pesanan customer');
    }
  }

  // ✅ Tambahan Baru → Detail Order Katalog
  static Future<OrderKatalog> fetchOrderKatalogDetail(int id) async {
    final response = await http.get(
      Uri.parse('http://192.168.100.65:8000/api/order-katalog/$id'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return OrderKatalog.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail pesanan katalog');
    }
  }
}
