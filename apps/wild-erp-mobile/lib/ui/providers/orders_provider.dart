import 'package:flutter/material.dart';

import '../../data/models/order.dart';
import '../../data/services/orders_service.dart';

class OrdersProvider extends ChangeNotifier {
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  String? _statusFilter;
  String? _searchQuery;

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get statusFilter => _statusFilter;

  List<Order> get filteredOrders {
    if (_searchQuery == null || _searchQuery!.isEmpty) return _orders;
    final q = _searchQuery!.toLowerCase();
    return _orders
        .where((o) =>
            (o.userName?.toLowerCase().contains(q) ?? false) ||
            (o.userEmail?.toLowerCase().contains(q) ?? false) ||
            o.id.toLowerCase().contains(q))
        .toList();
  }

  Future<void> loadOrders({String? status}) async {
    _isLoading = true;
    _error = null;
    _statusFilter = status;
    notifyListeners();

    try {
      _orders = await OrdersService.getOrders(status: status);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrder = await OrdersService.getOrderById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String orderId, String status) async {
    try {
      _selectedOrder = await OrdersService.updateOrderStatus(orderId, status);

      // Update in list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _selectedOrder!;
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
    _searchQuery = query;
    notifyListeners();
  }
}
