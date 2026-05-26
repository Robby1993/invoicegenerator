import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:invoicegenerator/database_helper.dart';
import 'package:invoicegenerator/models/customer.dart';
import 'package:invoicegenerator/models/invoice.dart';
import 'package:invoicegenerator/models/product.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ doesn't use READ/WRITE_EXTERNAL_STORAGE for files
        // It uses MANAGE_EXTERNAL_STORAGE or specific media permissions
        // But for just exporting, we can often just use SAF via file_picker or share
        return true; 
      } else {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    }
    return true;
  }

  static Future<String?> exportData() async {
    try {
      final db = DatabaseHelper.instance;
      final customers = await db.getCustomers();
      final products = await db.getProducts();
      final invoices = await db.getInvoicesFull();

      final Map<String, dynamic> data = {
        'customers': customers.map((e) => e.toMap()).toList(),
        'products': products.map((e) => e.toMap()).toList(),
        'invoices': invoices.map((inv) {
          final map = inv.toMap();
          map['items'] = inv.items.map((item) => {
            'productId': item.product.id,
            'netWeight': item.netWeight,
            'total': item.total,
          }).toList();
          return map;
        }).toList(),
      };

      final jsonString = jsonEncode(data);
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/invoice_backup_$timestamp.json');
      await file.writeAsString(jsonString);

      // On Android, we'll try to save to Downloads or just Share it
      await Share.shareXFiles([XFile(file.path)], text: 'Invoice App Backup');
      
      return file.path;
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  static Future<bool> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> data = jsonDecode(content);

        final db = DatabaseHelper.instance;
        await db.clearAllData();

        // 1. Import Customers (Mapping IDs)
        Map<int, int> customerIdMap = {};
        if (data['customers'] != null) {
          for (var c in data['customers']) {
            int oldId = c['id'];
            c.remove('id');
            int newId = await db.insertCustomer(Customer.fromMap(c));
            customerIdMap[oldId] = newId;
          }
        }

        // 2. Import Products (Mapping IDs)
        Map<int, int> productIdMap = {};
        if (data['products'] != null) {
          for (var p in data['products']) {
            int oldId = p['id'];
            p.remove('id');
            int newId = await db.insertProduct(Product.fromMap(p));
            productIdMap[oldId] = newId;
          }
        }

        // 3. Import Invoices
        if (data['invoices'] != null) {
          for (var inv in data['invoices']) {
            List<dynamic> itemsData = inv['items'];
            inv.remove('id');
            inv.remove('items');
            
            // Update customer ID
            inv['customerId'] = customerIdMap[inv['customerId']];

            // Manual reconstruction to avoid using fromMap which might expect objects
            // We'll insert invoice first then items
            final items = itemsData.map((itemData) {
              // We need to resolve the product first, but we can't easily without fetching from DB
              // or having the product object. 
              // Better approach: adjust DatabaseHelper to allow inserting items with just productId.
              return itemData; // temporarily
            }).toList();

            // To keep it simple, I'll just rely on the existing insertInvoice but I need to prepare the items
            // Actually, I'll just use raw SQL or a simpler insert in DatabaseHelper for this.
            // For now, let's assume we fetch products again or map them.
          }
        }
        
        // Re-implementing import logic more robustly
        await _robustImport(data);

        return true;
      }
      return false;
    } catch (e) {
      print('Import error: $e');
      return false;
    }
  }

  static Future<void> _robustImport(Map<String, dynamic> data) async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      // 1. Customers
      Map<int, int> customerIdMap = {};
      if (data['customers'] != null) {
        for (var c in data['customers']) {
          int oldId = c['id'];
          c.remove('id');
          int newId = await txn.insert('customers', c);
          customerIdMap[oldId] = newId;
        }
      }

      // 2. Products
      Map<int, int> productIdMap = {};
      if (data['products'] != null) {
        for (var p in data['products']) {
          int oldId = p['id'];
          p.remove('id');
          int newId = await txn.insert('products', p);
          productIdMap[oldId] = newId;
        }
      }

      // 3. Invoices & Items
      if (data['invoices'] != null) {
        for (var inv in data['invoices']) {
          List<dynamic> itemsData = inv['items'];
          inv.remove('id');
          inv.remove('items');
          
          inv['customerId'] = customerIdMap[inv['customerId']];
          int newInvoiceId = await txn.insert('invoices', inv);

          for (var item in itemsData) {
            await txn.insert('invoice_items', {
              'invoiceId': newInvoiceId,
              'productId': productIdMap[item['productId']],
              'netWeight': item['netWeight'],
              'total': item['total'],
            });
          }
        }
      }
    });
  }
}
