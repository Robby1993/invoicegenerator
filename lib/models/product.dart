class Product {
  final String name;
  final String hsnCode;
  final double salePrice;

  Product({
    required this.name,
    required this.hsnCode,
    required this.salePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hsnCode': hsnCode,
      'salePrice': salePrice,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'],
      hsnCode: map['hsnCode'],
      salePrice: map['salePrice'],
    );
  }
}
