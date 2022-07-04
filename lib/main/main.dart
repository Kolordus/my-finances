import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../widgets/MyFinancesApp.dart';

void main() async {

  runApp(MyFinancesApp());

  await initHiveDb();
}

Future<void> initHiveDb() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();

  print(appDocumentDir.path);
  Hive.init(appDocumentDir.path);

  await Hive.openBox('payments');
}


