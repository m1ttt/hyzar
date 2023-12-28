import 'package:flutter/material.dart';

class UserNotifier extends ChangeNotifier {
  String _userType;
  String _email;
  String _userID;

  UserNotifier(this._userType, this._email, this._userID);

  getUserType() => _userType;
  getEmail() => _email;
  getUserID() => _userID;

  setUserType(String userType) {
    _userType = userType;
    notifyListeners();
  }

  setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  setUserID(String userID) {
    _userID = userID;
    notifyListeners();
  }
}
