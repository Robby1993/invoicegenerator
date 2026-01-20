import 'package:flutter/material.dart';
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

  /*void _addProduct1() {
    if (_selectedProduct != null) {
      final weight = double.tryParse(_weightController.text) ?? 0;
      if (weight > 0) {
        setState(() {
          _selectedItems.add(
            InvoiceItem(product: _selectedProduct!, netWeight: weight),
          );
          _weightController.text = '0';
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
  }*/

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Selection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
          return const Center(child: Text('No products available'));
        }

        final product = _selectedProduct ?? provider.products.first;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Product Name', value: product.name),
                  _InfoRow(label: 'HSN Code', value: product.hsnCode),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Sale Price : '),
                      Expanded(
                        child: TextFormField(
                          initialValue: product.salePrice.toString(),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Net Weight : '),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(16),
      itemCount: _selectedItems.length,
      itemBuilder: (context, index) {
        final item = _selectedItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                  icon: const Icon(Icons.close),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFFF8BBD0),
              ),
              child: const Text('ADD NEW PRODUCT'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedItems.isEmpty
                  ? null
                  : () {
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BillingDetailScreen(items: _selectedItems),
                        ),
                      );*/
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFFF8BBD0),
              ),
              child: const Text('SHOW PRODUCT'),
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
              title: const Text('Select Product'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('HSN: ${product.hsnCode}'),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
