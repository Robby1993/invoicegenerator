class Product {
  final int? id;
  final String name;
  final String hsnCode;
  final double salePrice;

  Product({
    this.id,
    required this.name,
    required this.hsnCode,
    required this.salePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hsnCode': hsnCode,
      'salePrice': salePrice,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      hsnCode: map['hsnCode'],
      salePrice: map['salePrice'],
    );
  }

  Product copyWith({int? id}) {
    return Product(
      id: id ?? this.id,
      name: name,
      hsnCode: hsnCode,
      salePrice: salePrice,
    );
  }
}
