import 'package:flutter/material.dart';
import 'package:invoicegenerator/utils/responsive.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/invoice_item.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';
import 'billing_detail_screen.dart';
import 'invoice_preview_screen.dart';

class InvoiceConfirmScreen extends StatefulWidget {
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
  final List<InvoiceItem> items;

  const InvoiceConfirmScreen({
    super.key,
    this.invoiceId,
    this.invoiceNo,
    required this.challanNo,
    required this.vehicleNo,
    required this.date,
    required this.transport,
    required this.lrNo,
    required this.percent,
    required this.gstType,
    required this.customer,
    required this.items,
  });

  @override
  State<InvoiceConfirmScreen> createState() => _InvoiceConfirmScreenState();
}

class _InvoiceConfirmScreenState extends State<InvoiceConfirmScreen> {
  bool _isGenerating = false;

  double _calculateSubtotal() {
    return widget.items.fold(0.0, (sum, item) => sum + item.total);
  }

  double _calculateIGST() {
    return _calculateSubtotal() * (widget.percent / 100);
  }

  double _calculateGrandTotal() {
    return _calculateSubtotal() + _calculateIGST();
  }

  Future<void> _generateInvoice() async {
    setState(() {
      _isGenerating = true;
    });

    // Simulate a brief delay for better UX
    await Future.delayed(const Duration(milliseconds: 800));

    final provider = context.read<InvoiceProvider>();
    final invoiceNo = widget.invoiceNo ?? await provider.getNextInvoiceNumber();

    final invoice = Invoice(
      id: widget.invoiceId,
      invoiceNo: invoiceNo,
      customer: widget.customer,
      challanNo: widget.challanNo,
      vehicleNo: widget.vehicleNo,
      date: widget.date,
      transport: widget.transport,
      lrNo: widget.lrNo,
      items: widget.items,
      percent: widget.percent,
      gstType: widget.gstType,
    );

    if (widget.invoiceId != null) {
      await provider.updateInvoice(invoice);
    } else {
      await provider.addInvoice(invoice);
    }

    if (mounted) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.i,
                height: 80.i,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50.i,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                widget.invoiceId != null ? 'Invoice Updated!' : 'Invoice Generated!',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                'Invoice #$invoiceNo',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 24.h),
              Text(
                'Your invoice has been successfully created and saved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => InvoicePreviewScreen(invoice: invoice),
                  ),
                  (route) => route.isFirst,
                );
              },
              child: Text('View Invoice', style: TextStyle(fontSize: 14.sp)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Done', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
      );
    }

    setState(() {
      _isGenerating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final subtotal = _calculateSubtotal();
    final bool isInterState = widget.gstType == GstTransactionType.interState;

    final double gstPercent = widget.percent;

    double cgst = 0.0;
    double sgst = 0.0;
    double igst = 0.0;

    if (isInterState) {
      igst = subtotal * gstPercent / 100;
    } else {
      cgst = subtotal * (gstPercent / 2) / 100;
      sgst = subtotal * (gstPercent / 2) / 100;
    }

    final grandTotal = subtotal + cgst + sgst + igst;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review & Confirm', style: TextStyle(fontSize: 20.sp)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
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
                  _buildStepConnector(true),
                  _buildStepIndicator(4, 'Confirm', true),
                ],
              ),
            ),

            // Invoice Details Section
            Container(
              margin: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, color: Colors.black, size: 24.i),
                        SizedBox(width: 12.w),
                        Text(
                          'Invoice Details',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Challan No.',
                          widget.challanNo,
                          Icons.receipt_outlined,
                        ),
                        if (widget.vehicleNo.isNotEmpty)
                          _buildInfoRow(
                            'Vehicle No.',
                            widget.vehicleNo,
                            Icons.local_shipping_outlined,
                          ),
                        _buildInfoRow(
                          'Date',
                          DateFormat('dd/MM/yyyy').format(widget.date),
                          Icons.calendar_today_outlined,
                        ),
                        if (widget.transport.isNotEmpty)
                          _buildInfoRow(
                            'Transport',
                            widget.transport,
                            Icons.airport_shuttle_outlined,
                          ),
                        if (widget.lrNo.isNotEmpty)
                          _buildInfoRow(
                            'LR No.',
                            widget.lrNo,
                            Icons.description_outlined,
                          ),
                        if (isInterState)
                          _buildInfoRow(
                            'IGST',
                            '${gstPercent.toStringAsFixed(2)}%',
                            Icons.percent_outlined,
                          ),

                        if (!isInterState) ...[
                          _buildInfoRow(
                            'CGST',
                            '${(gstPercent / 2).toStringAsFixed(2)}%',
                            Icons.percent_outlined,
                          ),
                          _buildInfoRow(
                            'SGST',
                            '${(gstPercent / 2).toStringAsFixed(2)}%',
                            Icons.percent_outlined,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Customer Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.green, size: 24.i),
                        SizedBox(width: 12.w),
                        Text(
                          'Customer Information',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.customer.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16.i,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 8.w),
                            Text(widget.customer.mobile, style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16.i,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                '${widget.customer.address}, ${widget.customer.city}, ${widget.customer.state} - ${widget.customer.pincode}',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                        if (widget.customer.gstNumber.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.badge,
                                size: 16.i,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 8.w),
                              Text('GST: ${widget.customer.gstNumber}', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Products Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2, color: Colors.orange, size: 24.i),
                        SizedBox(width: 12.w),
                        Text(
                          'Products (${widget.items.length})',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.r),
                    itemCount: widget.items.length,
                    separatorBuilder: (_, __) => Divider(height: 24.h),
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40.i,
                            height: 40.i,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'HSN: ${item.product.hsnCode}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Qty: ${item.netWeight} × ₹${item.product.salePrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${item.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Totals Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.r),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _totalRow('Subtotal', subtotal),

                  if (isInterState)
                    _totalRow('IGST (${gstPercent.toStringAsFixed(2)}%)', igst),

                  if (!isInterState) ...[
                    _totalRow(
                      'CGST (${(gstPercent / 2).toStringAsFixed(2)}%)',
                      cgst,
                    ),
                    _totalRow(
                      'SGST (${(gstPercent / 2).toStringAsFixed(2)}%)',
                      sgst,
                    ),
                  ],

                  Divider(height: 24.h),

                  _totalRow('Grand Total', grandTotal, isGrand: true),
                ],
              ),
            ),

            SizedBox(height: 100.h),
          ],
        ),
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
            onPressed: _isGenerating ? null : _generateInvoice,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
            child: _isGenerating
                ? SizedBox(
                    height: 24.i,
                    width: 24.i,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 24.i),
                      SizedBox(width: 12.w),
                      Text(
                        'Generate Invoice',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool isGrand = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrand ? 18.sp : 16.sp,
              fontWeight: isGrand ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isGrand ? 22.sp : 16.sp,
              fontWeight: FontWeight.bold,
              color: isGrand ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
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
              color: isActive ? Colors.black : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive
                  ? Icon(Icons.check, color: Colors.white, size: 18.i)
                  : Text(
                      '$step',
                      style: TextStyle(
                        color: Colors.grey.shade600,
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
              color: isActive ? Colors.black : Colors.grey.shade600,
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
        color: isActive ? Colors.black : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.i, color: Colors.grey.shade600),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
