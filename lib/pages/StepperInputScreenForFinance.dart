import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class StepperInputScreenForFinance extends StatefulWidget {
  final String personName;
  final DateTime now;

  StepperInputScreenForFinance(this.personName, this.now);

  @override
  State<StatefulWidget> createState() => _StepperInputScreenForFinanceState();
}

class _StepperInputScreenForFinanceState
    extends State<StepperInputScreenForFinance> {
  var _currentStep = 0;
  TextEditingController operationNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    var isFinalStep = _currentStep == stepList().length - 1;
    var isNotComplete = amountController.text.isEmpty || operationNameController.text.isEmpty;
    if (isFinalStep) {
      if (isNotComplete) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Form Incomplete!", textAlign: TextAlign.center,)));
        return null;
      }
      String amount = amountController.text.replaceAll(".", "");

      // zbiórka do jednego obiektu
      // oraz zapis w bazie

      Navigator.pop(context);
    }
    _currentStep < 2 ? setState(() => {_currentStep += 1}) : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Stepper(
        physics: ScrollPhysics(),
        currentStep: _currentStep,
        onStepTapped: (step) => tapped(step),
        onStepContinue: continued,
        onStepCancel: cancel,
        steps: stepList(),
        controlsBuilder: (context, controlsDetails) {
          bool isFinalStep = _currentStep == stepList().length - 1;

          return Container(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                    ),
                    onPressed: continued,
                    child: isFinalStep ? const Text("Finish") : const Text("Next"),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (_currentStep > 0)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      onPressed: cancel,
                      child: const Text('Back'),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  List<Step> stepList() => [
        Step(
          title: Text(
            "Nazwa Operacji",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            children: [
              TextField(
                  decoration: InputDecoration(hintText: "Nazwa operacji"),
                  controller: operationNameController),
            ],
          ),
          isActive: _currentStep >= 0,
          state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
        ),
        Step(
          title: Text("Kwota", style: TextStyle(color: Colors.white)),
          content: Column(
            children: [
              TextField(
                decoration: InputDecoration(hintText: "złotych"),
                controller: amountController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (text) {
                  if (text.length > 2) {
                    var pln = text.substring(0, text.length - 2);
                    var gr = text.substring(text.length - 2);

                    amountController.text = pln + '.' + gr;
                    amountController.selection = TextSelection.fromPosition(
                        TextPosition(offset: amountController.text.length));
                  }
                },
              ),
            ],
          ),
          isActive: _currentStep >= 1,
          state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
        ),
        Step(
          title: Text("Podsumowanie", style: TextStyle(color: Colors.white)),
          content: Column(
            children: [
              Text(widget.now.toLocal().toString().substring(0, 16)),
              Text(operationNameController.text),
              amountController.text.isNotEmpty
                  ? Text(
                      (double.parse(amountController.text)).toString() + " PLN")
                  : Text("Form is incomplete!!", style: TextStyle(color: Colors.red, fontSize: 20),)
            ],
          ),
          isActive: _currentStep >= 2,
          state: StepState.complete,
        )
      ];
}
