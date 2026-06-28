import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import '../../data/models/variant.dart';
import '../../data/services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  String? _categoryFilter;

  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get filteredProducts {
    var list = _products;

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final q = _searchQuery!.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      list = list.where((p) => p.category == _categoryFilter).toList();
    }

    return list;
  }

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.sort();
    return cats;
  }

  Future<void> loadProducts({String? category, bool? isActive}) async {
    _isLoading = true;
    _error = null;
    _categoryFilter = category;
    notifyListeners();

    try {
      _products = await InventoryService.getProducts(
        category: category,
        isActive: isActive,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProduct = await InventoryService.getProductById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    try {
      final product = await InventoryService.createProduct(data);
      _products.insert(0, product);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final product = await InventoryService.updateProduct(id, data);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) _products[index] = product;
      if (_selectedProduct?.id == id) _selectedProduct = product;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await InventoryService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createVariant(Map<String, dynamic> data) async {
    try {
      await InventoryService.createVariant(data);
      await loadProductDetail(data['product_id']);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVariant(String id, Map<String, dynamic> data) async {
    try {
      await InventoryService.updateVariant(id, data);
      if (_selectedProduct != null) {
        await loadProductDetail(_selectedProduct!.id);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVariant(String id, String productId) async {
    try {
      await InventoryService.deleteVariant(id);
      await loadProductDetail(productId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStock(String variantId, int newStock) async {
    try {
      await InventoryService.updateStock(variantId, newStock);
      if (_selectedProduct != null) {
        await loadProductDetail(_selectedProduct!.id);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }
}
