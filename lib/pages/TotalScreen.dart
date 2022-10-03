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

  List<bool> _isSelected = [false, false];
  bool _isSalary = true;
  var _addToBankAmountController = TextEditingController();
  final _incomeNameController = TextEditingController();
  bool _isLoading = false;

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
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: _addToBankAmountController,
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
                                              buttonIndex < _isSelected.length;
                                              buttonIndex++) {
                                            if (buttonIndex == index) {
                                              _isSelected[buttonIndex] = true;
                                            } else {
                                              _isSelected[buttonIndex] = false;
                                            }
                                          }
                                        });
                                      },
                                      isSelected: _isSelected,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            controller: _incomeNameController),
                                  ],
                                ),
                                title: Text("New Income"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () async {
                                      PaymentMethod whatIsSelected =
                                          this._isSelected.elementAt(0)
                                              ? PaymentMethod.Card
                                              : PaymentMethod.Cash;
                                      await Database.getDatabase()
                                          .addNewIncomeToBank(
                                              _addToBankAmountController.text,
                                              _incomeNameController.text,
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
          _isLoading ? CircularProgressIndicator() : Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _exportData();
                    },
                    child: Text('Export data'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _importData();
                    },
                    child: Text('Import data'),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _clearAll();
                },
                child: Text('Clear All data'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportData() async {
    setState(() {
      _isLoading = true;
    });

    Database database = Database.getDatabase();

    List<PersistedPayment> cashEntries =
        await getDataForExportForMethod(database, PaymentMethod.Cash);
    List<PersistedPayment> cardEntries =
        await getDataForExportForMethod(database, PaymentMethod.Card);

    var isSuccess = await HttpService.sendToServer(cardEntries + cashEntries);
    if (!isSuccess) {
      await showDialogWithText(msg: "Cannot connect!");
    }
    else {
      await showDialogWithText(msg: "Done");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<List<PersistedPayment>> getDataForExportForMethod(
      Database database, PaymentMethod paymentMethod) async {
    List<PersistedPayment> payments =
        await database.getEntriesByPayMethod(paymentMethod);
    var balanceFor = await database.prepareDataForExport(paymentMethod);
    payments.add(balanceFor);

    return payments;
  }

  void _importData() async {
    setState(() {
      _isLoading = true;
    });

    var database = Database.getDatabase();
    await database.clearEntries();

    var imported = await HttpService.retrieveDataFromServerAndClearDB();
    if (imported == null) {
      await showDialogWithText(msg: "Cannot connect");
    }
    else {
      imported.forEach((json) {
        database.savePayment(PersistedPayment.fromJson(json));
      });

      await showDialogWithText(msg: "Done");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _clearAll() async {
    Database.getDatabase().clearAll();
    setState(() {});
  }

  Future<void> showDialogWithText({String msg = ''}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
