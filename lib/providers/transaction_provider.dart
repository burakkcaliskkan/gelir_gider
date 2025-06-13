import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  late Box<Transaction> _box;
  double _monthlyLimit = 0;
  String _userName = '';
  String _avatarUrl = '';

  List<Transaction> get transactions => _transactions;
  double get monthlyLimit => _monthlyLimit;
  String get userName => _userName;
  String get avatarUrl => _avatarUrl;

  Future<void> fetchTransactions() async {
    _box = await Hive.openBox<Transaction>('transactions');
    _transactions = _box.values.toList();
    await _fetchMonthlyLimit();
    await fetchProfile();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _box.add(transaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int index) async {
    await _box.deleteAt(index);
    await fetchTransactions();
  }

  Future<void> _fetchMonthlyLimit() async {
    final box = await Hive.openBox('settings');
    _monthlyLimit = box.get('monthlyLimit', defaultValue: 0.0);
  }

  Future<void> setMonthlyLimit(double limit) async {
    final box = await Hive.openBox('settings');
    await box.put('monthlyLimit', limit);
    _monthlyLimit = limit;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    final box = await Hive.openBox('settings');
    _userName = box.get('userName', defaultValue: 'Kullanıcı');
    _avatarUrl = box.get('avatarUrl', defaultValue: '');
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    final box = await Hive.openBox('settings');
    await box.put('userName', name);
    _userName = name;
    notifyListeners();
  }

  Future<void> setAvatarUrl(String url) async {
    final box = await Hive.openBox('settings');
    await box.put('avatarUrl', url);
    _avatarUrl = url;
    notifyListeners();
  }
}
