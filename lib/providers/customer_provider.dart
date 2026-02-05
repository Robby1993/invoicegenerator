import 'package:flutter/material.dart';
import 'package:invoicegenerator/database_helper.dart';
import 'package:invoicegenerator/models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  List<Customer> customers = [];

  Future<void> loadCustomers() async {
    customers = await _db.getCustomers();
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    await _db.insertCustomer(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(int id, Customer customer) async {
    await _db.updateCustomer(
      customer.copyWith(id: id),
    );
    await loadCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    await _db.deleteCustomer(id);
    await loadCustomers();
  }
}
