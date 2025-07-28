class Katalog {
  final int id;
  final String namaProduk;
  final String? gambar; // Ubah menjadi nullable
  final String deskripsiProduk;
  final String spesifikasi;
  final double hargaMinimum;
  final double hargaMaksimum;

  final String keterangan;

  Katalog({
    required this.id,
    required this.namaProduk,
    this.gambar,
    required this.deskripsiProduk,
    required this.spesifikasi,
    required this.hargaMinimum,
    required this.hargaMaksimum,
    required this.keterangan,
  });

  factory Katalog.fromJson(Map<String, dynamic> json) {
    return Katalog(
      id: json['id'],
      namaProduk: json['nama_produk'],
      gambar: json['gambar'],
      deskripsiProduk: json['deskripsi_produk'],
      spesifikasi: json['spesifikasi'],
      hargaMinimum: double.tryParse(json['harga_minimum'].toString()) ?? 0.0,
      hargaMaksimum: double.tryParse(json['harga_maksimum'].toString()) ?? 0.0,
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_produk': namaProduk,
      'gambar': gambar,
      'deskripsi_produk': deskripsiProduk,
      'spesifikasi': spesifikasi,
      'harga_minimum': hargaMinimum,
      'harga_maksimum': hargaMaksimum,
      'keterangan': keterangan,
    };
  }
}
