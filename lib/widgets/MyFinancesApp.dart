import 'package:flutter/material.dart';

import '../pages/HomePage.dart';

class MyFinancesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My finances',
      theme: ThemeData(
      ),
      home: MyHomePage(),
    );
  }
}