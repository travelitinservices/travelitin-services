import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thingqbator/core/services/location_service.dart';
import 'package:thingqbator/core/services/storage_service.dart';
import 'package:thingqbator/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added import
import 'package:permission_handler/permission_handler.dart'; // For permission handling

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();
  LatLng? _currentPosition;
  String? _errorMessage;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  static const LatLng _defaultPosition = LatLng(
    20.5937,
    78.9629,
  ); // Center on India
  static const String _lastLatKey = 'last_latitude';
  static const String _lastLngKey = 'last_longitude';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    try {
      // Check location permissions
      final permissionStatus = await Permission.location.request();
      if (permissionStatus != PermissionStatus.granted) {
        setState(() {
          _errorMessage = 'Location permission denied.';
        });
        return;
      }

      // Load last saved position
      final lastLat = await _storageService.getDouble(_lastLatKey);
      final lastLng = await _storageService.getDouble(_lastLngKey);
      if (lastLat != null && lastLng != null) {
        _currentPosition = LatLng(lastLat, lastLng);
      }

      // Get current location
      if (await _locationService.isLocationServiceEnabled()) {
        final position = await _locationService.getCurrentPosition();
        if (position != null) {
          _currentPosition = LatLng(position.latitude, position.longitude);
          await _storageService.saveDouble(_lastLatKey, position.latitude);
          await _storageService.saveDouble(_lastLngKey, position.longitude);
        }
      } else {
        setState(() {
          _errorMessage = 'Location services are disabled.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load location: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  void _onSearchSubmitted(String query) {
    // Placeholder for place search (e.g., using Google Places API)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Searching for: $query')));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.accentColor,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition ?? _defaultPosition,
                      zoom: 10,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers:
                        _currentPosition != null
                            ? {
                              Marker(
                                markerId: const MarkerId('current_location'),
                                position: _currentPosition!,
                                infoWindow: InfoWindow(
                                  title: 'Your Location',
                                  snippet:
                                      'Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}',
                                ),
                              ),
                            }
                            : {},
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      decoration: AppTheme.glassmorphismDecoration,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: AppTheme.inputDecoration(
                          'Search places...',
                        ).copyWith(prefixIcon: const Icon(Icons.search)),
                        keyboardType: TextInputType.text,
                        autofillHints: const [],
                        onSubmitted: _onSearchSubmitted,
                      ),
                    ),
                  ),
                  if (_errorMessage != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: AppTheme.glassmorphismDecoration,
                        child: Text(
                          _errorMessage!,
                          style: AppTheme.errorTextStyle(isSmallScreen),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}

extension StorageServiceExtension on StorageService {
  Future<void> saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }
}
