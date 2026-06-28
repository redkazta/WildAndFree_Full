import 'package:flutter/material.dart';

import '../../data/services/dashboard_service.dart';
import '../../data/cache/cache_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardStats _stats = DashboardStats();
  List<Map<String, dynamic>> _recentActivity = [];
  bool _isLoading = false;
  String? _error;

  DashboardStats get stats => _stats;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await DashboardService.getStats();
      _recentActivity = await DashboardService.getRecentActivity();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    CacheService.invalidateAll();
    await loadStats();
  }
}
