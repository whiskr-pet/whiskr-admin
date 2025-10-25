import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/wa_map_picker/wa_map_provider.dart';

class SmoothDraggableMapPicker extends StatefulWidget {
  const SmoothDraggableMapPicker({
    super.key,
    required this.mapboxAccessToken,
    this.initialLocation = const LatLng(41.89660066501317, 12.479782718685195),
    this.zoom = 13.0,
    this.showAddress = true,
    this.onConfirm,
    this.showMyLocationButton = false,
  });

  final String mapboxAccessToken;
  final LatLng initialLocation;
  final double zoom;
  final bool showAddress;
  final bool showMyLocationButton;
  final void Function(MapPickerResult result)? onConfirm;

  @override
  State<SmoothDraggableMapPicker> createState() => _SmoothDraggableMapPickerState();
}

class _SmoothDraggableMapPickerState extends State<SmoothDraggableMapPicker> {
  late MapPickerProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = MapPickerProvider();
    _provider.setup(mapboxAccessToken: widget.mapboxAccessToken, initialLocation: widget.initialLocation, initialZoom: widget.zoom, showAddress: widget.showAddress);

    _getInitialData();
  }

  Future<void> _getInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _provider.initialize();
      widget.onConfirm?.call(_provider.getResult());
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<MapPickerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ColorHelper.orange500.color),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            );
          }
          return Stack(
            children: [
              _MapView(mapboxAccessToken: widget.mapboxAccessToken, onConfirm: widget.onConfirm),
              Positioned(top: 10, left: 10, right: 10, child: _MapSearchBar(widget.onConfirm)),
              if (provider.locationError != null) _ErrorBanner(widget.onConfirm),
              _MapControls(showMyLocationButton: widget.showMyLocationButton),
              _ConfirmButton(onConfirm: widget.onConfirm),
            ],
          );
        },
      ),
    );
  }
}

/// Map view widget
class _MapView extends StatelessWidget {
  const _MapView({required this.mapboxAccessToken, required this.onConfirm});

  final String mapboxAccessToken;
  final void Function(MapPickerResult result)? onConfirm;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapPickerProvider>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorHelper.grey300.color, width: 1),
          boxShadow: [BoxShadow(color: ColorHelper.darkThemeBackground.color.withAlpha(100), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: FlutterMap(
          mapController: provider.mapController,
          options: MapOptions(
            initialCenter: provider.markerPosition,
            initialZoom: provider.initialZoom,
            onTap: (tapPosition, latLng) async {
              await provider.updateMarkerPosition(latLng, onDone: onConfirm);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/512/{z}/{x}/{y}@2x?access_token={access_token}',
              additionalOptions: {'access_token': mapboxAccessToken},
              userAgentPackageName: 'com.whiskr.admin',
            ),
            DragMarkers(
              markers: [
                DragMarker(
                  key: GlobalKey<DragMarkerWidgetState>(),
                  point: provider.markerPosition,
                  size: const Size(60, 60),
                  builder: (ctx, point, isDragging) => Icon(Icons.location_pin, size: 48, color: ColorHelper.red500.color),
                  onDragEnd: (details, point) async {
                    await provider.updateMarkerPosition(point, onDone: onConfirm);
                  },
                  scrollMapNearEdge: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Error banner widget
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.onConfirm);

  final void Function(MapPickerResult result)? onConfirm;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapPickerProvider>();

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Card(
        color: Colors.orange.shade100,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning, color: ColorHelper.orange500.color),
              const SizedBox(width: 8),
              Expanded(child: Text(provider.locationError ?? '')),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await provider.requestLocationAgain(onDone: onConfirm);
                },
                tooltip: 'Try again',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Map controls (zoom, location) widget
class _MapControls extends StatelessWidget {
  const _MapControls({this.showMyLocationButton = false});

  final bool showMyLocationButton;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapPickerProvider>();
    final hasError = provider.locationError != null;

    return Positioned(
      top: hasError ? 80 : 10,
      right: 10,
      child: Column(
        children: [
          // My location button
          if (provider.currentPosition != null && showMyLocationButton)
            FloatingActionButton(
              mini: true,
              backgroundColor: ColorHelper.white.color,
              heroTag: 'my_location',
              onPressed: () {
                provider.animateToLocation(provider.currentPosition!);
                provider.updateMarkerPosition(provider.currentPosition!);
              },
              tooltip: 'My Location',
              child: const Icon(Icons.my_location),
            )
          else
            const SizedBox(height: 50),
          const SizedBox(height: 8),
          // Zoom in button
          FloatingActionButton(
            mini: true,
            backgroundColor: ColorHelper.orange500.color,
            foregroundColor: ColorHelper.white.color,
            heroTag: 'zoom_in',
            onPressed: provider.zoomIn,
            tooltip: 'Zoom In',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          // Zoom out button
          FloatingActionButton(
            backgroundColor: ColorHelper.orange500.color,
            foregroundColor: ColorHelper.white.color,
            mini: true,
            heroTag: 'zoom_out',
            onPressed: provider.zoomOut,
            tooltip: 'Zoom Out',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

/// Confirm button widget
class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({this.onConfirm});

  final void Function(MapPickerResult result)? onConfirm;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapPickerProvider>();
    final hasError = provider.locationError != null;

    return Positioned(
      top: hasError ? 230 : 190,
      right: 10,
      child: FloatingActionButton(
        heroTag: 'confirm',
        mini: true,
        backgroundColor: ColorHelper.greenWeb.color,
        onPressed: () {
          onConfirm?.call(provider.getResult());
        },
        tooltip: 'Confirm Location',
        hoverColor: ColorHelper.greenWeb.color.withAlpha(100),
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}

class _MapSearchBar extends StatelessWidget {
  const _MapSearchBar(this.onConfirm);

  final void Function(MapPickerResult result)? onConfirm;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MapPickerProvider>();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: TextField(
        decoration: const InputDecoration(hintText: 'Search address...', prefixIcon: Icon(Icons.search), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        onChanged: (String address) async {
          await provider.onSearchTextChanged(address, onDone: onConfirm);
        },
      ),
    );
  }
}
