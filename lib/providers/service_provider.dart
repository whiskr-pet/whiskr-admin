import 'package:flutter/material.dart';
import '../models/service_offering.dart';
import '../services/api_service.dart';

class ServiceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  final List<ServiceOffering> _services = <ServiceOffering>[];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedType = 'all';

  List<ServiceOffering> get services => List.unmodifiable(_services);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;

  Future<void> loadServices() async {
    _setLoading(true);
    try {
      final List<ServiceOffering> result = await _apiService.getServices();
      _services
        ..clear()
        ..addAll(result);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<ServiceOffering?> createService(ServiceOffering newService) async {
    _setLoading(true);
    try {
      final ServiceOffering created = await _apiService.createService(newService);
      _services.insert(0, created);
      _error = null;
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<ServiceOffering?> updateService(String serviceId, ServiceOffering update) async {
    _setLoading(true);
    try {
      final ServiceOffering updated = await _apiService.updateService(serviceId, update);
      final int index = _services.indexWhere((ServiceOffering s) => s.id == serviceId);
      if (index != -1) {
        _services[index] = updated;
        notifyListeners();
      }
      _error = null;
      return updated;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteService(String serviceId) async {
    _setLoading(true);
    try {
      await _apiService.deleteService(serviceId);
      _services.removeWhere((ServiceOffering s) => s.id == serviceId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedType(String type) {
    if (_selectedType == type) return;
    _selectedType = type;
    notifyListeners();
  }

  List<ServiceOffering> get filteredServices {
    Iterable<ServiceOffering> result = _services;

    if (_selectedType != 'all') {
      result = result.where((ServiceOffering s) => s.type == _selectedType);
    }
    if (_searchQuery.isNotEmpty) {
      final String q = _searchQuery.toLowerCase();
      result = result.where(
        (ServiceOffering s) =>
            s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q) || s.tags.any((String tag) => tag.toLowerCase().contains(q)),
      );
    }
    return result.toList(growable: false);
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }
}
