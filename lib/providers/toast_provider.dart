import 'package:flutter/material.dart';

class ToastProvider extends ChangeNotifier {
  String? _message;
  bool _isVisible = false;

  String? get message => _message;
  bool get isVisible => _isVisible;

  void showToast(String message) {
    _message = message;
    _isVisible = true;
    notifyListeners();
  }

  void hideToast() {
    _isVisible = false;
    notifyListeners();
  }
}
