import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../model/PersistedPayment.dart';
import '../widgets/MyFinancesApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHiveDb();

  runApp(MyFinancesApp());
}

Future<void> initHiveDb() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();

  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter<PersistedPayment>(PersistedPaymentAdapter());

  await Hive.openBox<PersistedPayment>('payments');
  await Hive.openBox<double>('amounts');
}


