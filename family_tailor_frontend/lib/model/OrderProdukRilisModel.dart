class OrderProdukRilis {
  final int id;
  final int idCustomer;
  final String metodePengiriman;
  final String metodePembayaran;
  final String status;
  final String zona;
  final double ongkir;
  final double totalHarga;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status_pembayaran;
  final DateTime? estimasiTibaMin;
  final DateTime? estimasiTibaMax;

  // ✅ Tambahan untuk status pesanan
  final String namaProduk;
  final int jumlahItem;
  final double hargaPerItem;
  final double subtotal;
  final String? gambar; // opsional

  OrderProdukRilis({
    required this.id,
    required this.idCustomer,
    required this.metodePengiriman,
    required this.metodePembayaran,
    required this.status,
    required this.zona,
    required this.ongkir,
    required this.totalHarga,
    required this.createdAt,
    required this.updatedAt,
    required this.status_pembayaran,
    this.estimasiTibaMin,
    this.estimasiTibaMax,
    required this.namaProduk,
    required this.jumlahItem,
    required this.hargaPerItem,
    required this.subtotal,
    this.gambar,
  });

  factory OrderProdukRilis.fromJson(Map<String, dynamic> json) {
    return OrderProdukRilis(
      id: json['order_id'] ?? json['id'] ?? 0,
      idCustomer: json['id_customer'] ?? 0,
      metodePengiriman: json['metode_pengiriman'] ?? '-',
      metodePembayaran: json['metode_pembayaran'] ?? '-',
      status: json['status'] ?? 'diantrian',
      zona: json['zona'] ?? '-',
      ongkir: double.tryParse(json['ongkir']?.toString() ?? '0') ?? 0.0,
      totalHarga: double.tryParse(json['total_harga']?.toString() ?? '0') ?? 0.0,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      status_pembayaran: json['status_pembayaran'] ?? 'belum lunas',

      // ✅ Estimasi tiba min/max → bisa null
      estimasiTibaMin: json['estimasi_tiba_min'] != null
          ? DateTime.tryParse(json['estimasi_tiba_min'].toString())
          : null,
      estimasiTibaMax: json['estimasi_tiba_max'] != null
          ? DateTime.tryParse(json['estimasi_tiba_max'].toString())
          : null,

      // ✅ Parsing tambahan
      namaProduk: json['nama_produk'] ?? 'Produk Tidak Diketahui',
      jumlahItem: json['jumlah_item'] ?? 0,
      hargaPerItem:
          double.tryParse(json['harga_per_item']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      gambar: json['gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': id,
      'id_customer': idCustomer,
      'metode_pengiriman': metodePengiriman,
      'metode_pembayaran': metodePembayaran,
      'status': status,
      'zona': zona,
      'ongkir': ongkir,
      'total_harga': totalHarga,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status_pembayaran': status_pembayaran,
      'estimasi_tiba_min': estimasiTibaMin?.toIso8601String(),
      'estimasi_tiba_max': estimasiTibaMax?.toIso8601String(),

      'nama_produk': namaProduk,
      'jumlah_item': jumlahItem,
      'harga_per_item': hargaPerItem,
      'subtotal': subtotal,
      'gambar': gambar,
    };
  }
}
