import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';
import 'customer_selection_screen.dart';

class BillingDetailScreen extends StatefulWidget {
  const BillingDetailScreen({super.key});

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
          builder: (_) =>
              CustomerSelectionScreen(
                challanNo: _challanController.text.trim(),
                vehicleNo: _vehicleController.text.trim(),
                date: _selectedDate,
                transport: _transportController.text.trim(),
                lrNo: _lrController.text.trim(),
               // igst: double.tryParse(_igstController.text) ?? 18,
                igst: _gstType == GstTransactionType.interState
                    ? double.tryParse(_igstController.text) ?? 18
                    : 0,
               gstType: _gstType,
               // isInterState: _gstType == GstTransactionType.interState,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Billing Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fill in the invoice details to proceed',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(
                      controller: _challanController,
                      label: 'Challan Number',
                      icon: Icons.receipt_outlined,
                      hint: 'Enter challan number',
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                        controller: _vehicleController,
                        label: 'Vehicle Number',
                        icon: Icons.local_shipping_outlined,
                        hint: 'e.g., GJ-01-AB-1234',
                        enableValidation: false
                    ),
                    const SizedBox(height: 16),

                    _buildDateField(),
                    const SizedBox(height: 16),

                    _buildTextField(
                        controller: _transportController,
                        label: 'Transport Name',
                        icon: Icons.airport_shuttle_outlined,
                        hint: 'Enter transport company name',
                        enableValidation: false
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                        controller: _lrController,
                        label: 'LR Number',
                        icon: Icons.description_outlined,
                        hint: 'Enter LR number',
                        enableValidation: false
                    ),
                    const SizedBox(height: 16),

                    _buildGstTransactionType(),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _igstController,
                      label: 'IGST (%)',
                      icon: Icons.percent_outlined,
                      hint: 'Enter IGST percentage',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _proceedToCustomerSelection,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next: Select Customer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
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
        const Text(
          'Transaction Type (GST)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: Column(
            children: [
              RadioListTile<GstTransactionType>(
                value: GstTransactionType.interState,
                groupValue: _gstType,
                title: const Text('Inter State (IGST)'),
                onChanged: (value) {
                  setState(() {
                    _gstType = value!;
                  });
                },
              ),
              RadioListTile<GstTransactionType>(
                value: GstTransactionType.intraState,
                groupValue: _gstType,
                title: const Text('Intra State (CGST + SGST)'),
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
            width: 32,
            height: 32,
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
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
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
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: enableValidation
              ? (v) {
            if (v == null || v
                .trim()
                .isEmpty) {
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
        const Text(
          'Invoice Date',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            hintText: 'Select date',
            prefixIcon: const Icon(
                Icons.calendar_today_outlined, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (v) =>
          v
              ?.trim()
              .isEmpty ?? true ? 'Date is required' : null,
        ),
      ],
    );
  }
}

enum GstTransactionType { intraState, interState }

