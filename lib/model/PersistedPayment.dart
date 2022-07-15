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

  static PersistedPayment createPayment(name, amount, paymentType, paymentMethod) {
    return new PersistedPayment(name, getDate(), amount, paymentType, paymentMethod);
  }

  static String getDate() {
    DateTime date = DateTime.now();
    String month = date.month < 10
        ? '0' + date.month.toString()
        : date.month.toString();

    String day = date.day < 10
        ? '0' + date.day.toString()
        : date.day.toString();

    return "${date.year}-$month-$day ${date.hour}:${date.minute}";
  }

  DateTime getDateAsDateTime() {
    return DateTime.parse(this.time);
  }

  double getAmountAsDouble() {
    return double.parse(this.amount);
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
