import 'package:flutter/material.dart';
import 'package:invoicegenerator/utils/backup_service.dart';
import 'package:invoicegenerator/utils/responsive.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../providers/product_provider.dart';
import '../providers/invoice_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isProcessing = false;

  Future<void> _handleExport() async {
    setState(() => _isProcessing = true);
    final hasPermission = await BackupService.requestStoragePermission();
    if (hasPermission) {
      final path = await BackupService.exportToDownloads();
      if (mounted) {
        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup saved successfully')),
          );
        } else {
          // If path is null, it might be cancelled or failed
          // We don't show error for cancel usually, but BackupService returns null for both
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission required for export')),
        );
      }
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _handleImport() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('This will clear all current data and replace it with the backup. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Import', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isProcessing = true);
      final success = await BackupService.importData();
      if (mounted) {
        if (success) {
          // Refresh all providers
          context.read<CustomerProvider>().loadCustomers();
          context.read<ProductProvider>().loadProducts();
          context.read<InvoiceProvider>().loadInvoices();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data imported successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to import data')),
          );
        }
      }
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _buildSectionTitle('Data Management'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.upload_file, size: 24.i, color: Colors.blue),
                      title: Text('Export Backup', style: TextStyle(fontSize: 16.sp)),
                      subtitle: Text('Export customers, products, and invoices to JSON', style: TextStyle(fontSize: 12.sp)),
                      trailing: Icon(Icons.chevron_right, size: 20.i),
                      onTap: _isProcessing ? null : _handleExport,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.download_for_offline, size: 24.i, color: Colors.green),
                      title: Text('Import Backup', style: TextStyle(fontSize: 16.sp)),
                      subtitle: Text('Restore data from a JSON backup file', style: TextStyle(fontSize: 12.sp)),
                      trailing: Icon(Icons.chevron_right, size: 20.i),
                      onTap: _isProcessing ? null : _handleImport,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              _buildSectionTitle('App Info'),
              Card(
                child: ListTile(
                  title: Text('Version', style: TextStyle(fontSize: 16.sp)),
                  trailing: Text('1.0.0', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
