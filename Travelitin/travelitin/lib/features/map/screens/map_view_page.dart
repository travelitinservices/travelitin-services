import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travelitin/core/services/location_service.dart';
import 'package:travelitin/core/services/storage_service.dart';
import 'package:travelitin/core/constants/theme/appTheme.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added import
import 'package:permission_handler/permission_handler.dart'; // For permission handling

class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();
  LatLng? _currentPosition;
  String? _errorMessage;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool isSmallScreen = false;

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
    isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Container(
        decoration: AppTheme.glassmorphismDecoration,
        child: Column(
          children: [
            TextField(
              decoration: AppTheme.inputDecoration,
            ),
            Container(
              decoration: AppTheme.glassmorphismDecoration,
              child: const Text('Map Content'),
            ),
            Text(
              _errorMessage ?? '',
              style: AppTheme.errorTextStyle(isSmallScreen),
            ),
          ],
        ),
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
