import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../models/invoice.dart';
import '../utils/pdf_generator.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${invoice.invoiceNo}'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Invoice',
            onPressed: () => _sharePdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: () => _downloadPdf(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => PDFGenerator.generateInvoice(invoice),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: 'Invoice_${invoice.invoiceNo}.pdf',
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.print),
            onPressed: (context, build, pageFormat) async {
              await _printPdf(context);
            },
          ),
        ],
        initialPageFormat: PdfPageFormat.a4,
        maxPageWidth: 700,
      ),
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final pdf = await PDFGenerator.generateInvoice(invoice);
      await Printing.sharePdf(
        bytes: pdf,
        filename: 'Invoice_${invoice.invoiceNo}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final pdf = await PDFGenerator.generateInvoice(invoice);
      await Printing.sharePdf(
        bytes: pdf,
        filename: 'Invoice_${invoice.invoiceNo}.pdf',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF ready to download'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    try {
      final pdf = await PDFGenerator.generateInvoice(invoice);
      await Printing.layoutPdf(
        onLayout: (format) async => pdf,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}