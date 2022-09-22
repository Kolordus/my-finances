
import 'package:flutter/material.dart';
import 'package:my_finances/model/PersistedPayment.dart';
import 'package:my_finances/styles/TilesColors.dart';

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
      child: Opacity(
        opacity: .90,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              gradient: LinearGradient(
              colors: TilesColors.getColor(payment.paymentType)
            )
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: (Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,0,8),
                  child: Text(payment.name,
                      style: TextStyle(fontSize: 18)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4,0,4,0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(payment.paymentType.replaceAll("_", " ")),
                      new Spacer(),
                      Text(_shortenTime()),
                      new Spacer(),
                      Text(double.parse(payment.amount).toStringAsFixed(2),
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.red)),
                    ],
                  ),
                )
              ],
            )),
          ),
        ),
      ),
    );
  }

  String _shortenTime() => payment.time.substring(0, payment.time.lastIndexOf('.'));
}