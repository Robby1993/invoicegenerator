import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:invoicegenerator/screens/billing_detail_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/invoice.dart';
import 'company_config.dart';

class PDFGenerator {
  static Future<Uint8List> generateInvoice(Invoice invoice) async {
    final pdf = pw.Document();

    final Uint8List logoBytes = (await rootBundle.load(
      'assets/icon/app_icon.png',
    )).buffer.asUint8List();

    final logo = pw.MemoryImage(logoBytes);

    // Pre-calculate all totals
    final subtotal = invoice.items.fold(0.0, (sum, item) => sum + item.total);

    /*bool type = invoice.gstType == GstTransactionType.interState;
    // Split IGST into CGST and SGST (9% each if IGST is 18%)
    final cgst = subtotal * (invoice.igst / 2 / 100);
    final sgst = subtotal * (invoice.igst / 2 / 100);
    // final sgst = subtotal * (invoice.igst / 2 / 100);
    final igstAmount = invoice.gstType == GstTransactionType.interState
        ? 0.0
        : invoice.igst;
    final total = subtotal + cgst + sgst;*/

    final bool isInterState = invoice.gstType == GstTransactionType.interState;

    double cgst = 0.0;
    double sgst = 0.0;
    double igst = 0.0;

    // GST percentage (example: 18)
    final gstPercent = invoice.igst; // rename this to gstPercent ideally

    if (isInterState) {
      // IGST only
      igst = subtotal * gstPercent / 100;
    } else {
      // CGST + SGST (split equally)
      cgst = subtotal * (gstPercent / 2) / 100;
      sgst = subtotal * (gstPercent / 2) / 100;
    }

    final total = subtotal + cgst + sgst + igst;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section with Logo and Company Info
              _buildHeader(invoice, logo),

              pw.SizedBox(height: 8),

              // Bill To and Invoice Info Row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Bill To Section (Left)
                  pw.Expanded(flex: 5, child: _buildBillToSection(invoice)),

                  pw.SizedBox(width: 15),

                  // Invoice Info Section (Right)
                  pw.Expanded(
                    flex: 4,
                    child: _buildInvoiceInfoSection(invoice),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),

              // Products Table
              pw.Expanded(child: _buildProductsTable(invoice)),
             // pw.Spacer(),
              pw.SizedBox(height: 8),

              // Bank Details and Totals Row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Bank Details (Left)
                  pw.Expanded(flex: 5, child: _buildBankDetails()),

                  pw.SizedBox(width: 15),

                  // Totals (Right)
                  pw.Expanded(
                    flex: 4,
                    child: _buildTotalsSection(
                      subtotal,
                      cgst,
                      sgst,
                      igst,
                      total,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),

              // Terms and Conditions
              _buildTermsAndConditions(),

            //  pw.Spacer(),

              // Signature
              _buildSignature(),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildHeader1(Invoice invoice) {
    return pw.Column(
      children: [
        // Top header with GSTIN and Contact
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'GSTIN : 27D0UP04398H1Z9',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Namo Namh Shree Guru Nemi Suriye',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  child: pw.Text(
                    'Tax Invoice',
                    style: pw.TextStyle(
                      fontSize: 7,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Mo. 9892005301',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '9594070924',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 8),

        // Company Name with Logo - MAHAVEER CHEM
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Logo placeholder (MC)
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue900, width: 2),
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Text(
                  'MC',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
            ),
            pw.SizedBox(width: 15),
            pw.Text(
              'MAHAVEER CHEM',
              style: pw.TextStyle(
                fontSize: 36,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
                letterSpacing: 4,
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 5),

        // Dealing in line
        pw.Container(
          width: double.infinity,
          child: pw.Center(
            child: pw.Text(
              'Dealing in : Chemicals Minerals Pigments all Plastic Raw Materials.',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ),

        pw.SizedBox(height: 5),

        // Address bar
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(color: PdfColors.blue900),
          child: pw.Center(
            child: pw.Text(
              '219/6, Road No.14, Jawahar Nagar, Goregoan (W), Mumbai-400064.',
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildHeader(Invoice invoice, pw.MemoryImage logo) {
    return pw.Column(
      children: [
        // Top header with GSTIN and Contact
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              CompanyConfig.getGSTIN(),
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  CompanyConfig.blessingText,
                  style: const pw.TextStyle(
                    fontSize: 8,
                    // color: PdfColor.fromInt(0xFF163ef6),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  child: pw.Text(
                    'Tax Invoice',
                    style: pw.TextStyle(
                      fontSize: 7,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  CompanyConfig.getFormattedMobile1(),
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  CompanyConfig.getFormattedMobile2(),
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),

        //  pw.SizedBox(height: 8),

        // Company Name with Logo
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Logo placeholder
            pw.Image(logo, width: 60), // PDF icon/logo
            /*pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue900, width: 2),
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Text(
                  CompanyConfig.companyNameShort,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
            ),*/
            // pw.SizedBox(width: 15),
            pw.Text(
              CompanyConfig.companyName,
              style: pw.TextStyle(
                fontSize: 36,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF1414d3),
              ),
            ),

            pw.SizedBox(width: 60)
          ],
        ),

        pw.SizedBox(height: 5),

        // Dealing in line
        pw.Container(
          width: double.infinity,
          child: pw.Center(
            child: pw.Text(
              CompanyConfig.tagline,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),

        pw.SizedBox(height: 5),

        // Address bar
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          decoration: const pw.BoxDecoration(color: PdfColors.blue900),
          child: pw.Center(
            child: pw.Text(
              CompanyConfig.getFullAddress(),
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBillToSection(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Bill To.',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          invoice.customer.name,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          invoice.customer.mobile,
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          invoice.customer.address,
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '${invoice.customer.city}, ${invoice.customer.state} ${invoice.customer.pincode}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        if (invoice.customer.gstNumber.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'GST No.${invoice.customer.gstNumber}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildInvoiceInfoSection(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildInvoiceInfoRow('Invoice No.', invoice.invoiceNo),
        _buildInvoiceInfoRow('Invoice Date', invoice.formattedDate),
        _buildInvoiceInfoRow('Challan No.', invoice.challanNo),
        _buildInvoiceInfoRow(
          'Vehicle No.',
          invoice.vehicleNo.isEmpty ? '' : invoice.vehicleNo,
        ),
        pw.SizedBox(height: 4),
        _buildInvoiceInfoRow(
          'Transport',
          invoice.transport.isEmpty ? '' : invoice.transport,
        ),
        _buildInvoiceInfoRow(
          'LR No.',
          invoice.lrNo.isEmpty ? '' : invoice.lrNo,
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.Container(
            width: 95,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(': $value', style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildProductsTable(Invoice invoice) {

    const int maxRowsPerPage = 20;
    final int itemCount = invoice.items.length;
    final int emptyRowCount =
    itemCount < maxRowsPerPage ? maxRowsPerPage - itemCount : 0;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(40), // Index
        1: const pw.FlexColumnWidth(3), // Particulers
        2: const pw.FixedColumnWidth(70), // HSN Code
        3: const pw.FixedColumnWidth(70), // Nett Weight KGS
        4: const pw.FixedColumnWidth(60), // Rate
        5: const pw.FixedColumnWidth(80), // Amount
      },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white),
          children: [
            _buildTableHeaderCell('Index'),
            _buildTableHeaderCell('Particulers'),
            _buildTableHeaderCell('HSN Code'),
            _buildTableHeaderCell('Nett Weight\nKGS.'),
            _buildTableHeaderCell('Rate'),
            _buildTableHeaderCell('Amount'),
          ],
        ),
        // Data Rows
        ...invoice.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _buildTableDataCell('${index + 1}', align: pw.TextAlign.center),
              _buildTableDataCell(item.product.name, align: pw.TextAlign.left),
              _buildTableDataCell(
                item.product.hsnCode,
                align: pw.TextAlign.center,
              ),
              _buildTableDataCell(
                item.netWeight.toStringAsFixed(1),
                align: pw.TextAlign.right,
              ),
              _buildTableDataCell(
                item.product.salePrice.toStringAsFixed(1),
                align: pw.TextAlign.right,
              ),
              _buildTableDataCell(
                item.total.toStringAsFixed(1),
                align: pw.TextAlign.right,
              ),
            ],
          );
        }).toList(),

        // ✅ EMPTY ROWS TO EXPAND TABLE
        for (int i = 0; i < emptyRowCount; i++)
          pw.TableRow(
            children: List.generate(
              6,
                  (_) => pw.Container(
                height: 22, // controls row height
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(''),
              ),
            ),
          ),
      ],
    );
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableDataCell(String text, {pw.TextAlign? align}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
        textAlign: align ?? pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildBankDetails() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Bank Details',
            style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            CompanyConfig.bankName,
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            CompanyConfig.bankBranch,
            style: pw.TextStyle(fontSize: 10),
          ),
         // pw.SizedBox(height: 3),
          pw.Text(
            CompanyConfig.accountNumber,
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            CompanyConfig.ifscCode,
            style: pw.TextStyle(fontSize: 10, ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalsSection(
    double subtotal,
    double cgst,
    double sgst,
    double igst,
    double total,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      child: pw.Column(
        children: [
          _buildTotalRowWithBorder('Subtotal', subtotal),
          _buildTotalRowWithBorder('CGST (9.0%)', cgst),
          _buildTotalRowWithBorder('SGST (9.0%)', sgst),
          _buildTotalRowWithBorder('IGST (18.0%)', igst),
          _buildTotalRowWithBorder('Total', total, isBold: true),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRowWithBorder(
    String label,
    double amount, {
    bool isBold = false,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isBold ? 11 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            amount.toStringAsFixed(1),
            style: pw.TextStyle(
              fontSize: isBold ? 11 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTermsAndConditions() {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: CompanyConfig.termsAndConditions.map((term) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(
              term,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  static pw.Widget _buildTermLine(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildSignature() {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 180,
        padding: const pw.EdgeInsets.only(top: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              CompanyConfig.getCompanySignature(),
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              CompanyConfig.proprietorName,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
