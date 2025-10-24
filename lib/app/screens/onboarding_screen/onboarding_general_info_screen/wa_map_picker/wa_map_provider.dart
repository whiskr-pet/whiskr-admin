import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js_util.dart' as js_util;

/// Provider class that manages map picker state and logic
class MapPickerProvider extends ChangeNotifier {
  // Dependencies
  String? _mapboxAccessToken;
  LatLng? _initialLocation;
  double? _initialZoom;
  bool _showAddress = true;

  // Map controller
  MapController? _mapController;
  MapController get mapController => _mapController!;

  // State
  LatLng? _markerPosition;
  LatLng get markerPosition => _markerPosition!;

  String? _address;
  String? get address => _address;

  CustomAddressDetails? _addressDetails;
  CustomAddressDetails? get addressDetails => _addressDetails;

  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _locationError;
  String? get locationError => _locationError;

  double get initialZoom => _initialZoom ?? 13.0;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Setup the provider with required configuration
  void setup({required String mapboxAccessToken, required LatLng initialLocation, double initialZoom = 13.0, bool showAddress = true}) {
    if (_isInitialized) {
      debugPrint('MapPickerProvider already initialized');
      return;
    }

    _mapboxAccessToken = mapboxAccessToken;
    _initialLocation = initialLocation;
    _initialZoom = initialZoom;
    _showAddress = showAddress;
    _mapController = MapController();
    _markerPosition = initialLocation;
    _isInitialized = true;

    notifyListeners();
  }

  /// Initialize the provider and get user location
  Future<void> initialize() async {
    if (!_isInitialized) {
      throw Exception('MapPickerProvider must be setup before initialization');
    }
    await _getUserLocation();
  }

  /// Get user's current location from browser geolocation API
  Future<void> _getUserLocation() async {
    final geolocation = html.window.navigator.geolocation;

    try {
      final position = await geolocation.getCurrentPosition(enableHighAccuracy: true, timeout: const Duration(seconds: 10), maximumAge: const Duration(seconds: 0));

      final coords = js_util.getProperty(position, 'coords');
      final lat = js_util.getProperty(coords, 'latitude') as double;
      final lng = js_util.getProperty(coords, 'longitude') as double;

      final userLocation = LatLng(lat, lng);

      _currentPosition = userLocation;
      _markerPosition = userLocation;
      _isLoading = false;
      notifyListeners();

      // Fetch address for user's current location
      if (_showAddress) {
        await fetchAddress(userLocation);
      }
    } catch (error) {
      debugPrint('Error getting location: $error');

      // Fallback to initial location
      _currentPosition = _initialLocation;
      _markerPosition = _initialLocation;
      _locationError = 'Could not get your location. Using default location.';
      _isLoading = false;
      notifyListeners();

      if (_showAddress) {
        await fetchAddress(_initialLocation!);
      }
    }
  }

  /// Update marker position
  Future<void> updateMarkerPosition(LatLng newPosition) async {
    _markerPosition = newPosition;
    notifyListeners();

    if (_showAddress) {
      await fetchAddress(newPosition);
    }
  }

  /// Animate camera to a specific location
  void animateToLocation(LatLng location, {double? zoom}) {
    _mapController?.move(location, zoom ?? _initialZoom ?? 13.0);
  }

  /// Request location again (retry)
  Future<void> requestLocationAgain() async {
    _isLoading = true;
    _locationError = null;
    notifyListeners();
    await _getUserLocation();
  }

  /// Zoom in
  void zoomIn() {
    if (_mapController == null) return;
    final currentZoom = _mapController!.camera.zoom;
    _mapController!.move(_mapController!.camera.center, currentZoom + 1);
  }

  /// Zoom out
  void zoomOut() {
    if (_mapController == null) return;
    final currentZoom = _mapController!.camera.zoom;
    _mapController!.move(_mapController!.camera.center, currentZoom - 1);
  }

  /// Fetch address from coordinates using Mapbox Geocoding API
  Future<void> fetchAddress(LatLng point) async {
    if (_mapboxAccessToken == null) return;

    try {
      final url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/'
          '${point.longitude},${point.latitude}.json?'
          'access_token=$_mapboxAccessToken';

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final features = data['features'] as List?;

        if (features != null && features.isNotEmpty) {
          final feature = features[0];
          final place = feature['place_name'] as String?;
          final context = feature['context'] as List?;

          // Extract address components
          String? streetAddress;
          String? city;
          String? state;
          String? zip;
          String? country;

          // Get street address from the feature itself
          if (feature['place_type'] != null && (feature['place_type'] as List).contains('address')) {
            streetAddress = feature['text'] as String?;
            if (feature['address'] != null) {
              streetAddress = '${feature['address']} $streetAddress';
            }
          }

          // Parse context for other components
          if (context != null) {
            for (var item in context) {
              final id = item['id'] as String?;
              final text = item['text'] as String?;

              if (id != null && text != null) {
                if (id.startsWith('postcode')) {
                  zip = text;
                } else if (id.startsWith('place')) {
                  city = text;
                } else if (id.startsWith('region')) {
                  state = text;
                  // Some regions include short_code
                  if (item['short_code'] != null) {
                    final shortCode = item['short_code'] as String;
                    // Extract state code (e.g., "US-CA" -> "CA")
                    if (shortCode.contains('-')) {
                      state = shortCode.split('-').last;
                    }
                  }
                } else if (id.startsWith('country')) {
                  country = text;
                }
              }
            }
          }

          _address = place;
          _addressDetails = CustomAddressDetails(streetAddress: streetAddress, city: city, state: state, zip: zip, country: country, fullAddress: place);
          notifyListeners();

          debugPrint('Address Details: $_addressDetails');
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
    }
  }

  /// Get the result to be returned
  MapPickerResult getResult() {
    return MapPickerResult(location: _markerPosition!, address: _addressDetails ?? CustomAddressDetails());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

/// Data class for address details
class CustomAddressDetails {
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;
  final String? fullAddress;

  CustomAddressDetails({this.streetAddress, this.city, this.state, this.zip, this.country, this.fullAddress});

  @override
  String toString() {
    return 'AddressDetails(street: $streetAddress, city: $city, state: $state, zip: $zip, country: $country)';
  }

  Map<String, dynamic> toJson() {
    return {'streetAddress': streetAddress, 'city': city, 'state': state, 'zip': zip, 'country': country, 'fullAddress': fullAddress};
  }
}

/// Result model
class MapPickerResult {
  final LatLng location;
  final CustomAddressDetails address;

  MapPickerResult({required this.location, required this.address});

  Map<String, dynamic> toJson() {
    return {'latitude': location.latitude, 'longitude': location.longitude, 'address': address.toJson()};
  }
}
