import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  List<String> _conditions = [];
  List<String> get conditions => _conditions;
  set conditions(List<String> value) {
    _conditions = value;
  }

  void addToConditions(String value) {
    conditions.add(value);
  }

  void removeFromConditions(String value) {
    conditions.remove(value);
  }

  void removeAtIndexFromConditions(int index) {
    conditions.removeAt(index);
  }

  void updateConditionsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    conditions[index] = updateFn(_conditions[index]);
  }

  void insertAtIndexInConditions(int index, String value) {
    conditions.insert(index, value);
  }
}
