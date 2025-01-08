import 'package:flutter/material.dart';
import 'package:lumiers/services/appwrite.dart';

class UserProvider with ChangeNotifier{
  String _username = '';
  String _email = '';

  String get username => _username;
  String get email => _email;

  void setUsername(String username){
    _username = username;
    notifyListeners();
  }

  void setEmail(String email){
    _email = email;
    notifyListeners();
  }

  Future <void> logout() async {
    await AppwriteServices.signOut();
    notifyListeners();
  }
}