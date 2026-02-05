import 'product.dart';

class InvoiceItem {
  final Product product;
  final double netWeight;

  InvoiceItem({
    required this.product,
    required this.netWeight,
  });

  double get total => product.salePrice * netWeight;
}

