// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/material.dart';
import 'package:my_finances/dal/Database.dart';
import 'package:my_finances/model/PaymentMethod.dart';
import 'package:my_finances/model/PersistedPayment.dart';
import 'package:my_finances/widgets/SingleEntry.dart';

import '../model/Filters.dart';
import '../styles/TilesColors.dart';

class PaymentsListWidget extends StatelessWidget {
  PaymentsListWidget(
      {Key? key,
      required this.paymentMethod,
      required this.refreshFunction,
      required this.groupByCategories,
      required this.filters,
      required this.sortedDesc})
      : super(key: key);

  final PaymentMethod paymentMethod;
  final Function refreshFunction;
  final bool groupByCategories;
  final Filters filters;
  final bool sortedDesc;
  late List<PersistedPayment> _paymentList = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder <List<PersistedPayment>>(
        future: Database.getDatabase().getEntriesByPayMethod(paymentMethod),
        builder: (builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            _paymentList = snapshot.data as List<PersistedPayment>;

            _paymentList.sort((a, b) => a.getDateAsDateTime().isBefore(b.getDateAsDateTime()) ? 1 : 0);

            if (sortedDesc) {
              _paymentList.sort((a, b) =>
              a.getDateAsDateTime().isBefore(b.getDateAsDateTime()) ? 0 : 1);
            }

            return _renderLastActionsWidget(groupByCategories, filters);
          }

          return Center(child: CircularProgressIndicator());
        });
  }

  Widget _renderLastActionsWidget(bool groupByCategories, Filters filters) {
    if (_paymentList.length == 0) {
      return Center(
          child: Text(
        'No actions saved',
        style: TextStyle(fontSize: 40, color: Colors.pink),
      ));
    }

    if (filters != Filters.EMPTY_FILTER) return _renderFiltered();
    if (groupByCategories) return _renderGrouped();
    return _renderList();
  }

  Widget _renderGrouped() {
    Map<String, double> groupedEntities = {};

    _paymentList.forEach((element) {
      double amountFromElement = double.parse(element.amount);
      groupedEntities.update(
          element.paymentType, (value) => value + amountFromElement,
          ifAbsent: () => amountFromElement);
    });

    double _totalExpensesAmount = groupedEntities.values.fold(0, (p, c) => p + c);
    
    return Column(
      children: [
        Flexible(child: _totalExpensesWidget(_totalExpensesAmount), flex: 3,),
        Flexible(
          flex: 20,
          child: ListView.builder(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              itemCount: groupedEntities.keys.length,
              itemBuilder: (context, index) {
                var currentElement = groupedEntities.keys
                    .elementAt(index)
                    .toString();

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 0,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        gradient: LinearGradient(
                            colors: TilesColors.getColor(currentElement))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: (Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                                currentElement.replaceAll("_", " "),
                                style: TextStyle(fontSize: 25)),
                          ),
                          Flexible(
                            child: Text(
                                groupedEntities.values.elementAt(index).toStringAsFixed(2),
                                style: TextStyle(fontSize: 25, color: Colors.pink)),
                          )
                        ],
                      )),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _totalExpensesWidget(double _totalExpensesAmount) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Text("TOTAL EXPENSES",
              style: TextStyle(fontSize: 15, color: Colors.deepOrangeAccent)),
          Text(_totalExpensesAmount.toStringAsFixed(2),
              style: TextStyle(fontSize: 20, color: Colors.deepOrangeAccent))
        ],
      ),
    );
  }

  Widget _renderList() {
    // somehow sometimes it tries to render null so how come
    //you say it'll never be null?!
    if (_paymentList == null) {
      return Container();
    }

    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: _paymentList.length,
          padding: const EdgeInsets.all(0),
          itemBuilder: (context, index) {
            PersistedPayment currentElement = _paymentList.elementAt(index);
            return GestureDetector(
                onDoubleTap: () async => await _deletePayment(currentElement),
                child: SingleEntry(payment: currentElement));
          }),
    );
  }

  Future<void> _deletePayment(PersistedPayment payment) async {
    await Database.getDatabase().deletePayment(payment);
    await Future.delayed(Duration(milliseconds: 10));
    await refreshFunction();
  }

  Widget _renderFiltered() {
    List<PersistedPayment> filtersEntries =
        _filterEntries(filters, paymentMethod.name);

    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: filtersEntries.length,
          padding: const EdgeInsets.all(0),
          itemBuilder: (context, index) {
            PersistedPayment currentElement = filtersEntries.elementAt(index);
            return GestureDetector(
                onDoubleTap: () async => await _deletePayment(currentElement),
                child: SingleEntry(payment: currentElement));
          }),
    );
  }

  List<PersistedPayment> _filterEntries(Filters filters, String paymentMethod) {
    List<PersistedPayment> list = _paymentList
        .where((element) => element.paymentMethod == paymentMethod)
        .where((element) =>
            element.getDateAsDateTime().isAfter(filters.dateRange.start) &&
            element.getDateAsDateTime().isBefore(filters.dateRange.end))
        .where((element) => _isInRange(
            element.getAmountAsDouble(), filters.selectedRangeAmount))
        .where((element) => element.name.contains(filters.operationName))
        .where((element) => _filterByOperationType(element.paymentType, filters))
        .toList();

    list.sort((a, b) =>
        a.getDateAsDateTime().isBefore(b.getDateAsDateTime()) ? 1 : 0);

    return list;
  }

  bool _filterByOperationType(String operationType, Filters filters) {
    if (operationType.isNotEmpty)
      return operationType.contains(filters.selectedOperationType);

    return false;
  }

  bool _isInRange(double amount, RangeValues values) {
    return amount >= values.start && amount <= values.end;
  }

}
