// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/material.dart';
import 'package:my_finances/dal/Database.dart';
import 'package:my_finances/model/PersistedPayment.dart';

class LastActions extends StatefulWidget {
  LastActions({Key? key, required this.paymentMethod, required this.refreshFunction}) : super(key: key);

  final String paymentMethod;
  final Function refreshFunction;

  @override
  _LastActionsState createState() => _LastActionsState();
}

class _LastActionsState extends State<LastActions> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Database.getDatabase().getEntriesByPaymentMethod(widget.paymentMethod),
        builder: (builder, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : _renderLastActionsWidget(snapshot.data, context);
        });
  }

  Widget _renderLastActionsWidget(_paymentList, context) {
    var actionsAmount = _paymentList?.length ?? 0;

    return actionsAmount == 0 ? Center(child: Text('Nothing to show')) :
    Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: actionsAmount,
          itemBuilder: (context, index) {
            PersistedPayment currentElement = _paymentList!.elementAt(index);
            return GestureDetector(
              onDoubleTap: () async => {
                await _deletePayment(currentElement.time),
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Card(
                  color: Colors.green[200],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: (Column(
                      children: [
                        Container(
                          child: Text(currentElement.name.toString(),
                              style: TextStyle(fontSize: 18)),
                          alignment: Alignment.topLeft,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currentElement.paymentType.toString()),
                            Text(currentElement.time.toString()),
                            Text(double.parse(currentElement.amount).toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: double.parse(currentElement.amount) >= 0
                                        ? Colors.green
                                        : Colors.redAccent)),
                          ],
                        )
                      ],
                    )),
                  ),
                ),
              ),
            );
          }),
    );

  }

  Future<void>_deletePayment(String time) async {
    await Database.getDatabase().deletePayment(time, widget.paymentMethod);
    await Future.delayed(Duration(milliseconds: 10));
    await widget.refreshFunction();
  }
}


