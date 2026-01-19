import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';

class AddCustomerScreen extends StatefulWidget {
  final int? index;
  final Customer? customer;

  const AddCustomerScreen({super.key, this.index, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _gstController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _mobileController.text = widget.customer!.mobile;
      _addressController.text = widget.customer!.address;
      _cityController.text = widget.customer!.city;
      _stateController.text = widget.customer!.state;
      _pincodeController.text = widget.customer!.pincode;
      _gstController.text = widget.customer!.gstNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        gstNumber: _gstController.text.trim(),
      );

      final provider = context.read<CustomerProvider>();
      if (widget.index != null) {
        provider.updateCustomer(widget.index!, customer);
      } else {
        provider.addCustomer(customer);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer != null ? 'Edit Customer' : 'Add Customer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_mobileController, 'Mobile', TextInputType.phone),
              _buildTextField(_addressController, 'Address'),
              _buildTextField(_cityController, 'City'),
              _buildTextField(_stateController, 'State'),
              _buildTextField(_pincodeController, 'Pincode', TextInputType.number),
              _buildTextField(_gstController, 'GST Number', null, false),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveCustomer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  backgroundColor: Colors.grey[400],
                ),
                child: const Text('SAVE', style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType? keyboardType,
    bool required = true,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(16),
        ),
        keyboardType: keyboardType,
        validator: required
            ? (v) => v?.trim().isEmpty ?? true ? '$label is required' : null
            : null,
      ),
    );
  }
}
