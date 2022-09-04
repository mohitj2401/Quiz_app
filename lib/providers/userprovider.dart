import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  String _name = '';
  String _email = '';

  String get email => _email;
  String get name => _name;

  updateUser(String name, String email) {
    _name = name;
    _email = email;
    notifyListeners();
  }
}
