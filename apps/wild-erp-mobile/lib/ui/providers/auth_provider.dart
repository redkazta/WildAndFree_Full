import 'package:flutter/material.dart';

import '../../data/models/profile.dart';
import '../../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _profile != null;
  bool get isAdmin => _profile?.role == 'admin';

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.signIn(email: email, password: password);
      await loadProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await AuthService.signOut();
      _profile = null;
      notifyListeners();
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    try {
      _profile = await AuthService.getCurrentProfile();
      notifyListeners();
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await AuthService.updateProfile(data);
      await loadProfile();
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
    }
  }

  String _parseError(dynamic e) {
    if (e is Exception) return e.toString().replaceFirst('Exception: ', '');
    return e.toString();
  }
}
