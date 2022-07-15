

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/PaymentType.dart';

class DropDownWithValues extends StatelessWidget {

  String selectedOperationType;
  Function refreshParent;

  DropDownWithValues({required this.selectedOperationType, required this.refreshParent});

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: selectedOperationType,
        items: PaymentType.values
            .map<DropdownMenuItem<String>>((PaymentType value) {
          return DropdownMenuItem<String>(
            value: value.name,
            child: Text(value.name.toLowerCase().replaceAll("_", " ")),
          );
        }).toList(),
        onChanged: (String? selected) {
          refreshParent(selected!);
        });
  }
}