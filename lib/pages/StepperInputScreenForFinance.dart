import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_finances/dal/Database.dart';
import 'package:my_finances/model/PaymentMethod.dart';
import 'package:my_finances/model/PaymentType.dart';
import 'package:my_finances/model/PersistedPayment.dart';
import 'package:my_finances/widgets/DropDownWithValues.dart';

class StepperInputScreenForFinance extends StatefulWidget {
  final PaymentMethod paymentMethod;

  StepperInputScreenForFinance(this.paymentMethod);

  @override
  State<StatefulWidget> createState() => _StepperInputScreenForFinanceState();
}

class _StepperInputScreenForFinanceState
    extends State<StepperInputScreenForFinance> {
  var _currentStep = 0;

  List<TextField> textFields = [];
  List<TextEditingController> controllers = [];
  TextEditingController operationNameController = TextEditingController();

  String selectedOperationType = PaymentType.OTHERS.name;
  String amountStr = '';

  @override
  void initState() {
    super.initState();
    final controller = TextEditingController();
    var textField = textFieldWithAmount(controller);

    this.textFields.add(textField);
    this.controllers.add(controller);
  }

  TextField textFieldWithAmount(TextEditingController controller) {
    return TextField(
      decoration: InputDecoration(hintText: "złotych"),
      controller: controller,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (text) {
        if (text.length > 2) {
          var pln = text.substring(0, text.length - 2);
          var gr = text.substring(text.length - 2);

          controller.text = pln + '.' + gr;
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length));
        }
      },
    );
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() async {
    var isFinalStep = _currentStep == stepList().length - 1;

    if (!isFinalStep) {
      _currentStep < stepList().length - 1 ? setState(() => {_currentStep += 1})
          : null;
      return;
    }

    var isActionNotSelected = selectedOperationType == '';
    var noAmountGiven = this.amountStr == '0.0';

    if (isActionNotSelected || noAmountGiven) {
      const snackBar = SnackBar(
        content: Text('Form incomplete'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return;
    }

    var createdPayment = PersistedPayment.createPayment(
        operationNameController.text,
        amountStr,
        selectedOperationType,
        widget.paymentMethod);

    await Database.getDatabase().savePayment(createdPayment);

    Navigator.pop(context, createdPayment);
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  @override
  Widget build(BuildContext context) {
    this.amountStr = _getTextFromControllers();
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
                    child:
                        isFinalStep ? const Text("Finish") : const Text("Next"),
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
          isActive: _currentStep == 0,
          state: _currentStep == 0 ? StepState.complete : StepState.disabled,
        ),
        Step(
          title: Text(
            "Rodzaj",
            style: TextStyle(color: Colors.white),
          ),
          content: Container(
            child: DropDownWithValues(selectedOperationType: selectedOperationType,
                refreshParent: (String selected) {
                  setState(() {
                    selectedOperationType = selected;
                  });
                }),
          ),
          isActive: _currentStep == 1,
          state: _currentStep > 1 ? StepState.complete : StepState.disabled,
        ),
        Step(
          title: Text("Kwota", style: TextStyle(color: Colors.white)),
          content: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: this.textFields.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(child: this.textFields.elementAt(index));
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                    child: Icon(Icons.add, size: 35, color: Colors.white),
                    onTap: () {
                      final controller = TextEditingController();
                      var textField = textFieldWithAmount(controller);

                      setState(() {
                        this.textFields.add(textField);
                        this.controllers.add(controller);
                      });
                    }),
              )
            ],
          ),
          isActive: _currentStep == 2,
          state: _currentStep > 2 ? StepState.complete : StepState.disabled,
        ),
        Step(
          title: Text("Podsumowanie", style: TextStyle(color: Colors.white)),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("NAME: ", style: _labelTextStyle()),
                    Text(_operationName(), style: _contentTextStyle()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("TYPE: ", style: _labelTextStyle()),
                    Text(
                        selectedOperationType.isEmpty
                            ? "NO OPERATION TYPE SELECTED"
                            : selectedOperationType
                                .toLowerCase()
                                .replaceAll("_", " "),
                        style: _contentTextStyle()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("AMOUNT: ", style: _labelTextStyle()),
                    Text(
                        this.amountStr == '0.0'
                            ? "WRONG AMOUNT"
                            : this.amountStr + " PLN",
                        style: _contentTextStyle()),
                  ],
                )
              ],
            ),
          ),
          isActive: _currentStep == 3,
          state: StepState.editing,
        )
      ];

  String _operationName() {
    String text = operationNameController.text.isEmpty
        ? "NO OPERATION NAME"
        : operationNameController.text;

    return text.length > 10 ? text.substring(0, 10) + "..." : text;
  }

  TextStyle _contentTextStyle() => TextStyle(
      fontWeight: FontWeight.bold, fontSize: 20, color: Colors.indigo);

  TextStyle _labelTextStyle() =>
      TextStyle(fontWeight: FontWeight.bold, fontSize: 15);

  String _getTextFromControllers() {
    double amount = 0.0;
    this.controllers.forEach((element) {
      if (element.text.isNotEmpty) {
        amount += double.parse(element.text);
      }
    });
    return amount.toString();
  }
}
