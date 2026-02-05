import 'package:flutter/material.dart';
import 'package:invoicegenerator/database_helper.dart';
import 'package:invoicegenerator/models/product.dart';

class ProductProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;
  List<Product> products = [];

  Future<void> loadProducts() async {
    products = await _db.getProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _db.insertProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(int id, Product product) async {
    await _db.updateProduct(product.copyWith(id: id));
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _db.deleteProduct(id);
    await loadProducts();
  }
}
