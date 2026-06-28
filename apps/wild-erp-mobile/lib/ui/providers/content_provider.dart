import 'package:flutter/material.dart';

import '../../data/models/content_item.dart';
import '../../data/services/content_service.dart';

class ContentProvider extends ChangeNotifier {
  List<ContentItem> _items = [];
  ContentItem? _selectedItem;
  bool _isLoading = false;
  String? _error;
  String? _statusFilter;
  String? _typeFilter;

  List<ContentItem> get items => _items;
  ContentItem? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get statusFilter => _statusFilter;

  int get pendingCount => _items.where((i) => i.isPending).length;
  int get approvedCount => _items.where((i) => i.isApproved).length;
  int get rejectedCount => _items.where((i) => i.isRejected).length;

  Future<void> loadContent({
    String? status,
    String? type,
  }) async {
    _isLoading = true;
    _error = null;
    _statusFilter = status;
    _typeFilter = type;
    notifyListeners();

    try {
      _items = await ContentService.getContentItems(
        status: status,
        type: type,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadItemDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedItem = await ContentService.getContentItemById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveContent(String id) async {
    try {
      final item = await ContentService.approveContent(id);

      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) _items[index] = item;
      if (_selectedItem?.id == id) _selectedItem = item;

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectContent(String id, String reason) async {
    try {
      final item = await ContentService.rejectContent(id, reason);

      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) _items[index] = item;
      if (_selectedItem?.id == id) _selectedItem = item;

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteContent(String id) async {
    try {
      await ContentService.deleteContent(id);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
