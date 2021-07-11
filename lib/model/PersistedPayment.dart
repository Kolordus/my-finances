import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

final String tablePersistedPayments = 'persisted_payments';

class PersistedPayment {

  int id;
  String name;
  DateTime time;
  Decimal amount;
  PaymentType paymentType;

  PersistedPayment(this.id, this.name, this.time, this.amount, this.paymentType);

  Map<String, Object?> toJson() => {
    '_id': id,
    'name': name,
    'time': time.toIso8601String(),
    'amount': amount,
    'type' : paymentType.getJson()
  };

  static PersistedPayment fromJson(Map<String, Object?> json) => PersistedPayment(
      json['_id'] as int,
      json['name'] as String,
      DateTime.parse(json['time'] as String),
      json['amount'] as Decimal,
      PaymentType.setFromJson(json['paymentType'] as String)
  );

  PersistedPayment copy(int? id) {
    return PersistedPayment(id!, name, time, amount, paymentType);
  }

}

class PaymentType {

  String type;

  PaymentType._init({required this.type});

  static final PaymentType OTHERS_IMPORTANT = PaymentType._init(type: 'OTHERS_IMPORTANT');
  static final PaymentType FOOD = PaymentType._init(type: 'FOOD');
  static final PaymentType BILLS = PaymentType._init(type: 'BILLS');
  static final PaymentType OTHERS_UNIMPORTANT = PaymentType._init(type: 'OTHERS_UNIMPORTANT');

  String getJson() {
    return '''
    'type': $type
    ''';
  }

  static PaymentType setFromJson(String json) {
    switch (json) {
      case 'OTHERS_IMPORTANT' : return OTHERS_IMPORTANT;
      case 'FOOD' : return FOOD;
      case 'BILLS' : return BILLS;
      case 'OTHERS_UNIMPORTANT' : return OTHERS_UNIMPORTANT;
      default : return OTHERS_UNIMPORTANT;
    }
  }
}