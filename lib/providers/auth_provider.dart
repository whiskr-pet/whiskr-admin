import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      _currentUser = null;
      _error = null;
      _setLoading(false);
    }
  }

  // Update user profile
  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}
