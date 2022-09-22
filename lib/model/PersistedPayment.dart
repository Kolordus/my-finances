import 'package:hive/hive.dart';
import 'package:my_finances/model/PaymentMethod.dart';

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

  static PersistedPayment createPayment(name, amount, paymentType, PaymentMethod paymentMethod) {
    return new PersistedPayment(name, getDate(), amount, paymentType, paymentMethod.name);
  }

  static String getDate() {
    DateTime date = DateTime.now();

    String month = _getProperFormat(date.month);
    String day = _getProperFormat(date.day);
    String hour = _getProperFormat(date.hour);
    String minute = _getProperFormat(date.minute);
    String second = _getProperFormat(date.second);

    return "${date.year}-$month-$day $hour:$minute:$second.${date.microsecond}";
  }

  static String _getProperFormat(int unit) {
    return unit < 10
        ? '0' + unit.toString()
        : unit.toString();
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

  static PersistedPayment fromJson(Map<String, dynamic> json) => PersistedPayment(
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
