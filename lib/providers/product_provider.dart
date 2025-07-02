import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Filtered products based on search and category
  List<Product> get filteredProducts {
    List<Product> filtered = _products;

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (product) =>
                product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                product.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                product.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase())),
          )
          .toList();
    }

    return filtered;
  }

  // Get unique categories
  List<String> get categories {
    final categories = _products.map((product) => product.category).toSet().toList();
    categories.sort();
    return ['all', ...categories];
  }

  // Get low stock products
  List<Product> get lowStockProducts {
    return _products.where((product) => product.isLowStock).toList();
  }

  // Get out of stock products
  List<Product> get outOfStockProducts {
    return _products.where((product) => product.isOutOfStock).toList();
  }

  // Load products
  Future<void> loadProducts() async {
    _setLoading(true);
    _error = null;

    try {
      _products = await _apiService.getProducts();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create product
  Future<bool> createProduct(Map<String, dynamic> productData) async {
    _setLoading(true);
    _error = null;

    try {
      final newProduct = await _apiService.createProduct(productData);
      _products.add(newProduct);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update product
  Future<bool> updateProduct(String productId, Map<String, dynamic> productData) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedProduct = await _apiService.updateProduct(productId, productData);
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    _error = null;

    try {
      await _apiService.deleteProduct(productId);
      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get product by ID
  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Create demo product for testing
  Future<bool> createDemoProduct() async {
    try {
      final demoProduct = await _apiService.createDemoProduct();
      _products.insert(0, demoProduct);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
