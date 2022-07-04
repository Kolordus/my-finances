import 'package:hive/hive.dart';

final String tablePersistedPayments = 'payments';

@HiveType(typeId: 0)
class PersistedPayment {

  @HiveField(0)
  int? id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? time;
  @HiveField(3)
  String? amount;
  @HiveField(4)
  String? paymentType;
  @HiveField(5)
  String? paymentMethod;

  PersistedPayment.dto(PersistedPayment payment) {
    this.name = payment.name;
    this.time = payment.time;
    this.amount = payment.amount;
    this.paymentType = payment.paymentType;
    this.paymentMethod = payment.paymentMethod;
  }

  PersistedPayment(this.id, this.name, this.time, this.amount, this.paymentType, this.paymentMethod);

  static PersistedPayment createPayment(name, time, amount, paymentType, paymentMethod) {
    return new PersistedPayment(null, name, time, amount, paymentType, paymentMethod);
  }

  Map<String, Object?> toJson() => {
    '_id': id,
    'name': name,
    'time': time,
    'amount': amount,
    'paymentType' : paymentType,
    'paymentMethod' : paymentMethod
  };

  static PersistedPayment fromJson(Map<String, Object?> json) => PersistedPayment(
      json['_id'] as int,
      json['name'] as String,
      json['time'] as String,
      json['amount'].toString(),
      json['paymentType'] as String,
      json['paymentMethod'] as String,
  );

  PersistedPayment copy(int? id) {
    return PersistedPayment(id!, name, time, amount, paymentType, paymentMethod);
  }

  @override
  String toString() {
    return 'PersistedPayment{id: $id, name: $name, time: $time, amount: $amount, paymentType: $paymentType, paymentMethod: $paymentMethod}';
  }
}
