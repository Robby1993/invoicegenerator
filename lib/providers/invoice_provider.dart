import 'package:flutter/foundation.dart';
import 'package:invoicegenerator/database_helper.dart';
import 'package:invoicegenerator/models/customer.dart';
import 'package:invoicegenerator/models/product.dart';
import '../models/invoice.dart';

/*class InvoiceProvider with ChangeNotifier {
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
}*/

class InvoiceProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  List<Invoice> invoices = [];

  int _lastInvoiceNo = 0;

  String getNextInvoiceNumber1() {
    _lastInvoiceNo++;
    return _lastInvoiceNo.toString().padLeft(4, '0');
  }


 /* Future<void> initInvoiceNumber() async {
    _lastInvoiceNo = await _db.getLastInvoiceNumber();
  }*/

  String getNextInvoiceNumber() {
    _lastInvoiceNo++;
    return _lastInvoiceNo.toString().padLeft(4, '0');
  }


  Future<void> loadInvoices() async {
    // 🔥 IMPORTANT: init invoice counter from DB
    _lastInvoiceNo = await _db.getLastInvoiceNumber();

    invoices = await _db.getInvoicesFull();
    notifyListeners();
  }

  Future<void> loadInvoices1(
    List<Customer> customers,
    List<Product> products,
  ) async {
    invoices = await _db.getInvoices(customers, products);
    notifyListeners();
  }

  Future<void> addInvoice(Invoice invoice) async {
    await _db.insertInvoice(invoice);
    invoices.insert(0, invoice);
    notifyListeners();
  }

  Future<void> deleteInvoice1(int invoiceId) async {
    await _db.deleteInvoice(invoiceId);
    invoices.removeWhere((i) => i.id == invoiceId);
    notifyListeners();
  }

  Future<void> deleteInvoice(int invoiceId) async {
    await _db.deleteInvoice(invoiceId);
    invoices.removeWhere((i) => i.id == invoiceId);
    notifyListeners(); // 🔥 REQUIRED
  }

}
