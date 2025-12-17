// account_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountViewModel extends ChangeNotifier {
  bool _loggedIn = false;
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _phone = '';

  bool get loggedIn => _loggedIn;
  String get email => _email;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get phone => _phone;

  AccountViewModel() {
    loadAuthInfo();
  }

  Future<void> loadAuthInfo() async {
    final authInfo = await _getAuthInfo();
    _loggedIn = authInfo['loggedIn'] == true;
    _email = authInfo['email'] ?? '';
    _firstName = authInfo['firstName'] ?? '';
    _lastName = authInfo['lastName'] ?? '';
    _phone = authInfo['phone'] ?? '';
    notifyListeners();
  }

  Future<Map<String, dynamic>> _getAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final email = prefs.getString('userEmail') ?? '';
    final firstName = prefs.getString('userFirstName') ?? '';
    final lastName = prefs.getString('userLastName') ?? '';
    final phone = prefs.getString('userPhone') ?? '';

    return {
      'loggedIn': token != null && token.isNotEmpty,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userEmail');
    await prefs.remove('userFirstName');
    await prefs.remove('userLastName');
    await prefs.remove('userPhone');

    await loadAuthInfo(); // Reload auth info to update UI
  }

  Future<String?> getCartId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cartId');
  }
}
