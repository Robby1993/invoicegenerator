import 'package:flutter/material.dart';
import 'package:invoicegenerator/utils/responsive.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import 'add_customer_screen.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer List', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          if (provider.customers.isEmpty) {
            return Center(
              child: Text(
                'Data not found',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: provider.customers.length,
            itemBuilder: (context, index) {
              final customer = provider.customers[index];
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
                            _InfoRow(label: 'Customer Name', value: customer.name),
                            _InfoRow(label: 'Mobile', value: customer.mobile),
                            _InfoRow(label: 'Address', value: customer.address),
                            _InfoRow(label: 'City', value: customer.city),
                            _InfoRow(label: 'State', value: customer.state),
                            _InfoRow(label: 'Pincode', value: customer.pincode),
                            _InfoRow(label: 'GST Number', value: customer.gstNumber),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, size: 24.i),
                            onPressed: () {
                              _showDeleteDialog(context, provider, index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, size: 24.i),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddCustomerScreen(
                                    index: index,
                                    customer: customer,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );
        },
        child: Icon(Icons.add, size: 24.i),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    CustomerProvider provider,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Customer', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this customer?', style: TextStyle(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCustomer(index);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
          ),
        ],
      ),
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
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14.sp))),
        ],
      ),
    );
  }
}
