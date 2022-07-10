// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_finances/model/PersistedPayment.dart';

class LastActions extends StatefulWidget {
  LastActions({Key? key, required this.paymentMethod}) : super(key: key);

  final String paymentMethod;

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
        future: _getActionsFromDB(widget.paymentMethod),
        builder: (builder, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : renderLastActionsWidget(snapshot.data, context);
        });
  }

  _getActionsFromDB(String paymentMethod) async {
    var paymentsBox = Hive.box<PersistedPayment>('payments');
    List<PersistedPayment> paymentList = [];

    paymentsBox.keys.forEach((element) {
      var persistedPayment = paymentsBox.get(element);

      if (persistedPayment?.paymentMethod == paymentMethod) {
        paymentList.add(persistedPayment!);
      }
    });

    return paymentList;
  }

  Widget renderLastActionsWidget(_paymentList, context) {
    var actionsAmount = _paymentList?.length ?? 0;
    var deviceWidth = MediaQuery.of(context).size.width;

    return actionsAmount == 0 ? Center(child: Text('Nothing to show')) :
    Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: actionsAmount,
          itemBuilder: (context, index) {
            PersistedPayment currentElement = _paymentList!.elementAt(index);
            return GestureDetector(
              onDoubleTap: () => deletePayment(currentElement.time),
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


  deletePayment(String time) async {
    var box = Hive.box<PersistedPayment>('payments');

    box.keys.forEach((key) {
      var persistedPayment = box.get(key);
      if (isWanted(persistedPayment, time)) {
          box.delete(key);
          setState(() {});
          return ;
        }
      }
    );
  }

  bool isWanted(PersistedPayment? persistedPayment, String time) => persistedPayment?.time == time && persistedPayment?.paymentMethod == widget.paymentMethod;

}


