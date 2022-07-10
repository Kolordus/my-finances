import 'package:hive/hive.dart';

part 'PersistedPayment.g.dart';

final String tablePersistedPayments = 'payments';

@HiveType(typeId: 0)
class PersistedPayment {

  @HiveField(0)
  String name;

  @HiveField(1)
  String time;

  @HiveField(2)
  String amount;

  @HiveField(3)
  String paymentType;

  @HiveField(4)
  String paymentMethod;

  PersistedPayment(this.name, this.time, this.amount, this.paymentType, this.paymentMethod);

  static PersistedPayment createPayment(name, time, amount, paymentType, paymentMethod) {
    return new PersistedPayment(name, time, amount, paymentType, paymentMethod);
  }

  Map<String, Object?> toJson() => {
    'name': name,
    'time': time,
    'amount': amount,
    'paymentType' : paymentType,
    'paymentMethod' : paymentMethod
  };

  static PersistedPayment fromJson(Map<String, Object?> json) => PersistedPayment(
      json['name'] as String,
      json['time'] as String,
      json['amount'].toString(),
      json['paymentType'] as String,
      json['paymentMethod'] as String,
  );

  @override
  String toString() {
    return 'PersistedPayment{name: $name, time: $time, amount: $amount, paymentType: $paymentType, paymentMethod: $paymentMethod}';
  }
}
