import 'package:flutter/material.dart';
import 'package:invoicegenerator/models/invoice.dart';
import 'package:invoicegenerator/utils/responsive.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';
import 'customer_selection_screen.dart';

class BillingDetailScreen extends StatefulWidget {
  final Invoice? invoice;
  const BillingDetailScreen({super.key, this.invoice});

  @override
  State<BillingDetailScreen> createState() => _BillingDetailScreenState();
}

class _BillingDetailScreenState extends State<BillingDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _challanController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _dateController = TextEditingController();
  final _transportController = TextEditingController();
  final _lrController = TextEditingController();
  final _igstController = TextEditingController(text: '18');

  DateTime _selectedDate = DateTime.now();

  GstTransactionType _gstType = GstTransactionType.interState;

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _challanController.text = widget.invoice!.challanNo;
      _vehicleController.text = widget.invoice!.vehicleNo;
      _selectedDate = widget.invoice!.date;
      _transportController.text = widget.invoice!.transport;
      _lrController.text = widget.invoice!.lrNo;
      _igstController.text = widget.invoice!.percent.toString();
      _gstType = widget.invoice!.gstType;
    }
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _challanController.dispose();
    _vehicleController.dispose();
    _dateController.dispose();
    _transportController.dispose();
    _lrController.dispose();
    _igstController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateController.text = DateFormat('dd/MM/yyyy').format(date);
      });
    }
  }

  void _proceedToCustomerSelection() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerSelectionScreen(
            invoiceId: widget.invoice?.id,
            invoiceNo: widget.invoice?.invoiceNo,
            challanNo: _challanController.text.trim(),
            vehicleNo: _vehicleController.text.trim(),
            date: _selectedDate,
            transport: _transportController.text.trim(),
            lrNo: _lrController.text.trim(),
            percent: double.tryParse(_igstController.text) ?? 18,
            gstType: _gstType,
            existingCustomer: widget.invoice?.customer,
            existingItems: widget.invoice?.items,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing Details', style: TextStyle(fontSize: 20.sp)),
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
                  _buildStepConnector(false),
                  _buildStepIndicator(2, 'Customer', false),
                  _buildStepConnector(false),
                  _buildStepIndicator(3, 'Products', false),
                  _buildStepConnector(false),
                  _buildStepIndicator(4, 'Confirm', false),
                ],
              ),
            ),

            // Form
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Billing Information',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Fill in the invoice details to proceed',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                    SizedBox(height: 24.h),

                    _buildTextField(
                      controller: _challanController,
                      label: 'Challan Number',
                      icon: Icons.receipt_outlined,
                      hint: 'Enter challan number',
                    ),
                    SizedBox(height: 16.h),

                    _buildTextField(
                      controller: _vehicleController,
                      label: 'Vehicle Number',
                      icon: Icons.local_shipping_outlined,
                      hint: 'e.g., GJ-01-AB-1234',
                      enableValidation: false,
                    ),
                    SizedBox(height: 16.h),

                    _buildDateField(),
                    SizedBox(height: 16.h),

                    _buildTextField(
                      controller: _transportController,
                      label: 'Transport Name',
                      icon: Icons.airport_shuttle_outlined,
                      hint: 'Enter transport company name',
                      enableValidation: false,
                    ),
                    SizedBox(height: 16.h),

                    _buildTextField(
                      controller: _lrController,
                      label: 'LR Number',
                      icon: Icons.description_outlined,
                      hint: 'Enter LR number',
                      enableValidation: false,
                    ),
                    SizedBox(height: 16.h),

                    _buildGstTransactionType(),
                    SizedBox(height: 16.h),

                    _buildTextField(
                      controller: _igstController,
                      label: 'IGST (%)',
                      icon: Icons.percent_outlined,
                      hint: 'Enter IGST percentage',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    SizedBox(height: 32.h), // Bottom padding for scroll
                  ],
                ),
              ),
            ),
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
            onPressed: _proceedToCustomerSelection,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next: Select Customer',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward, size: 20.i),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGstTransactionType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Type (GST)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: Column(
            children: [
              RadioListTile<GstTransactionType>(
                value: GstTransactionType.interState,
                groupValue: _gstType,
                title: Text('Inter State (IGST)', style: TextStyle(fontSize: 14.sp)),
                onChanged: (value) {
                  setState(() {
                    _gstType = value!;
                  });
                },
              ),
              RadioListTile<GstTransactionType>(
                value: GstTransactionType.intraState,
                groupValue: _gstType,
                title: Text('Intra State (CGST + SGST)', style: TextStyle(fontSize: 14.sp)),
                onChanged: (value) {
                  setState(() {
                    _gstType = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool enableValidation = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14.sp),
            prefixIcon: Icon(icon, color: Colors.black, size: 20.i),
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
              borderSide: BorderSide(color: Colors.black, width: 2.r),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.all(16.r),
          ),
          validator: enableValidation
              ? (v) {
                  if (v == null || v.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null, // 👈 skip validation
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice Date',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Select date',
            hintStyle: TextStyle(fontSize: 14.sp),
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: Colors.black,
              size: 20.i,
            ),
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
              borderSide: BorderSide(color: Colors.black, width: 2.r),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.all(16.r),
          ),
          validator: (v) =>
              v?.trim().isEmpty ?? true ? 'Date is required' : null,
        ),
      ],
    );
  }
}

