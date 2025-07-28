class Customer {
  final int id;
  final String nama;
  final String noHp;
  final String alamat;
  

  Customer({
    required this.id,
    required this.nama,
    required this.noHp,
    required this.alamat,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      nama: json['nama'],
      noHp: json['no_hp'],
      alamat: json['alamat'],
    );
  }
}
