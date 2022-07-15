import 'package:flutter/material.dart';

class Filters {
  final String operationName;
  final RangeValues selectedRangeAmount;
  final DateTimeRange dateRange;
  final String selectedOperationType;

  Filters(
      {required this.operationName,
      required this.selectedRangeAmount,
      required this.dateRange,
      required this.selectedOperationType});

  static final EMPTY_FILTER = Filters(
      operationName: '',
      selectedRangeAmount: RangeValues(0, 0),
      dateRange: DateTimeRange(start: DateTime(1), end: DateTime(1)),
      selectedOperationType: '');

  @override
  String toString() {
    return 'Filters{operationName: $operationName, selectedRangeAmount: $selectedRangeAmount, dateRange: $dateRange, selectedOperationType: $selectedOperationType}';
  }
}
