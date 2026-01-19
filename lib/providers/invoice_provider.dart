import 'package:flutter/foundation.dart';
import '../models/invoice.dart';

class InvoiceProvider with ChangeNotifier {
  final List<Invoice> _invoices = [];
  int _invoiceCounter = 1;

  List<Invoice> get invoices => List.unmodifiable(_invoices);

  String getNextInvoiceNumber() {
    return 'INV_$_invoiceCounter';
  }

  void addInvoice(Invoice invoice) {
    _invoices.insert(0, invoice);
    _invoiceCounter++;
    notifyListeners();
  }

  void deleteInvoice(int index) {
    if (index >= 0 && index < _invoices.length) {
      _invoices.removeAt(index);
      notifyListeners();
    }
  }
}
