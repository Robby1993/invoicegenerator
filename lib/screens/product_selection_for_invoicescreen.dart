import 'package:flutter/material.dart';
import 'package:invoicegenerator/models/invoice.dart';
import 'package:invoicegenerator/utils/responsive.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/invoice_item.dart';
import 'invoice_confirm_screen.dart';

class ProductSelectionForInvoiceScreen extends StatefulWidget {
  final int? invoiceId;
  final String? invoiceNo;
  final String challanNo;
  final String vehicleNo;
  final DateTime date;
  final String transport;
  final String lrNo;
  final double percent;
  final GstTransactionType gstType;
  final Customer customer;
  final List<InvoiceItem>? existingItems;

  const ProductSelectionForInvoiceScreen({
    super.key,
    this.invoiceId,
    this.invoiceNo,
    required this.challanNo,
    required this.vehicleNo,
    required this.date,
    required this.transport,
    required this.lrNo,
    required this.percent,
    required this.customer,
    required this.gstType,
    this.existingItems,
  });

  @override
  State<ProductSelectionForInvoiceScreen> createState() =>
      _ProductSelectionForInvoiceScreenState();
}

class _ProductSelectionForInvoiceScreenState
    extends State<ProductSelectionForInvoiceScreen> {
  late final List<InvoiceItem> _selectedItems = widget.existingItems != null 
    ? List.from(widget.existingItems!) 
    : [];
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddProductDialog(Product product) {
    final weightController = TextEditingController(text: '1');
    final priceController = TextEditingController(
      text: product.salePrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(product.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HSN Code: ${product.hsnCode}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: priceController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Price per Unit',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    prefixText: '₹ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixIcon: Icon(Icons.currency_rupee, size: 20.i),
                    helperText: 'You can edit the price for this invoice',
                    helperStyle: TextStyle(fontSize: 12.sp),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: weightController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Quantity/Weight',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixIcon: Icon(Icons.scale_outlined, size: 20.i),
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
            ),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text) ?? 0;
                final price = double.tryParse(priceController.text) ?? 0;

                if (weight > 0 && price > 0) {
                  double total = price * weight;
                  // Create a new product with updated price
                  final productWithNewPrice = Product(
                    name: product.name,
                    hsnCode: product.hsnCode,
                    salePrice: price,
                  );

                  setState(() {
                    _selectedItems.add(
                      InvoiceItem(
                        product: productWithNewPrice,
                        netWeight: weight,
                        total: total
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid quantity and price'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              child: Text('Add', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _editItem(int index) {
    final item = _selectedItems[index];
    final weightController =
    TextEditingController(text: item.netWeight.toString());
    final priceController = TextEditingController(
      text: item.product.salePrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit ${item.product.name}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HSN Code: ${item.product.hsnCode}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: priceController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Price per Unit',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    prefixText: '₹ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixIcon: Icon(Icons.currency_rupee, size: 20.i),
                    helperText: 'Edit price for this invoice only',
                    helperStyle: TextStyle(fontSize: 12.sp),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: weightController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    labelText: 'Quantity/Weight',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixIcon: Icon(Icons.scale_outlined, size: 20.i),
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
            ),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text) ?? 0;
                final price = double.tryParse(priceController.text) ?? 0;

                if (weight > 0 && price > 0) {
                  double total = price * weight;
                  // Create a new product with updated price
                  final productWithNewPrice = Product(
                    name: item.product.name,
                    hsnCode: item.product.hsnCode,
                    salePrice: price,
                  );

                  setState(() {
                    _selectedItems[index] = InvoiceItem(
                      product: productWithNewPrice,
                      netWeight: weight,
                      total: total
                    );
                  });
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid quantity and price'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              child: Text('Update', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  void _proceedToConfirm() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceConfirmScreen(
          invoiceId: widget.invoiceId,
          invoiceNo: widget.invoiceNo,
          challanNo: widget.challanNo,
          vehicleNo: widget.vehicleNo,
          date: widget.date,
          transport: widget.transport,
          lrNo: widget.lrNo,
          percent: widget.percent,
          gstType: widget.gstType,
          customer: widget.customer,
          items: _selectedItems,
        ),
      ),
    );
  }

  double _calculateTotal() {
    return _selectedItems.fold(
      0.0,
          (sum, item) => sum + item.total,
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Products', style: TextStyle(fontSize: 20.sp)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: EdgeInsets.all(16.r),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                _buildStepIndicator(1, 'Billing', true),
                _buildStepConnector(true),
                _buildStepIndicator(2, 'Customer', true),
                _buildStepConnector(true),
                _buildStepIndicator(3, 'Products', true),
                _buildStepConnector(false),
                _buildStepIndicator(4, 'Confirm', false),
              ],
            ),
          ),

          // Customer Info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            color: Colors.green.shade50,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    widget.customer.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customer.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.customer.mobile,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 24.i),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.r),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, color: Colors.blue, size: 24.i),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, size: 24.i),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.blue, width: 2.r),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.all(16.r),
              ),
            ),
          ),

          // Selected Items Summary
          if (_selectedItems.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.blue, size: 24.i),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedItems.length} items selected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          'Total: ₹${_calculateTotal().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r),
                          ),
                        ),
                        builder: (ctx) => _buildSelectedItemsSheet(),
                      );
                    },
                    child: Text('View', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ),
          SizedBox(height: 16.h),

          // Product List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80.i,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No Products Available',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final filteredProducts =
                provider.products.where((product) {
                  return product.name.toLowerCase().contains(_searchQuery) ||
                      product.hsnCode.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80.i,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No Results Found',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isSelected = _selectedItems
                        .any((item) => item.product.name == product.name);

                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      elevation: isSelected ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: isSelected
                            ? BorderSide(color: Colors.blue, width: 2.r)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: () => _showAddProductDialog(product),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            children: [
                              Container(
                                width: 50.i,
                                height: 50.i,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: Colors.blue,
                                  size: 28.i,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'HSN: ${product.hsnCode}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '₹${product.salePrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: 28.i,
                                )
                              else
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.grey.shade400,
                                  size: 28.i,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, -5.h),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _selectedItems.isEmpty ? null : _proceedToConfirm,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedItems.isEmpty
                      ? 'Select Products to Continue'
                      : 'Next: Review & Confirm',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedItems.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, size: 20.i),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedItemsSheet() {
    Responsive.init(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Selected Products',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 24.i),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.all(16.r),
                itemCount: _selectedItems.length,
                itemBuilder: (context, index) {
                  final item = _selectedItems[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Qty: ${item.netWeight} × ₹${item.product.salePrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '₹${item.total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _editItem(index);
                            },
                            icon: Icon(Icons.edit_outlined, size: 20.i),
                            color: Colors.blue,
                          ),
                          IconButton(
                            onPressed: () {
                              _removeItem(index);
                              if (_selectedItems.isEmpty) {
                                Navigator.pop(context);
                              }
                            },
                            icon: Icon(Icons.delete_outline, size: 20.i),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${_calculateTotal().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32.i,
            height: 32.i,
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isActive ? Colors.blue : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.only(bottom: 20.h),
        color: isActive ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }
}