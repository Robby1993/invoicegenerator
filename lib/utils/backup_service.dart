import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:invoicegenerator/database_helper.dart';
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

  static Future<String?> exportData({bool share = true}) async {
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

      if (share) {
        // On Android, we'll try to save to Downloads or just Share it
        await Share.shareXFiles([XFile(file.path)], text: 'Invoice App Backup');
      }
      
      return file.path;
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  static Future<String?> exportToDownloads() async {
    try {
      final path = await exportData(share: false);
      if (path == null) return null;

      final file = File(path);
      final bytes = await file.readAsBytes();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'invoice_backup_$timestamp.json';

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup',
        fileName: fileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      return result;
    } catch (e) {
      print('Save to downloads error: $e');
      return null;
    }
  }

  static Future<bool> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> data = jsonDecode(content);

        return await _robustImport(data);
      }
      return false;
    } catch (e) {
      print('Import error: $e');
      return false;
    }
  }

  static Future<bool> _robustImport(Map<String, dynamic> data) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;

      await db.transaction((txn) async {
        // 0. Clear existing data inside the transaction
        await txn.delete('invoice_items');
        await txn.delete('invoices');
        await txn.delete('products');
        await txn.delete('customers');

        // 1. Import Customers (Mapping IDs)
        Map<int, int> customerIdMap = {};
        if (data['customers'] != null) {
          for (var c in data['customers']) {
            int oldId = c['id'];
            c.remove('id');
            int newId = await txn.insert('customers', c);
            customerIdMap[oldId] = newId;
          }
        }

        // 2. Import Products (Mapping IDs)
        Map<int, int> productIdMap = {};
        if (data['products'] != null) {
          for (var p in data['products']) {
            int oldId = p['id'];
            p.remove('id');
            int newId = await txn.insert('products', p);
            productIdMap[oldId] = newId;
          }
        }

        // 3. Import Invoices & Items
        if (data['invoices'] != null) {
          for (var inv in data['invoices']) {
            List<dynamic> itemsData = inv['items'] ?? [];
            inv.remove('id');
            inv.remove('items');

            inv['customerId'] = customerIdMap[inv['customerId']];
            int newInvoiceId = await txn.insert('invoices', inv);

            for (var item in itemsData) {
              await txn.insert('invoice_items', {
                'invoiceId': newInvoiceId,
                'productId': productIdMap[item['productId']],
                'netWeight': (item['netWeight'] as num?)?.toDouble() ?? 0.0,
                'total': (item['total'] as num?)?.toDouble() ?? 0.0,
              });
            }
          }
        }
      });
      return true;
    } catch (e) {
      print('Robust import error: $e');
      return false;
    }
  }
}
