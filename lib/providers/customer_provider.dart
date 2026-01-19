import 'package:flutter/foundation.dart';
import '../models/customer.dart';

class CustomerProvider with ChangeNotifier {
  final List<Customer> _customers = [];

  List<Customer> get customers => List.unmodifiable(_customers);

  void addCustomer(Customer customer) {
    _customers.add(customer);
    notifyListeners();
  }

  void updateCustomer(int index, Customer customer) {
    if (index >= 0 && index < _customers.length) {
      _customers[index] = customer;
      notifyListeners();
    }
  }

  void deleteCustomer(int index) {
    if (index >= 0 && index < _customers.length) {
      _customers.removeAt(index);
      notifyListeners();
    }
  }
}
