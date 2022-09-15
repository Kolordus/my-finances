import 'package:flutter/material.dart';

class TilesColors {

  static final List<Color> _defaultColors = [
    Colors.greenAccent,
    Colors.green
  ];

  static final List<Color> _billsColors = [
    Colors.yellowAccent,
    Colors.yellow
  ];

  static final List<Color> _eventsColors = [
    Colors.orangeAccent,
    Colors.orange
  ];

  static final List<Color> _transportColors = [
    Colors.blueAccent,
    Colors.blue
  ];

  static final List<Color> _foodColors = [
    Colors.indigo,
    Colors.blue
  ];

  static final List<Color> _savingsColors = [
    Colors.purpleAccent,
    Colors.purple
  ];

  static final List<Color> _incomeColors = [
    Colors.orangeAccent,
    Colors.orange
  ];

  static List<Color> getColor(String paymentType) {
    switch (paymentType) {
      case "BILLS": return _billsColors;
      case "EVENTS": return _eventsColors;
      case "TRANSPORT": return _transportColors;
      case "FOOD": return _foodColors;
      case "SAVINGS_ACCOUNT": return _savingsColors;
      case "INCOME": return _incomeColors;
      case "OTHERS_IMPORTANT": return _defaultColors;
      default: return _defaultColors;
    }
  }

}