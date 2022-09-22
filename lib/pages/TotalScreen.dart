import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_finances/model/PaymentMethod.dart';
import 'package:my_finances/model/PersistedPayment.dart';
import 'package:my_finances/services/HttpService.dart';

import '../dal/Database.dart';

class TotalScreen extends StatefulWidget {
  TotalScreen({Key? key}) : super(key: key);

  final String title = 'Total';

  @override
  _TotalScreenState createState() => _TotalScreenState();
}

class _TotalScreenState extends State<TotalScreen> {
  String _card = '00.00';
  String _cash = '00.00';
  String _total = '00.00';

  List<bool> isSelected = [false, false];
  bool _isSalary = true;
  var addToBankAmountController = TextEditingController();
  final incomeNameController = TextEditingController();

  String validateAmount(String amount) {
    return amount == 'null' ? '0.00' : amount;
  }

  TextStyle getTextStyle(Color color, {double fontSize = 40}) {
    return TextStyle(fontSize: fontSize, color: color);
  }

  Future<void> getAmountsForBoth() async {
    double card = await Database.getDatabase().getSumForMethod("Card");
    double cash = await Database.getDatabase().getSumForMethod("Cash");

    _card = card.toStringAsFixed(2);
    _cash = cash.toStringAsFixed(2);
    this._total = (card + cash).toDouble().toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: getAmountsForBoth(),
      builder: (builder, snapshot) {
        return snapshot.connectionState == ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : _renderPage(deviceWidth);
      },
    );
  }

  Padding _renderPage(double deviceWidth) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
              flex: 2,
              child: Text(widget.title.toUpperCase(),
                  style: getTextStyle(Colors.pink))),
          Flexible(
            flex: 4,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Karta', style: getTextStyle(Colors.black)),
                      Text(_card, style: getTextStyle(Colors.amberAccent)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gotowka', style: getTextStyle(Colors.black)),
                      Text(_cash, style: getTextStyle(Colors.amberAccent)),
                    ],
                  ),
                  Container(
                      width: deviceWidth * 0.8,
                      child: Divider(color: Colors.black)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_total,
                          style:
                              getTextStyle(Colors.yellowAccent, fontSize: 70)),
                    ],
                  ),
                ],
              )),
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                backgroundColor: Colors.lightBlue,
                                title: Text("New Income"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: addToBankAmountController,
                                        style: TextStyle(color: Colors.white),
                                        inputFormatters: [
                                          FilteringTextInputFormatter(
                                              RegExp(r'^\d*\.?\d*'),
                                              allow: true)
                                        ],
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.add),
                                            iconColor: Colors.white,
                                            prefixIconColor: Colors.red),
                                      ),
                                    ),
                                    ToggleButtons(
                                      disabledBorderColor: Colors.blue,
                                      fillColor: Colors.white,
                                      children: <Widget>[
                                        Icon(Icons.credit_card),
                                        Icon(Icons.money),
                                      ],
                                      onPressed: (int index) {
                                        setState(() {
                                          for (int buttonIndex = 0;
                                              buttonIndex < isSelected.length;
                                              buttonIndex++) {
                                            if (buttonIndex == index) {
                                              isSelected[buttonIndex] = true;
                                            } else {
                                              isSelected[buttonIndex] = false;
                                            }
                                          }
                                        });
                                      },
                                      isSelected: isSelected,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Salary'),
                                        Checkbox(
                                          activeColor: Colors.white,
                                          checkColor: Colors.blue,
                                          value: _isSalary,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _isSalary = value!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    _isSalary
                                        ? Text("")
                                        : TextField(
                                            controller: incomeNameController),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () async {
                                      PaymentMethod whatIsSelected = this.isSelected.elementAt(0) ? PaymentMethod.Card : PaymentMethod.Cash;
                                      await Database.getDatabase()
                                          .addNewIncomeToBank(
                                              addToBankAmountController.text,
                                              incomeNameController.text,
                                              whatIsSelected,
                                              this._isSalary);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Ok",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                      setState(() {});
                    },
                    child: Text('new income',
                        style: getTextStyle(Colors.white, fontSize: 20))),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(onPressed: () {
                    _exportData();
                  },
                  child: Text('Export data'),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(onPressed: () {
                    _importData();
                  },
                    child: Text('Import data'),),
                ),

              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: () {
                _clearAll();
              },
                child: Text('Clear All data'),),
            ),
          ),
        ],
      ),
    );
  }

  void _exportData() async {
    Database database = Database.getDatabase();

    List<PersistedPayment> cashEntries = await getDataForExportForMethod(database, PaymentMethod.Cash);
    List<PersistedPayment> cardEntries = await getDataForExportForMethod(database, PaymentMethod.Card);

    await HttpService.sendToServer(cardEntries + cashEntries);
  }

  Future<List<PersistedPayment>> getDataForExportForMethod(Database database, PaymentMethod paymentMethod) async {
    List<PersistedPayment> payments = await database.getEntriesByPayMethod(paymentMethod);
    var balanceFor = await database.prepareDataForExport(paymentMethod);
    payments.add(balanceFor);

    return payments;
  }

  void _importData() async {
    var database = Database.getDatabase();
    await database.clearEntries();

    var imported = await HttpService.retrieveDataFrmServerAndClearDB();
    imported.forEach((json) {
      database.savePayment(PersistedPayment.fromJson(json));
    });

    setState(() {});
  }

  void _clearAll() async {
    Database.getDatabase().clearAll();
    setState(() {});
  }

}
