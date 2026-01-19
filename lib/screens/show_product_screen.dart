import 'package:flutter/material.dart';
import 'package:invoicegenerator/screens/billing_detail_screen.dart';
import 'package:provider/provider.dart';
import '../models/invoice_item.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../providers/invoice_provider.dart';
import 'invoice_preview_screen.dart';

class ShowProductScreen extends StatefulWidget {
  final List<InvoiceItem> items;
  final Customer customer;
  final String challanNo;
  final String vehicleNo;
  final DateTime date;
  final String transport;
  final String lrNo;
  final double igst;
  final GstTransactionType gstType;

  const ShowProductScreen({
    super.key,
    required this.items,
    required this.customer,
    required this.challanNo,
    required this.vehicleNo,
    required this.date,
    required this.transport,
    required this.lrNo,
    required this.igst,
    required this.gstType,
  });

  @override
  State<ShowProductScreen> createState() => _ShowProductScreenState();
}

class _ShowProductScreenState extends State<ShowProductScreen> {
  final List<TextEditingController> _weightControllers = [];

  @override
  void initState() {
    super.initState();
    for (var item in widget.items) {
      _weightControllers.add(
        TextEditingController(text: item.netWeight.toString()),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double _getUpdatedTotal(int index) {
    final weight = double.tryParse(_weightControllers[index].text) ?? 0;
    return widget.items[index].product.salePrice * weight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Product'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
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
                        Row(
                          children: [
                            const Text(
                              'Net Weight : ',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _weightControllers[index],
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.all(8),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Total',
                          value: _getUpdatedTotal(index).toStringAsFixed(2),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        widget.items.removeAt(index);
                        _weightControllers.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _confirmInvoice,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFFF8BBD0),
          ),
          child: const Text('CONFIRM'),
        ),
      ),
    );
  }

  void _confirmInvoice() {
    final provider = context.read<InvoiceProvider>();
    final invoiceNo = provider.getNextInvoiceNumber();

    // Update weights from controllers
    final updatedItems = <InvoiceItem>[];
    for (int i = 0; i < widget.items.length; i++) {
      final weight = double.tryParse(_weightControllers[i].text) ?? 0;
      updatedItems.add(
        InvoiceItem(
          product: widget.items[i].product,
          netWeight: weight,
        ),
      );
    }

    final invoice = Invoice(
      invoiceNo: invoiceNo,
      customer: widget.customer,
      challanNo: widget.challanNo,
      vehicleNo: widget.vehicleNo,
      date: widget.date,
      transport: widget.transport,
      lrNo: widget.lrNo,
      items: updatedItems,
      igst: widget.igst,
      gstType: widget.gstType
    );

    provider.addInvoice(invoice);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePreviewScreen(invoice: invoice),
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
