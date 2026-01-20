import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final int? index;
  final Product? product;

  const AddProductScreen({super.key, this.index, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _hsnController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _hsnController = TextEditingController(text: widget.product?.hsnCode ?? '');
    _priceController = TextEditingController(
      text: widget.product?.salePrice.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hsnController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveProduct1() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: _nameController.text.trim(),
        hsnCode: _hsnController.text.trim(),
        salePrice: double.parse(_priceController.text.trim()),
      );

      final provider = context.read<ProductProvider>();
      if (widget.index != null) {
        provider.updateProduct(widget.index!, product);
      } else {
        provider.addProduct(product);
      }

      Navigator.pop(context);
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        hsnCode: _hsnController.text.trim(),
        salePrice: double.parse(_priceController.text.trim()),
      );

      final provider = context.read<ProductProvider>();

      if (widget.product != null) {
        await provider.updateProduct(product.id!, product);
      } else {
        await provider.addProduct(product);
      }

      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PRODUCT',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hsnController,
                decoration: const InputDecoration(
                  hintText: 'HSN Code',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'HSN Code is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  hintText: 'Sale Price',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) {
                    return 'Sale Price is required';
                  }
                  if (double.tryParse(v!) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.grey[400],
                  ),
                  child: const Text(
                    'SAVE',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
