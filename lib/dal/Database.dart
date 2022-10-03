import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_finances/model/PaymentMethod.dart';
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
    }
  }

  static Database getDatabase() {
    return _instance;
  }

  Future<void> savePayment(PersistedPayment payment) async {
    await _paymentsBox!.add(payment);

    double toSave = double.parse(payment.amount);

    var currentAmount = this._cashAndCardAmount!.get(payment.paymentMethod);
    if (payment.paymentType == "INCOME") {
      currentAmount = currentAmount!;
      currentAmount += toSave;
    }
    else {
      currentAmount = currentAmount! - toSave;
    }

    _cashAndCardAmount!.put(payment.paymentMethod, currentAmount);
  }

  Future<List<PersistedPayment>> getEntriesByPayMethod(PaymentMethod paymentMethod) async {
    List<PersistedPayment> list = await _paymentsBox!.values
        .where((element) => _excludePreviousBalances(element))
        .where((element) => element.paymentMethod == paymentMethod.name)
        .toList();
    return list;
  }

  bool _excludePreviousBalances(PersistedPayment element) => element.name != "Balance" && element.paymentType != PaymentType.INCOME.toString();

  getSumOfEntries(List<PersistedPayment> list) {
    double totalAmount = 0;
    list.map((e) => double.parse(e.amount)).forEach((element) {
      totalAmount += element;
    });

    return totalAmount;
  }

  Future<RangeValues> getHighestAndLowestAmount() async {
    if (_paymentsBox!.isEmpty)
      return RangeValues(0, 0);

    var high = _paymentsBox!.values.
        map((e) => double.parse(e.amount))
        .reduce(max);

    var small = _paymentsBox!.values.
    map((e) => double.parse(e.amount))
        .reduce(min);

    return RangeValues(small, high);
  }

  Future<void> deletePayment(PersistedPayment payment) async {
    _paymentsBox!.keys.forEach((key) async {
      PersistedPayment? currElement = _paymentsBox!.get(key);
      if (_isWanted(currElement, payment)) {
        await _paymentsBox!.delete(key);
        await _cashAndCardAmount!.put(
            payment.paymentMethod, _calculateAmount(payment));
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
      PaymentMethod paymentMethod, bool isSalary) async {
    await _calculateAndSaveAmount(paymentMethod, amount);

    if (isSalary) {
      await Database.getDatabase().clearEntries();
    } else {
      _saveInEntryList(incomeNameAmount, amount, paymentMethod);
    }
  }

  _saveInEntryList(String operationName, String amount, PaymentMethod paymentMethod) {
    PersistedPayment createPayment = PersistedPayment.createPayment(
        operationName, amount, PaymentType.INCOME.name, paymentMethod);

    savePayment(createPayment);
  }

  Future<void> _calculateAndSaveAmount(PaymentMethod payMethod, String amount) async {
    double previousAmount = _cashAndCardAmount!.get(payMethod.name) ?? 0.0;
    double newAmount = previousAmount + double.parse(amount);
    await _cashAndCardAmount!.put(payMethod.name, newAmount);
  }

  getSumForMethod(String paymentMethod) {
    double? previousAmount = _cashAndCardAmount!.get(paymentMethod);
    if (previousAmount == null) {
      _cashAndCardAmount!.put(paymentMethod, 0);
      previousAmount = 0;
    }
    return previousAmount.toDouble();
  }

  clearEntries() async {
    return _paymentsBox!.clear();
  }

  Future<void> close() async {
    await Hive.close();
  }

  bool _isWanted(PersistedPayment? current, PersistedPayment candidate) =>
      current?.name == candidate.name &&
      current?.time == candidate.time &&
      current?.paymentMethod == candidate.paymentMethod;

  void clearAll() async {
    await this.clearEntries();
    await this._cashAndCardAmount!.clear();
  }

  Future<PersistedPayment> prepareDataForExport(PaymentMethod paymentMethod) async {
    double sum = this._cashAndCardAmount!.get(paymentMethod.name)?.abs() ?? 0.0;
    var list = await getEntriesByPayMethod(paymentMethod);
    list.forEach((e) { sum += double.parse(e.amount);});

    return PersistedPayment.createPayment('Balance', sum.toString(), PaymentType.INCOME.name, paymentMethod);
  }



// todo: zrobić opcję wyciągania kabony z bankomatu - dodaje cash odejmuje z card
// todo: jesli nie zadziala to jak powinno to wysylac tez balanse
}
