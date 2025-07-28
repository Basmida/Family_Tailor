class OrderDetailModel {
  int id;
  String metodePengiriman;
  String metodePembayaran;
  String status;
  String zona;
  String ongkir;
  String totalHarga;
  String statusPembayaran;
  String? estimasiTibaMin;
  String? estimasiTibaMax;
  Customer customer;
  List<DetailOrder> detailOrders;

  OrderDetailModel({
    required this.id,
    required this.metodePengiriman,
    required this.metodePembayaran,
    required this.status,
    required this.zona,
    required this.ongkir,
    required this.totalHarga,
    required this.statusPembayaran,
    this.estimasiTibaMin,
    this.estimasiTibaMax,
    required this.customer,
    required this.detailOrders,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'],
      metodePengiriman: json['metode_pengiriman'],
      metodePembayaran: json['metode_pembayaran'],
      status: json['status'],
      zona: json['zona'],
      ongkir: json['ongkir'],
      totalHarga: json['total_harga'],
      statusPembayaran: json['status_pembayaran'],
      estimasiTibaMin: json['estimasi_tiba_min'],
      estimasiTibaMax: json['estimasi_tiba_max'],
      customer: Customer.fromJson(json['customer']),
      detailOrders: List<DetailOrder>.from(
        json['detail_orders'].map((x) => DetailOrder.fromJson(x)),
      ),
    );
  }
}

class Customer {
  final String nama;
  final String alamat;
  final String no_hp;
  final String email;

  Customer({
    required this.nama,
    required this.alamat,
    required this.no_hp,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      nama: json['nama'],
      alamat: json['alamat'],
      no_hp: json['no_hp'],
      email: json['email'],
    );
  }
}

class DetailOrder {
  final int jumlahItem;
  final String hargaPerItem;
  final String subtotal;
  final ProdukRilis produkRilis;

  DetailOrder({
    required this.jumlahItem,
    required this.hargaPerItem,
    required this.subtotal,
    required this.produkRilis,
  });

  factory DetailOrder.fromJson(Map<String, dynamic> json) {
    return DetailOrder(
      jumlahItem: json['jumlah_item'],
      hargaPerItem: json['harga_per_item'],
      subtotal: json['subtotal'],
      produkRilis: ProdukRilis.fromJson(json['produk_rilis']),
    );
  }
}

class ProdukRilis {
  final String namaProduk;
  final String gambar;

  ProdukRilis({
    required this.namaProduk,
    required this.gambar,
  });

  factory ProdukRilis.fromJson(Map<String, dynamic> json) {
    return ProdukRilis(
      namaProduk: json['nama_produk'],
      gambar: json['gambar'],
    );
  }
}
