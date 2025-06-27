import 'package:flutter/material.dart';

class MainScreenController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if(_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}