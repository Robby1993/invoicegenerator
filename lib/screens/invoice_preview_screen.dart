import 'package:flutter/material.dart';
import 'package:invoicegenerator/utils/responsive.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../models/invoice.dart';
import '../utils/pdf_generator.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${invoice.invoiceNo}', style: TextStyle(fontSize: 20.sp)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share, size: 24.i),
            tooltip: 'Share Invoice',
            onPressed: () => _sharePdf(context),
          ),
          IconButton(
            icon: Icon(Icons.download, size: 24.i),
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
            icon: Icon(Icons.print, size: 24.i, color: Colors.white),
            onPressed: (context, build, pageFormat) async {
              await _printPdf(context);
            },
          ),
        ],
        initialPageFormat: PdfPageFormat.a4,
        maxPageWidth: 700.w,
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
            content: Text('Error sharing PDF: $e', style: TextStyle(fontSize: 14.sp)),
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
          SnackBar(
            content: Text('PDF ready to download', style: TextStyle(fontSize: 14.sp)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e', style: TextStyle(fontSize: 14.sp)),
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
            content: Text('Error printing PDF: $e', style: TextStyle(fontSize: 14.sp)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}