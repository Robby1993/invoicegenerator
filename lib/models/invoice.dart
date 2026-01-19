import 'package:intl/intl.dart';
import 'package:invoicegenerator/screens/billing_detail_screen.dart';
import 'customer.dart';
import 'invoice_item.dart';

class Invoice {
  final String invoiceNo;
  final Customer customer;
  final String challanNo;
  final String vehicleNo;
  final DateTime date;
  final String transport;
  final String lrNo;
  final List<InvoiceItem> items;
  final double igst;
  final GstTransactionType gstType;

  Invoice({
    required this.invoiceNo,
    required this.customer,
    required this.challanNo,
    required this.vehicleNo,
    required this.date,
    required this.transport,
    required this.lrNo,
    required this.items,
    this.igst = 0.0,
    required this.gstType,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get cgst => subtotal * 0.09;
  double get sgst => subtotal * 0.09;
  double get total => subtotal + cgst + sgst + igst;

  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);
}
