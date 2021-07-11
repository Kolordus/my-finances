import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_finances/dal/PersistedPaymentDAO.dart';
import 'package:my_finances/model/PersistedPayment.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:decimal/decimal.dart';

class InputController extends StatefulWidget {

  InputController({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _InputControllerState createState() => _InputControllerState();
}

class _InputControllerState extends State<InputController> {

  final myController = TextEditingController();

  Decimal _amount = new Decimal.parse('0.00');

  @override
  void initState() {
    var formatter = NumberFormat("####.0#", "en_US");

    if (widget.title == 'gotowka') {
      getAmountPref('gotowka')
      .then((value) => this.setState(() {
        _amount = new Decimal.parse(formatter.format(value));
      }));
    } else {
      getAmountPref('karta')
          .then((value) => this.setState(() {
        _amount = new Decimal.parse(formatter.format(value));
      }));
    }
  super.initState();
    this.setState(() {

    });
  }

  void _calculate() async {

    Widget okButton = ElevatedButton(
        onPressed: () {
          this.setState(() {
            _amount += new Decimal.parse(myController.text);
          });

          final prefs = SharedPreferences.getInstance();

          if (widget.title == 'gotowka') {
            saveAmountPref('gotowka', _amount.toDouble())
                .then((value) => null);
          }
          else {
            saveAmountPref('karta', _amount.toDouble())
            .then((value) => null);
          }
          
          Navigator.pop(context);
        },
        child: Text('Ok'));

    AlertDialog alert = AlertDialog(
      title: Text('Amount:'),
      content: TextField(
        controller: myController,
      ) ,
      actions: [
        okButton
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return alert;
        }
    );
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.title),
        Text(_amount.toDouble().toStringAsFixed(2)),
        ElevatedButton(onPressed: _calculate, child: Icon(Icons.exposure))
      ],
    );
  }
}

Future<bool> saveAmountPref(String name, double amount) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(name, amount.toString());

  return prefs.commit();
}

Future<String> getAmountPref(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? amount = prefs.getString(name);

  return amount.toString();
}