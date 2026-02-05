import 'package:invoicegenerator/models/customer.dart';
import 'package:invoicegenerator/models/invoice.dart';
import 'package:invoicegenerator/models/invoice_item.dart';
import 'package:invoicegenerator/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'invoice_app.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          mobile TEXT,
          address TEXT,
          city TEXT,
          state TEXT,
          pincode TEXT,
          gstNumber TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          hsnCode TEXT,
          salePrice REAL
        )
      ''');

        await db.execute('''
CREATE TABLE invoices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoiceNo TEXT,
  customerId INTEGER,
  challanNo TEXT,
  vehicleNo TEXT,
  date TEXT,
  transport TEXT,
  lrNo TEXT,
  percent REAL,
  gstType INTEGER
)
''');

        await db.execute('''
CREATE TABLE invoice_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoiceId INTEGER,
  productId INTEGER,
  netWeight REAL,
  total REAL
)
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            hsnCode TEXT,
            salePrice REAL
          )
        ''');
        }
      },
    );
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final result = await db.query('customers');
    return result.map((e) => Customer.fromMap(e)).toList();
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // PRODUCT CRUD
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'name');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }


  ///Invoice
  Future<int> insertInvoice(Invoice invoice) async {
    final db = await database;

    return await db.transaction((txn) async {
      final invoiceId = await txn.insert('invoices', invoice.toMap());

      for (final item in invoice.items) {
        await txn.insert(
          'invoice_items',
          item.copyWith(invoiceId: invoiceId).toMap(),
        );
      }

      return invoiceId;
    });
  }


  Future<List<Invoice>> getInvoicesFull() async {
    final db = await database;

    final invoiceRows = await db.query(
      'invoices',
      orderBy: 'id DESC',
    );

    List<Invoice> invoices = [];

    for (final inv in invoiceRows) {
      final invoiceId = inv['id'] as int;

      // 1️⃣ Customer
      final customerRow = await db.query(
        'customers',
        where: 'id = ?',
        whereArgs: [inv['customerId']],
        limit: 1,
      );

      final customer = Customer.fromMap(customerRow.first);

      // 2️⃣ Items + Products
      final itemRows = await db.rawQuery('''
      SELECT ii.*, p.*
      FROM invoice_items ii
      JOIN products p ON ii.productId = p.id
      WHERE ii.invoiceId = ?
    ''', [invoiceId]);

      final items = itemRows.map((row) {
        return InvoiceItem(
          id: row['id'] as int,
          invoiceId: invoiceId,
          product: Product(
            id: row['productId'] as int,
            name: row['name'] as String,
            hsnCode: row['hsnCode'] as String,
            salePrice: (row['salePrice'] as num).toDouble(),
          ),
          netWeight: (row['netWeight'] as num).toDouble(),
          total: (row['total'] as num).toDouble(),
        );
      }).toList();

      invoices.add(
        Invoice(
          id: invoiceId,
          invoiceNo: inv['invoiceNo'] as String,
          customer: customer,
          challanNo: inv['challanNo'] as String,
          vehicleNo: inv['vehicleNo'] as String,
          date: DateTime.parse(inv['date'] as String),
          transport: inv['transport'] as String,
          lrNo: inv['lrNo'] as String,
          percent: (inv['percent'] as num).toDouble(),
          gstType: GstTransactionType.values[inv['gstType'] as int],
          items: items,
        ),
      );
    }

    return invoices;
  }


  Future<int> getLastInvoiceNumber() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT MAX(CAST(invoiceNo AS INTEGER)) as lastNo FROM invoices',
    );

    final lastNo = result.first['lastNo'];
    return lastNo == null ? 0 : lastNo as int;
  }


  Future<List<Invoice>> getInvoices(
      List<Customer> customers,
      List<Product> products,
      ) async {
    final db = await database;

    final invoiceRows = await db.query(
      'invoices',
      orderBy: 'id DESC',
    );

    List<Invoice> invoices = [];

    for (final row in invoiceRows) {
      final itemsRows = await db.query(
        'invoice_items',
        where: 'invoiceId = ?',
        whereArgs: [row['id']],
      );

      final customer =
      customers.firstWhere((c) => c.id == row['customerId']);

      final items = itemsRows.map((i) {
        final product =
        products.firstWhere((p) => p.id == i['productId']);

        return InvoiceItem(
          id: i['id'] as int,
          invoiceId: i['invoiceId'] as int,
          product: product,
          netWeight: i['netWeight'] as double,
          total: i['total'] as double,
        );
      }).toList();

      invoices.add(
        Invoice(
          id: row['id'] as int,
          invoiceNo: row['invoiceNo'] as String,
          customer: customer,
          challanNo: row['challanNo'] as String,
          vehicleNo: row['vehicleNo'] as String,
          date: DateTime.parse(row['date'] as String),
          transport: row['transport'] as String,
          lrNo: row['lrNo'] as String,
          percent: row['percent'] as double,
          gstType: GstTransactionType.values[row['gstType'] as int],
          items: items,
        ),
      );
    }

    return invoices;
  }

  Future<void> deleteInvoice(int invoiceId) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete(
        'invoice_items',
        where: 'invoiceId = ?',
        whereArgs: [invoiceId],
      );

      await txn.delete(
        'invoices',
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
    });
  }


}
