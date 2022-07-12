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

  Future<void> savePayment(String paymentMethod, PersistedPayment createdPayment) async {
    await _paymentsBox!.add(createdPayment);

    double totalAmount = 0.0;

    var listByMethod = await this.getEntriesByPaymentMethod(paymentMethod);

    listByMethod
        .forEach((entry) {
          var entryAmount = double.parse(entry.amount);

          /// this happen because it's already calculated for INCOME in method calling this method
          totalAmount = entry.paymentType == "INCOME" ? 0 : totalAmount += entryAmount;

    });

    var currentAmount = this._cashAndCardAmount!.get(paymentMethod);

    this._cashAndCardAmount!.put(paymentMethod, currentAmount! - totalAmount);
  }

  Future<List<PersistedPayment>> getEntriesByPaymentMethod(String paymentMethod) async {
    return await _paymentsBox!.values
      .where((element) => element.paymentMethod == paymentMethod)
      .toList();
  }

  getSumOfEntries(List<PersistedPayment> list) {
    double totalAmount = 0;
    list.map((e) => double.parse(e.amount))
        .forEach((element) {totalAmount += element;});

    return totalAmount;
  }


  Future<void> deletePayment(String time, String paymentMethod) async {
    _paymentsBox!.keys.forEach((key) async {
      PersistedPayment? persistedPayment = _paymentsBox!.get(key);
      if (isWanted(persistedPayment, time, paymentMethod)) {
        await _paymentsBox!.delete(key);
        await _cashAndCardAmount!.put(paymentMethod, _calculateAmount(paymentMethod, persistedPayment));

        return ;
      }}
    );
  }

  double _calculateAmount(String paymentMethod, PersistedPayment? persistedPayment) {
    double? currentAmount = _cashAndCardAmount!.get(paymentMethod);
    double entryAmount = double.parse(persistedPayment!.amount);

    entryAmount = persistedPayment.paymentType == "INCOME" ? entryAmount *= -1 : entryAmount;

    double newAmount = currentAmount! + entryAmount;
    return newAmount;
  }

  Future<void> addToBank(String amount, String incomeNameAmount, String paymentMethod, bool isSalary) async {
    double? previousAmount = _cashAndCardAmount!.get(paymentMethod);

    double newAmount = previousAmount! + double.parse(amount);

    await _cashAndCardAmount!.put(paymentMethod, newAmount);

    if (isSalary) {
      await Database.getDatabase()
          .clearEntries();

      return;
    }
    else {
      PersistedPayment createPayment = PersistedPayment.createPayment(incomeNameAmount, amount, PaymentType.INCOME.name, paymentMethod);
      savePayment(paymentMethod, createPayment);
    }

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

  bool isWanted(PersistedPayment? persistedPayment, String time, String paymentMethod) => persistedPayment?.time == time && persistedPayment?.paymentMethod == paymentMethod;

  // todo: zrobić opcję wyciągania kabony z bankomatu - dodaje cash odejmuje z card
}