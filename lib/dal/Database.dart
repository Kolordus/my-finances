import 'dart:async';

import 'package:hive/hive.dart';
import 'package:my_finances/model/PaymentType.dart';

import '../model/PersistedPayment.dart';

class Database {
  static Database _instance = Database();

  Box<PersistedPayment>? _paymentsBox;
  Box<double>? _cashAndCardAmount;

  Database() {
    if (_paymentsBox == null) {
      _paymentsBox = Hive.box<PersistedPayment>('payments');
    }
    if (_cashAndCardAmount == null) {
      _cashAndCardAmount = Hive.box<double>('amounts');
      _cashAndCardAmount!.put("Card", 1000.0);
      _cashAndCardAmount!.put("Cash", 100.0);
    }
  }

  static Database getDatabase() {
    if (_instance == null) {
      _instance = Database();
    }

    return _instance;
  }

  Future<void> savePayment(PersistedPayment payment) async {
    await _paymentsBox!.add(payment);

    double totalAmount = 0.0;

    var filteredList =
        await this.getEntriesByPaymentMethod(payment.paymentMethod);
    filteredList.forEach((entry) {
      var entryAmount = double.parse(entry.amount);

      totalAmount += entry.paymentType == "INCOME" ? 0 : entryAmount;

    });

    var currentAmount = this._cashAndCardAmount!.get(payment.paymentMethod);

    _cashAndCardAmount!
        .put(payment.paymentMethod, currentAmount! - totalAmount);
  }

  Future<List<PersistedPayment>> getEntriesByPaymentMethod(
      String paymentMethod) async {
    return await _paymentsBox!.values
        .where((element) => element.paymentMethod == paymentMethod)
        .toList();
  }

  getSumOfEntries(List<PersistedPayment> list) {
    double totalAmount = 0;
    list.map((e) => double.parse(e.amount)).forEach((element) {
      totalAmount += element;
    });

    return totalAmount;
  }

  Future<void> deletePayment(String time, String paymentMethod) async {
    _paymentsBox!.keys.forEach((key) async {
      PersistedPayment? persistedPayment = _paymentsBox!.get(key);
      if (isWanted(persistedPayment, time, paymentMethod)) {
        await _paymentsBox!.delete(key);
        await _cashAndCardAmount!.put(
            paymentMethod, _calculateAmount(persistedPayment));
      }
    });
  }

  double _calculateAmount(PersistedPayment? persistedPayment) {
    double? currentAmount = _cashAndCardAmount!.get(persistedPayment!.paymentMethod);
    double entryAmount = double.parse(persistedPayment.amount);

    entryAmount = persistedPayment.paymentType == "INCOME"
        ? entryAmount *= -1
        : entryAmount;

    double newAmount = currentAmount! + entryAmount;
    return newAmount;
  }

  Future<void> addNewIncomeToBank(String amount, String incomeNameAmount,
      String paymentMethod, bool isSalary) async {
    await _calculateAndSaveAmount(paymentMethod, amount);

    if (isSalary) {
      await Database.getDatabase().clearEntries();
    } else {
      _saveInEntryList(incomeNameAmount, amount, paymentMethod);
    }
  }

  _saveInEntryList(String operationName, String amount, String paymentMethod) {
    PersistedPayment createPayment = PersistedPayment.createPayment(
        operationName, amount, PaymentType.INCOME.name, paymentMethod);

    savePayment(createPayment);
  }

  Future<void> _calculateAndSaveAmount(String payMethod, String amount) async {
    double? previousAmount = _cashAndCardAmount!.get(payMethod);
    double newAmount = previousAmount! + double.parse(amount);
    await _cashAndCardAmount!.put(payMethod, newAmount);
  }

  getSavedCashOrCard(String paymentMethod) {
    double? previousAmount = _cashAndCardAmount!.get(paymentMethod);
    return previousAmount!;
  }

  clearEntries() async {
    return _paymentsBox!.clear();
  }

  Future<void> close() async {
    await Hive.close();
  }

  bool isWanted(PersistedPayment? payment, String time, String payMethod) =>
      payment?.time == time &&
      payment?.paymentMethod == payMethod;

// todo: zrobić opcję wyciągania kabony z bankomatu - dodaje cash odejmuje z card
}
