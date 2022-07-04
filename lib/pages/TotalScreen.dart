import 'package:flutter/material.dart';
import '../components/PrefController.dart';

class TotalScreen extends StatefulWidget {
  TotalScreen({Key? key}) : super(key: key);

  final String title = 'Total';

  @override
  _TotalScreenState createState() => _TotalScreenState();

}

class _TotalScreenState extends State<TotalScreen> {
  final amountController = TextEditingController();
  final nameController = TextEditingController();

  String _card = '00.00';
  String _cash = '00.00';
  String _total = '00.00';

  @override
  void initState() {
    PrefController.getAmountPref('Card').then((cardValue) => {
      _card = validateAmount(cardValue),
      _total = (double.parse(_total) + double.parse(validateAmount(cardValue))).toString(),
    });

    PrefController.getAmountPref('Cash').then((cashValue) => {
      _cash = validateAmount(cashValue),
      _total = (double.parse(_total) + double.parse(validateAmount(cashValue))).toStringAsFixed(2),
    });


    super.initState();
  }

  String validateAmount(String amount) {
    return amount == 'null' ? '0.00' : amount;
  }

  TextStyle getTextStyle() {
    return TextStyle(fontSize: 20);
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(flex: 1,child: Text(widget.title, style: TextStyle(fontSize: 20))),
          Flexible(
            flex: 1,
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Karta', style: getTextStyle()),
                  Text(_card, style: TextStyle(fontSize: 20, color: double.parse(_card) >= 0 ? Colors.green : Colors.redAccent)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Gotowka', style: TextStyle(fontSize: 20)),
                  Text(_cash, style: TextStyle(fontSize: 20, color: double.parse(_cash) >= 0 ? Colors.green : Colors.redAccent)),
                ],
              ),
              Container(width: deviceWidth * 0.8, child: Divider(color: Colors.black)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_total, style: TextStyle(fontSize: 20, color: double.parse(_total) >= 0 ? Colors.green : Colors.redAccent)),
                ],
              ),
            ],)
          ),
        ],
      ),
    );
  }
}

