// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LastActions extends StatefulWidget {
  LastActions({Key? key, required this.paymentMethod, required this.refresh}) : super(key: key);

  final String paymentMethod;
  final Function refresh;

  @override
  _LastActionsState createState() => _LastActionsState();
}

class _LastActionsState extends State<LastActions> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Hive.openBox('payments'),
        builder: (builder, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : renderLastActionsWidget(snapshot.data, context, widget.refresh);
        });
  }
}

Widget renderLastActionsWidget(_paymentList, context, refresh) {
  var actionsAmount = _paymentList?.length ?? 0;
  var deviceWidth = MediaQuery.of(context).size.width;

  return actionsAmount == 0 ? Center(child: Text('Nothing to show')) :
  Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.blue),
    width: deviceWidth * 0.95,
    child: ListView.builder(
        shrinkWrap: true,
        itemCount: actionsAmount,
        itemBuilder: (context, index) {
          var currentElement = _paymentList!.elementAt(index);
          return GestureDetector(
            onDoubleTap: () => deletePayment(currentElement.id),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Card(
                color: Colors.greenAccent,
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
                          Text(double.parse(currentElement.amount!).toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: 15,
                                  color: double.parse(currentElement.amount!) >= 0
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


deletePayment(int paymentId) async {
  Hive.box('payments').delete(paymentId);
}
