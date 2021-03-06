import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
    }
    else {
      currentAmount = currentAmount! - toSave;
    }

    _cashAndCardAmount!.put(payment.paymentMethod, currentAmount);
  }

  Future<List<PersistedPayment>> getEntriesByPayMethod(String paymentMethod) async {
    List<PersistedPayment> list = _paymentsBox!.values
        .where((element) => element.paymentMethod == paymentMethod)
        .toList();

    list.sort((a, b) => a.getDateAsDateTime().isBefore(b.getDateAsDateTime()) ? 1 : 0);
    return list;
  }

  getSumOfEntries(List<PersistedPayment> list) {
    double totalAmount = 0;
    list.map((e) => double.parse(e.amount)).forEach((element) {
      totalAmount += element;
    });

    return totalAmount;
  }

  Future<RangeValues> getHighestAmount() async {
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

// todo: zrobi?? opcj?? wyci??gania kabony z bankomatu - dodaje cash odejmuje z card
}
