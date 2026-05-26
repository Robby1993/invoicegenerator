import 'package:flutter/material.dart';
import 'package:invoicegenerator/utils/responsive.dart';
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

  void _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.customer?.id,
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        gstNumber: _gstController.text.trim(),
      );

      final provider = context.read<CustomerProvider>();

      if (widget.customer != null) {
        await provider.updateCustomer(customer.id!, customer);
      } else {
        await provider.addCustomer(customer);
      }

      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer != null ? 'Edit Customer' : 'Add Customer', style: TextStyle(fontSize: 20.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
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
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: _saveCustomer,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 16.h),
                  backgroundColor: Colors.grey[400],
                ),
                child: Text('SAVE', style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.bold)),
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
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(fontSize: 14.sp),
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.all(16.r),
        ),
        keyboardType: keyboardType,
        validator: required
            ? (v) => v?.trim().isEmpty ?? true ? '$label is required' : null
            : null,
      ),
    );
  }
}
