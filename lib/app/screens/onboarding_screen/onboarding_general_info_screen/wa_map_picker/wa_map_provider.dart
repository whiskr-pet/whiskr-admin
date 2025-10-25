import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
  Future<void> updateMarkerPosition(LatLng newPosition, {void Function(MapPickerResult result)? onDone}) async {
    _markerPosition = newPosition;
    notifyListeners();

    if (_showAddress) {
      await fetchAddress(newPosition);
      // if address found successfully → clear any error
      if (_addressDetails != null && _addressDetails?.fullAddress != null) {
        _locationError = null;
        notifyListeners();

        if (_mapController != null) {
          animateToLocation(newPosition);
        }

        // now callback with latest result
        if (onDone != null) {
          onDone(getResult());
        }
      }
    }
  }

  /// Animate camera to a specific location
  void animateToLocation(LatLng location, {double? zoom}) {
    _mapController?.move(location, zoom ?? _initialZoom ?? 13.0);
  }

  /// Request location again (retry)
  Future<void> requestLocationAgain({void Function(MapPickerResult result)? onDone}) async {
    _isLoading = true;
    _locationError = null;
    notifyListeners();
    await _getUserLocation();
    if (_currentPosition != null) {
      animateToLocation(_currentPosition!);
      if (onDone != null) {
        onDone(getResult());
      }
    }
  }

  /// Zoom in
  void zoomIn() {
    if (_mapController == null) return;
    final currentZoom = _mapController!.camera.zoom;
    smoothZoom(currentZoom + 1);
  }

  /// Zoom out
  void zoomOut() {
    if (_mapController == null) return;
    final currentZoom = _mapController!.camera.zoom;
    smoothZoom(currentZoom - 1);
  }

  void smoothZoom(double targetZoom, {int steps = 20, Duration totalDuration = const Duration(milliseconds: 400)}) {
    if (_mapController == null) return;

    final currentZoom = _mapController!.camera.zoom;
    final zoomDiff = targetZoom - currentZoom;
    final stepDuration = totalDuration ~/ steps;
    int step = 0;

    // Cubic ease-in-out curve
    double easeInOut(double t) => t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;

    Timer.periodic(stepDuration, (timer) {
      if (step >= steps) {
        timer.cancel();
        _mapController!.move(_mapController!.camera.center, targetZoom);
        return;
      }

      final t = (step + 1) / steps;
      final easedT = easeInOut(t);
      final newZoom = currentZoom + zoomDiff * easedT;

      _mapController!.move(_mapController!.camera.center, newZoom);
      step++;
    });
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

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    if (address.isEmpty) return null;

    final encodedAddress = Uri.encodeComponent(address);
    final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedAddress.json?access_token=$_mapboxAccessToken&limit=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['features'] != null && data['features'].isNotEmpty) {
        final coords = data['features'][0]['geometry']['coordinates'];
        final lng = coords[0];
        final lat = coords[1];
        return LatLng(lat, lng);
      }
    }

    return null;
  }

  Timer? _debounce;

  Future<void> onSearchTextChanged(String value, {void Function(MapPickerResult result)? onDone}) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      if (value.isNotEmpty) {
        final coords = await getCoordinatesFromAddress(value);
        if (coords != null) {
          _markerPosition = coords;
          notifyListeners();

          // move camera to searched location
          _mapController?.move(coords, _initialZoom ?? 13.0);

          // also update address details
          await fetchAddress(coords);

          if (onDone != null) {
            onDone(getResult());
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _debounce?.cancel();
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
