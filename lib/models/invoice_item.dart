import 'package:invoicegenerator/models/product.dart';

class InvoiceItem {
  final int? id;
  final int? invoiceId;
  final Product product;
  final double netWeight;
  final double total;

  InvoiceItem({
    this.id,
    this.invoiceId,
    required this.product,
    required this.netWeight,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'productId': product.id,
      'netWeight': netWeight,
      'total': total,
    };
  }

  InvoiceItem copyWith({
    int? id,
    int? invoiceId,
    double? netWeight,
    double? total,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      product: product,
      netWeight: netWeight ?? this.netWeight,
      total: total ?? this.total,
    );
  }
}

