// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:my_finances/model/PaymentType.dart';
import 'package:my_finances/model/PersistedPayment.dart';

import '../components/PrefController.dart';
import '../widgets/LastActions.dart';
import 'StepperInputScreenForFinance.dart';

class FinanceTypeScreen extends StatefulWidget {
  FinanceTypeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _FinanceTypeScreenState createState() => _FinanceTypeScreenState();
}

class _FinanceTypeScreenState extends State<FinanceTypeScreen> {
  final amountController = TextEditingController();
  final nameController = TextEditingController();

  double _amount = 00.0;
  String _selectedPaymentType = 'OTHERS';

  final _formKey = GlobalKey<FormState>();

  List<String> _categories = PaymentType.values
      .map((e) => e.toString().split(".").last.replaceAll("_", " "))
      .toList();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    PrefController.getAmountPref(widget.title).then(
        (value) => {_amount = double.parse(value == 'null' ? '0' : value)});

    super.initState();
  }

  void _saveNewPayment() async {
    String paymentDate =
        DateFormat('d-M-y HH:mm:ss').format(new DateTime.now());

    Widget okButton = ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Processing Data')));
          }

          this.setState(() {
            _amount += double.parse(amountController.text);
            PrefController.saveAmountPref(widget.title, _amount.toDouble());
          });


          var persistedPayment = PersistedPayment.createPayment(
              nameController.text,
              paymentDate,
              amountController.text,
              _selectedPaymentType,
              _getPaymentMethod());

          // PersistedPaymentDAO.INSTANCE.create(persistedPayment);

          Hive.box('payments').add(persistedPayment);

          Navigator.pop(context);
        },
        child: Text('Ok'));

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Amount:'),
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('$paymentDate')),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^[-.0-9 ]+$'))
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: amountController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'amount',
                        ),
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: nameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Operation name'),
                      ),
                      DropdownButton<String>(
                        value: _selectedPaymentType,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black),
                        isExpanded: true,
                        underline: Container(
                          height: 2,
                          color: Colors.blue,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPaymentType = newValue!;
                          });
                        },
                        items: _categories
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value.toString().split(".").last,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                actions: [okButton],
              );
            },
          );
        });
    // no tutaj powinno się zamknąć i pokazac najnowszą akcję
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(flex: 1, child: Text(widget.title, style: TextStyle(fontSize: 20))),
          Flexible(
            flex: 1,
            child: Text(_amount.toDouble().toStringAsFixed(2),
                style: TextStyle(
                    fontSize: 30,
                    color: _amount.toDouble() >= 0
                        ? Colors.green
                        : Colors.redAccent)),
          ),
          Flexible(
              flex: 1,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        this.context,
                        MaterialPageRoute(
                            builder: (context) => StepperInputScreenForFinance("", DateTime.now())
                        )
                    );

                    setState(() {});
                  }, child: Icon(Icons.add) )),
                  // onPressed: _saveNewPayment, child: Icon(Icons.add))),
          Expanded(
              flex: 4,
              child: LastActions(
                  paymentMethod: widget.title,
                  refresh: refreshAndUpdateAmount)),
        ],
      ),
    );
  }

  _getPaymentMethod() {
    switch (widget.title) {
      case 'Card':
        return 'Card';
      case 'Cash':
        return 'Cash';
      default:
        throw new Exception('Incorect value!');
    }
  }

  refreshAndUpdateAmount(String amountToSubtract) async {
    double previusAmount = 0;

    await PrefController.getAmountPref(widget.title)
        .then((persistedValue) => {previusAmount = double.parse(persistedValue)});

    var amountToSubtractAsDouble = double.parse(amountToSubtract);

    var result = previusAmount - amountToSubtractAsDouble;

    print(previusAmount);
    print(amountToSubtractAsDouble);
    print(result);

    PrefController.saveAmountPref(widget.title, result);
  }
}

Future<String> halo() async {
  await Future.delayed(Duration(seconds: 2));
  return 'przeszlo';
}
