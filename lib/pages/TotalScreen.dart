import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool isSalary = true;
  var addToBankAmountController = TextEditingController();
  final incomeNameController = TextEditingController();

  String validateAmount(String amount) {
    return amount == 'null' ? '0.00' : amount;
  }

  TextStyle getTextStyle(Color color, {double fontSize = 40}) {
    return TextStyle(fontSize: fontSize, color: color);
  }

  Future<void> getAmountsForBoth() async {
    var card = await Database.getDatabase().getSavedCashOrCard("Card");
    var cash = await Database.getDatabase().getSavedCashOrCard("Cash");

    this._card = card.toString();
    this._cash = cash.toString();
    this._total = (card + cash).toString();
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
              flex: 1,
              child: Text(widget.title.toUpperCase(),
                  style: getTextStyle(Colors.pink))),
          Flexible(
              flex: 1,
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
          Row(
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
                                        value: isSalary,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isSalary = value!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  isSalary ? Text("") : TextField(controller: incomeNameController),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    String whatIsSelected =
                                        this.isSelected.elementAt(0)
                                            ? "Card"
                                            : "Cash";
                                    await Database.getDatabase().addToBank(
                                        addToBankAmountController.text,
                                        incomeNameController.text,
                                        whatIsSelected,
                                        this.isSalary);

                                    // todo: create reports

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
        ],
      ),
    );
  }
}
