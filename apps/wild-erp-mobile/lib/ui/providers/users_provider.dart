import 'package:flutter/material.dart';

import '../../data/models/profile.dart';
import '../../data/services/users_service.dart';

class UsersProvider extends ChangeNotifier {
  List<Profile> _users = [];
  Profile? _selectedUser;
  bool _isLoading = false;
  String? _error;
  String? _roleFilter;

  List<Profile> get users => _users;
  Profile? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get roleFilter => _roleFilter;

  List<Profile> get filteredUsers {
    if (_roleFilter == null || _roleFilter!.isEmpty) return _users;
    return _users.where((u) => u.role == _roleFilter).toList();
  }

  Future<void> loadUsers({String? role}) async {
    _isLoading = true;
    _error = null;
    _roleFilter = role;
    notifyListeners();

    try {
      _users = await UsersService.getUsers(role: role);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedUser = await UsersService.getUserById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final user = await UsersService.updateUser(id, data);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) _users[index] = user;
      if (_selectedUser?.id == id) _selectedUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRole(String id, String role) async {
    try {
      await UsersService.updateUserRole(id, role);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(role: role);
      }
      if (_selectedUser?.id == id) {
        _selectedUser = _selectedUser!.copyWith(role: role);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleArtist(String id, bool isArtist) async {
    try {
      await UsersService.toggleArtistStatus(id, isArtist);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isArtist: isArtist);
      }
      if (_selectedUser?.id == id) {
        _selectedUser = _selectedUser!.copyWith(isArtist: isArtist);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleVerification(String id, bool isVerified) async {
    try {
      await UsersService.toggleVerification(id, isVerified);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isVerified: isVerified);
      }
      if (_selectedUser?.id == id) {
        _selectedUser = _selectedUser!.copyWith(isVerified: isVerified);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignTokens(String id, int tokens) async {
    try {
      await UsersService.assignTokens(id, tokens);
      await loadUserDetail(id);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1 && _selectedUser != null) {
        _users[index] = _selectedUser!;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void search(String query) {
    // Search is done via service, triggering reload
    notifyListeners();
  }
}
