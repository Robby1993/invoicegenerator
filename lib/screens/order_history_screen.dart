import 'package:flutter/material.dart';
import 'package:invoicegenerator/models/invoice.dart';
import 'package:invoicegenerator/utils/responsive.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import 'invoice_preview_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(title: Text('Order History', style: TextStyle(fontSize: 20.sp))),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, _) {
          if (provider.invoices.isEmpty) {
            return Center(
              child: Text(
                'No orders yet',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: provider.invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = provider.invoices[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  InvoicePreviewScreen(invoice: invoice),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _InfoRow(
                                      label: 'Invoice No.',
                                      value: invoice.invoiceNo,
                                    ),
                                    _InfoRow(
                                      label: 'Customer Name',
                                      value: invoice.customer.name,
                                    ),
                                    _InfoRow(
                                      label: 'Mobile',
                                      value: invoice.customer.mobile,
                                    ),
                                    _InfoRow(
                                      label: 'Invoice Date',
                                      value: invoice.formattedDate,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete, size: 24.i),
                                    onPressed: () {
                                      _showDeleteDialog(
                                        context,
                                        provider,
                                        invoice,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.receipt, size: 24.i),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => InvoicePreviewScreen(
                                            invoice: invoice,
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
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8BBD0),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'TOTAL ( ${provider.invoices.length} )',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    InvoiceProvider provider,
    Invoice invoice,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Invoice', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this invoice?', style: TextStyle(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteInvoice(invoice.id!);
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
