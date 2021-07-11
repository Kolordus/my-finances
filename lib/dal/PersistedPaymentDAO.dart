import 'package:my_finances/model/PersistedPayment.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PersistedPaymentDAO {

  static final PersistedPaymentDAO INSTANCE = PersistedPaymentDAO._init();

  static Database? _database;

  PersistedPaymentDAO._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('persisted_payments.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future _createDb(Database db, int version) async {
      await db.execute('''
        CREATE TABLE $tablePersistedPayments (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255),
        time DATE,
        amount REAL,
        paymentType VARCHAR(255)
        )
      ''');
  }

  Future close() async {
    final db = await INSTANCE.database;
    db.close();
  }

  Future<PersistedPayment> create(PersistedPayment payment) async {
    final db = await INSTANCE.database;

    final id = await db.insert(tablePersistedPayments, payment.toJson());

    return payment.copy(id);
  }

  Future<List<PersistedPayment>> readAllPayments() async {
    final db = await INSTANCE.database;

    final orderBy = 'time ASC';
    
    final result = await db.query(tablePersistedPayments, orderBy: orderBy);

    return result.map((json) => PersistedPayment.fromJson(json)).toList();
  }


}