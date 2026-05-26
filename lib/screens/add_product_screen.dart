import 'package:flutter/material.dart';
import 'package:invoicegenerator/utils/responsive.dart';
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
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product', style: TextStyle(fontSize: 20.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRODUCT',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.sp,
                  letterSpacing: 1.w,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _nameController,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16.r),
                ),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Name is required' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _hsnController,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'HSN Code',
                  hintStyle: TextStyle(fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16.r),
                ),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'HSN Code is required' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _priceController,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Sale Price',
                  hintStyle: TextStyle(fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16.r),
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
              SizedBox(height: 32.h),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 48.w,
                      vertical: 16.h,
                    ),
                    backgroundColor: Colors.grey[400],
                  ),
                  child: Text(
                    'SAVE',
                    style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.bold),
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
