class ProdukRilis {
  final int id;
  final String namaProduk;
  final double harga;
  final String? gambar;
  final String ukuran;
  final String spesifikasi;
  final String deskripsiProduk;
  final String? keterangan;

  ProdukRilis({
    required this.id,
    required this.namaProduk,
    required this.harga,
    this.gambar,
    required this.ukuran,
    required this.spesifikasi,
    required this.deskripsiProduk,
    this.keterangan,
  });

  // Factory method to create an instance from JSON
  factory ProdukRilis.fromJson(Map<String, dynamic> json) {
    return ProdukRilis(
      id: json['id'],
      namaProduk: json['nama_produk'],
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      gambar: json['gambar'],
      ukuran: json['ukuran'],
      spesifikasi: json['spesifikasi'],
      deskripsiProduk: json['deskripsi_produk'],
      keterangan: json['keterangan'],
    );
  }

  // Convert instance to JSON (for POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'nama_produk': namaProduk,
      'harga': harga,
      'gambar': gambar,
      'ukuran': ukuran,
      'spesifikasi': spesifikasi,
      'deskripsi_produk': deskripsiProduk,
      'keterangan': keterangan,
    };
  }
}
