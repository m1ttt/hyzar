import 'dart:io';

import 'package:flutter/material.dart';

class UserNotifier extends ChangeNotifier {
  String _userType;
  String _email;
  String _userID;
  String _nombre;
  File? _image;

  UserNotifier(
      this._userType, this._email, this._userID, this._nombre, this._image);

  getUserType() => _userType;
  getEmail() => _email;
  getUserID() => _userID;
  getNombre() => _nombre;
  getImage() => _image;

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

  setNombre(String nombre) {
    _nombre = nombre;
    notifyListeners();
  }

  setImage(File image) {
    _image = image;
    notifyListeners();
  }
}
