import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    final user = await DatabaseHelper.instance.authenticate(email, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(User user) async {
    await DatabaseHelper.instance.updateUser(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> updatePassword(String oldPass, String newPass) async {
    if (_currentUser == null) return false;

    if (_currentUser!.password != oldPass) {
      return false;
    }

    await DatabaseHelper.instance.changePassword(_currentUser!.id, newPass);

    _currentUser = User(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      password: newPass,
      role: _currentUser!.role,
    );

    notifyListeners();

    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    final user = User(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
      role: "student",
    );

    return await DatabaseHelper.instance.registerUser(user);
  }
}
