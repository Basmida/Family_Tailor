class OrderKatalog {
  final int id;
  final String namaCustomer;
  final String namaProduk;
  final String gambar;
  final String estimasiSelesai;
  final String totalHarga;
  final String status;

  OrderKatalog({
    required this.id,
    required this.namaCustomer,
    required this.namaProduk,
    required this.gambar,
    required this.estimasiSelesai,
    required this.totalHarga,
    required this.status,
  });

  factory OrderKatalog.fromJson(Map<String, dynamic> json) {
    return OrderKatalog(
      id: json['order_id'] ?? 0,
      // ✅ Backend sekarang TIDAK kirim nama_customer, jadi fallback ke "-"
      namaCustomer: json['nama_customer'] ?? '-',
      namaProduk: json['nama_produk'] ?? 'Produk Tidak Diketahui',
      gambar: json['gambar'] ?? '',
      estimasiSelesai: json['estimasi_selesai']?.toString() ??
          '-', // ✅ Backend sekarang SUDAH kirim
      totalHarga: json['total_harga']?.toString() ?? '0',
      status: json['status'] ?? 'diantrian',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': id,
      'nama_customer': namaCustomer,
      'nama_produk': namaProduk,
      'gambar': gambar,
      'estimasi_selesai': estimasiSelesai,
      'total_harga': totalHarga,
      'status': status,
    };
  }
}
