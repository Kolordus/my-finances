import 'package:my_finances/model/PersistedPayment.dart';

import '../dal/Database.dart';

class StorageService {
  Database db = Database.getDatabase();

  Future<void> savePayment(PersistedPayment payment) async {
    await db.savePayment(payment);
  }


}