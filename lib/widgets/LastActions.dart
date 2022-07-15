// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/material.dart';
import 'package:my_finances/dal/Database.dart';
import 'package:my_finances/model/PersistedPayment.dart';
import 'package:my_finances/widgets/SingleEntry.dart';

import '../model/Filters.dart';

class LastActions extends StatelessWidget {
  LastActions(
      {Key? key,
      required this.paymentMethod,
      required this.refreshFunction,
      required this.groupByCategories,
      required this.filters})
      : super(key: key);

  final String paymentMethod;
  final Function refreshFunction;
  final bool groupByCategories;
  final Filters filters;
  late final List<PersistedPayment> _paymentList;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Database.getDatabase().getEntriesByPayMethod(paymentMethod),
        builder: (builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          _paymentList = snapshot.data as List<PersistedPayment>;

          return _renderLastActionsWidget(context, groupByCategories, filters);
        });
  }

  Widget _renderLastActionsWidget(context, bool groupByCategories, Filters filters) {
    if (_paymentList.length == 0) {
      return Center(
          child: Text(
            'No actions saved',
            style: TextStyle(fontSize: 40, color: Colors.pink),
          ));
    }

    if (filters != Filters.EMPTY_FILTER)
      return _renderFiltered();
    if (groupByCategories)
      return _renderGrouped();
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

    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: groupedEntities.keys.length,
          itemBuilder: (context, index) {
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
                        colors: [Colors.greenAccent, Colors.green])),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: (Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(groupedEntities.keys.elementAt(index).toString()
                            .replaceAll("_", " "),
                            style: TextStyle(fontSize: 25)),
                      ),
                      Flexible(
                        child: Text(groupedEntities.values.elementAt(index).toString(),
                            style: TextStyle(fontSize: 25, color: Colors.pink)
                        ),
                      )
                    ],
                  )),
                ),
              ),
            );
          }),
    );
  }

  Widget _renderList() {
    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: _paymentList.length,
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
    List<PersistedPayment> filtersEntries = Database.getDatabase()
        .getFiltersEntries(filters, paymentMethod);

    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: filtersEntries.length,
          itemBuilder: (context, index) {
            PersistedPayment currentElement = filtersEntries.elementAt(index);
            return GestureDetector(
                onDoubleTap: () async => await _deletePayment(currentElement),
                child: SingleEntry(payment: currentElement));
          }),
    );
  }
}
