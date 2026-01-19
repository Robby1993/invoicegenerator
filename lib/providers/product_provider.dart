import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(int index, Product product) {
    if (index >= 0 && index < _products.length) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(int index) {
    if (index >= 0 && index < _products.length) {
      _products.removeAt(index);
      notifyListeners();
    }
  }

  Product? getProductByHSN(String hsnCode) {
    try {
      return _products.firstWhere((p) => p.hsnCode == hsnCode);
    } catch (e) {
      return null;
    }
  }
}
