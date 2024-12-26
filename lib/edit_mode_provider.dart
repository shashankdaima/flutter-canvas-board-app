import 'package:flutter/material.dart';

class EditModeProvider extends ChangeNotifier {
  EditMode? _currentMode;

  EditMode? get currentMode => _currentMode;

  void setMode(EditMode? mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
    }
  }
  voidClear(){
    _currentMode=null;
  }
}

enum EditMode {
  pencil,
  text,
  image,
  shape,
}
