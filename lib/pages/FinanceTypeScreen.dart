// ignore: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  String backgroundImage = '';

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _amount = getTotalAmountForType(widget.title);

    if (widget.title == 'Card') backgroundImage = "assets/images/bank-card.jpg";
    if (widget.title == 'Cash') backgroundImage = "assets/images/notes.jpg";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
                opacity: 1000,
              colorFilter: ColorFilter.mode(Colors.lightBlueAccent, BlendMode.color)
            )

        ),
        child: Padding(
          padding: EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,20,0,0),
                  child: Text(_amount.toDouble().toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 70,
                          color: _amount.toDouble() >= 0
                              ? Colors.amberAccent
                              : Colors.redAccent)),
                ),
              ),
              Flexible(
                  flex: 1,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          shadowColor:
                              MaterialStateProperty.all<Color>(Colors.grey),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                      onPressed: () async {
                        PersistedPayment createdPayment = await Navigator.push(
                            this.context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    new StepperInputScreenForFinance(widget.title)));

                        setState(() {

                        });
                      },
                      child: Icon(Icons.add))),
              // onPressed: _saveNewPayment, child: Icon(Icons.add))),
              Expanded(
                  flex: 4,
                  child: LastActions(paymentMethod: widget.title))
            ],
          ),
        ),
      ),
    );
  }

  refreshAndUpdateAmount(String amountToSubtract) async {
    double previousAmount = 0;

    await PrefController.getAmountPref(widget.title)
        .then((persistedValue) => {previousAmount = double.parse(persistedValue)});

    var amountToSubtractAsDouble = double.parse(amountToSubtract);

    var result = previousAmount - amountToSubtractAsDouble;

    print(previousAmount);
    print(amountToSubtractAsDouble);
    print(result);

    PrefController.saveAmountPref(widget.title, result);
  }

  double getTotalAmountForType(title) {
    var box = Hive.box<PersistedPayment>('payments');
    double totalAmount = 0.0;
    box.values
        .where((e) => e.paymentMethod == title)
        .map((e) => double.parse(e.amount))
        .forEach((number) { totalAmount += number;});

    return totalAmount;
  }
}
