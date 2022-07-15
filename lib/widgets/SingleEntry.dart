
import 'package:flutter/material.dart';
import 'package:my_finances/model/PersistedPayment.dart';

class SingleEntry extends StatelessWidget {

  final PersistedPayment payment;

  SingleEntry({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            gradient: LinearGradient(
            colors: [
              Colors.greenAccent,
              Colors.green
            ]
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: (Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0,0,0,8),
                child: Text(payment.name,
                    style: TextStyle(fontSize: 18)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(payment.paymentType.replaceAll("_", " ")),
                  Text(payment.time),
                  Text(double.parse(payment.amount).toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink)),
                ],
              )
            ],
          )),
        ),
      ),
    );
  }
}