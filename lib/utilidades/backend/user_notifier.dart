import 'package:flutter/material.dart';

class UserNotifier extends ChangeNotifier {
  String _userType;
  String _email;

  UserNotifier(this._userType, this._email);

  getUserType() => _userType;
  getEmail() => _email;

  setUserType(String userType) {
    _userType = userType;
    notifyListeners();
  }

  setEmail(String email) {
    _email = email;
    notifyListeners();
  }
}
