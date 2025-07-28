class Operasional {
  final String tanggal;
  final String namaItem;
  final double nominal;
  final String jenisOperasional;
  final String? keterangan; // ✅ nullable supaya aman jika null

  Operasional({
    required this.tanggal,
    required this.namaItem,
    required this.nominal,
    required this.jenisOperasional,
    this.keterangan, // ✅ opsional
  });

  factory Operasional.fromJson(Map<String, dynamic> json) {
    return Operasional(
      tanggal: json['tanggal'],
      namaItem: json['nama_item'],
      nominal: double.parse(json['nominal'].toString()),
      jenisOperasional: json['jenis_operasional'],
      keterangan: json['keterangan'], // ✅ bisa null, tidak akan error
    );
  }
}
