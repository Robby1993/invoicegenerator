import 'package:flutter/material.dart';
import 'package:invoicegenerator/utils/responsive.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';
import 'billing_detail_screen.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final List<InvoiceItem> _selectedItems = [];
  Product? _selectedProduct;
  final _weightController = TextEditingController(text: '0');
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addProduct() {
    if (_selectedProduct != null) {
      final weight = double.tryParse(_weightController.text) ?? 0;

      if (weight > 0) {
        final total = weight * _selectedProduct!.salePrice;

        setState(() {
          _selectedItems.add(
            InvoiceItem(
              product: _selectedProduct!,
              netWeight: weight,
              total: total,
            ),
          );
          _weightController.text = '';
          _selectedProduct = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid weight')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Selection', style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 24.i),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedItems.isEmpty
                ? _buildProductSelector()
                : _buildSelectedItemsList(),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProductSelector() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.products.isEmpty) {
          return Center(child: Text('No products available', style: TextStyle(fontSize: 16.sp)));
        }

        final product = _selectedProduct ?? provider.products.first;
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Product Name', value: product.name),
                  _InfoRow(label: 'HSN Code', value: product.hsnCode),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text('Sale Price : ', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      Expanded(
                        child: TextFormField(
                          initialValue: product.salePrice.toString(),
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            isDense: true,
                            border: const OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12.r),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Text('Net Weight : ', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            isDense: true,
                            border: const OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12.r),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _InfoRow(label: 'Total', value: _calculateTotal(product)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _calculateTotal(Product product) {
    final weight = double.tryParse(_weightController.text) ?? 0;
    return (product.salePrice * weight).toStringAsFixed(2);
  }

  Widget _buildSelectedItemsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: _selectedItems.length,
      itemBuilder: (context, index) {
        final item = _selectedItems[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(label: 'Product Name', value: item.product.name),
                      _InfoRow(label: 'HSN Code', value: item.product.hsnCode),
                      _InfoRow(
                        label: 'Sale Price',
                        value: item.product.salePrice.toString(),
                      ),
                      _InfoRow(
                        label: 'Net Weight',
                        value: item.netWeight.toString(),
                      ),
                      _InfoRow(
                        label: 'Total',
                        value: item.total.toStringAsFixed(2),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.i),
                  onPressed: () {
                    setState(() => _selectedItems.removeAt(index));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16.r),
                backgroundColor: const Color(0xFFF8BBD0),
              ),
              child: Text('ADD NEW PRODUCT', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedItems.isEmpty
                  ? null
                  : () {
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16.r),
                backgroundColor: const Color(0xFFF8BBD0),
              ),
              child: Text('SHOW PRODUCT', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer<ProductProvider>(
          builder: (context, provider, _) {
            return AlertDialog(
              title: Text('Select Product', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return ListTile(
                      title: Text(product.name, style: TextStyle(fontSize: 14.sp)),
                      subtitle: Text('HSN: ${product.hsnCode}', style: TextStyle(fontSize: 12.sp)),
                      onTap: () {
                        setState(() => _selectedProduct = product);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Text('$label : ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14.sp))),
        ],
      ),
    );
  }
}
