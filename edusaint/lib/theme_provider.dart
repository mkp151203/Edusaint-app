import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Private variable
  Color _appColor = const Color.fromARGB(255, 108, 142, 199); // Default color

  // Public getter
  Color get appColor => _appColor;

  get primaryColor => null;

  // Public setter
  set appColor(Color color) {
    _appColor = color;
    notifyListeners();
  }
}
