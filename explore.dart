import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:thingqbator/home_page.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'TripPlanner.dart';

void main() {
  runApp(const ExplorePage());
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Explorer',
      theme: ThemeData().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1E88E5),
          secondary: Color(0xFF64B5F6),
        ),
      ),
      home: const MapExplorerScreen(),
    );
  }
}

class MapExplorerScreen extends StatefulWidget {
  const MapExplorerScreen({super.key});

  @override
  State<MapExplorerScreen> createState() => _MapExplorerScreenState();
}

class _MapExplorerScreenState extends State<MapExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
   double _currentZoom = 10.0; // Initialize with your starting zoom level
   LatLng _currentCenter = LatLng(51.5, -0.09); // Initial center position
  final Random _random = Random();

  static const String _apiKey = '492cdff6b79e46adb5938059495eacc9';

  List<Map<String, dynamic>> _searchResults = [];
  Marker? _currentMarker;
  bool _showInfoCard = false;
  bool _isSearchActive = false;
  Timer? _debounceTimer;

  String _locationName = '';
  String _locationCoordinates = '';
  String _country = '';
  String _currency = '';
  String _timezone = '';
  String _roadInfo = '';
  String _flag = '';
  String _sunrise = '';
  String _sunset = '';
  String _dms = '';
  String _fips = '';
  String _mgrs = '';
  String _maidenhead = '';
  String _geohash = '';
  String _qibla = '';
  String _callingCode = '';
  String _what3words = '';
  String _travelAlert = 'Loading...';

  static const List<Map<String, dynamic>> _majorCities = [
    {'name': 'Tokyo', 'lat': 35.6762, 'lon': 139.6503},
    {'name': 'New York', 'lat': 40.7128, 'lon': -74.0060},
    {'name': 'London', 'lat': 51.5074, 'lon': -0.1278},
    {'name': 'Paris', 'lat': 48.8566, 'lon': 2.3522},
    {'name': 'Dubai', 'lat': 25.2048, 'lon': 55.2708},
    {'name': 'Singapore', 'lat': 1.3521, 'lon': 103.8198},
    {'name': 'Sydney', 'lat': -33.8688, 'lon': 151.2093},
    {'name': 'Rio de Janeiro', 'lat': -22.9068, 'lon': -43.1729},
    {'name': 'Cape Town', 'lat': -33.9249, 'lon': 18.4241},
    {'name': 'Moscow', 'lat': 55.7558, 'lon': 37.6173},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _randomLocation() {
    final city = _majorCities[_random.nextInt(_majorCities.length)];
    final lat = city['lat'] + (_random.nextDouble() - 0.5) * 0.1;
    final lon = city['lon'] + (_random.nextDouble() - 0.5) * 0.1;
    _reverseGeocode(LatLng(lat, lon));
  }


   void _zoomIn() {
    setState(() {
      _currentZoom += 1; // Increase zoom level
    });
    _mapController.move(_currentCenter, _currentZoom);
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1; // Decrease zoom level
    });
    _mapController.move(_currentCenter, _currentZoom);
  }



  Future<void> _fetchTravelAlert(String city) async {
    try {
      final response = await http.get(
        Uri.parse("https://antonioroger.pythonanywhere.com/scrape?city=$city"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _travelAlert = data['content'] ?? 'No travel alert available.';
        });
      } else {
        setState(() {
          _travelAlert = 'Failed to fetch travel alert.';
        });
      }
    } catch (e) {
      setState(() {
        _travelAlert = 'Error fetching travel alert: $e';
      });
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.opencagedata.com/geocode/v1/json?q=${Uri.encodeComponent(query)}&key=$_apiKey&limit=5'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() =>
            _searchResults = List<Map<String, dynamic>>.from(data['results']));
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

 void _updateMap(double lat, double lng, String name, dynamic details) {
    if (!mounted) return;

    setState(() {
      _currentMarker = Marker(
        point: LatLng(lat, lng),
        width: 40, // Specify the width of the marker
        height: 40, // Specify the height of the marker
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      );

      _locationName = '$name';
      _locationCoordinates =
          ' ${lat.toStringAsFixed(6)}°, ${lng.toStringAsFixed(6)}°';
      _country = 'Country: ${_getNestedValue(details, [
                'components',
                'country'
              ]) ?? 'Unknown'}';
      _currency = _formatCurrency(details);
      _timezone = 'Timezone: ${_getNestedValue(details, [
                'annotations',
                'timezone',
                'name'
              ]) ?? 'Unknown'}';
      _sunrise = _formatSunTime(details, 'rise');
      _sunset = _formatSunTime(details, 'set');

      _dms = _formatDMS(details);
      _mgrs = 'MGRS: ${_getNestedValue(details, [
                'annotations',
                'MGRS'
              ]) ?? 'Unknown'}';
      _maidenhead = 'Maidenhead: ${_getNestedValue(details, [
                'annotations',
                'Maidenhead'
              ]) ?? 'Unknown'}';
      _geohash = 'Geohash: ${_getNestedValue(details, [
                'annotations',
                'geohash'
              ]) ?? 'Unknown'}';
      _qibla = 'Qibla: ${_getNestedValue(details, [
                'annotations',
                'qibla'
              ])?.toString() ?? 'Unknown'}°';
      _callingCode = 'Calling Code: ${_getNestedValue(details, [
                'annotations',
                'callingcode'
              ]) ?? 'Unknown'}';
      _what3words = 'What3Words: ${_getNestedValue(details, [
                'annotations',
                'what3words',
                'words'
              ]) ?? 'Unknown'}';

      _showInfoCard = true;
      _searchResults = [];
    });

    // Move the map to the new location
    _mapController.move(LatLng(lat, lng), 9);

    // Fetch travel alert for the location
    _fetchTravelAlert(name);
  }


  String? _getNestedValue(dynamic obj, List<String> keys) {
    dynamic current = obj;
    for (final key in keys) {
      if (current is! Map || !current.containsKey(key)) return null;
      current = current[key];
    }
    return current?.toString();
  }

  String _formatCurrency(dynamic details) {
    final name = _getNestedValue(details, ['annotations', 'currency', 'name']);
    final symbol =
        _getNestedValue(details, ['annotations', 'currency', 'symbol']);
    return 'Currency: ${name ?? 'Unknown'} ${symbol != null ? '($symbol)' : ''}';
  }

  String _formatSunTime(dynamic details, String type) {
    final timestamp =
        _getNestedValue(details, ['annotations', 'sun', type, 'apparent']);
    if (timestamp == null) return 'Unknown';
    try {
      final dateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
      return '${type.capitalize()}: ${dateTime.toLocal()}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatDMS(dynamic details) {
    final lat = _getNestedValue(details, ['annotations', 'DMS', 'lat']);
    final lng = _getNestedValue(details, ['annotations', 'DMS', 'lng']);
    return 'DMS: ${lat ?? 'Unknown'}, ${lng ?? 'Unknown'}';
  }

  void _debouncedSearch(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _handleSearch(value);
    });
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    const LatLng(22.0, 78.0), // Set initial center position
                initialZoom: 5.0, // Set initial zoom level
                minZoom: 2.0,
                maxZoom: 18.0,
                onTap: (tapPosition, latLng) =>
                    _reverseGeocode(latLng), // Handle map tap
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all &
                      ~InteractiveFlag.rotate, // Disable rotation
                ),
                onMapEvent: (event) {
                  if (event is MapEventMoveEnd) {
                    final camera = _mapController.camera;
                    final zoomLevel = camera.zoom;
                    final center = camera.center;
                    if (zoomLevel <= 2) {
                      _mapController.move(
                        LatLng(0, center.longitude),
                        zoomLevel,
                      );
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.map_explorer',
                ),
                if (_currentMarker != null)
                  MarkerLayer(
                    markers: [_currentMarker!],
                  ),
              ],
            ),
            _buildSearchBar(),
            if (_searchResults.isNotEmpty) _buildSearchResults(),
            _buildControls(),
            if (_showInfoCard) _buildInfoCard(),
          ],
        ),
      ),
    );
  }



  Widget _buildSearchBar() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for a location...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.blueAccent.withOpacity(0.6),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                  ),
                  onChanged: (value) {
                    _debouncedSearch(value);
                    setState(() {
                      _isSearchActive = value.isNotEmpty; // Set search state
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Positioned(
      top: 76,
      left: 16,
      right: 16,
      bottom: 16,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return ListTile(
                title: Text(
                  result['formatted'] ?? 'Unknown location',
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  _searchController.text = result['formatted'] ?? '';
                  final geometry = result['geometry'];
                  if (geometry != null) {
                    _updateMap(
                      (geometry['lat'] as num).toDouble(),
                      (geometry['lng'] as num).toDouble(),
                      result['formatted'] ?? 'Unknown location',
                      result,
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      right: 16,
      bottom: _showInfoCard ? 650 : 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.add,
            onPressed: _zoomIn,
            size: 56,
          ),
          const SizedBox(height: 16),
          _buildControlButton(
            icon: Icons.remove,
            onPressed: _zoomOut,
            size: 56,
          ),
          const SizedBox(height: 16),
          _buildControlButton(
            icon: Icons.shuffle,
            onPressed: _randomLocation,
            size: 56,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 48,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: size * 0.5,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 12,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 8),
              _buildCountryCurrencyTimezone(),
              const SizedBox(height: 12),
              _buildTravelAlert(),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 12),
              _buildPlanTripButton(),
              const Divider(thickness: 1, color: Colors.grey),
              _buildCoordinatesAndCode(),
              const Divider(thickness: 1, color: Colors.grey),
              _buildTechnicalDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            _locationName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => setState(() => _showInfoCard = false),
        ),
      ],
    );
  }

  Widget _buildCountryCurrencyTimezone() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text('$_country', style: _infoTextStyle())),
          Flexible(child: Text('$_currency', style: _infoTextStyle())),
          Flexible(child: Text('$_timezone', style: _infoTextStyle())),
        ],
      ),
    );
  }

  Widget _buildTravelAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5E57), Color(0xFFFE4A49)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: _showTravelAlertDialog,
        child: Text(
          '🚨 Travel Alert: ${_travelAlert.split('\n').first.length > 80 ? _travelAlert.split('\n').first.substring(0, 80) : _travelAlert.split('\n').first}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCoordinatesAndCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('', _callingCode, '', _locationCoordinates),
      ],
    );
  }

  Widget _buildPlanTripButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          final locationData = {
            'destination': _locationName.replaceAll('Location: ', ''),
            'coordinates': {
              'lat': _currentMarker?.point.latitude,
              'lng': _currentMarker?.point.longitude,
            },
            'country': _country.replaceAll('Country: ', ''),
            'travelAlert': _travelAlert,
          };

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripPlanner(locationData: locationData),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(55, 178, 253, 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Plan A Trip',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(_dms, ""),
        _buildDetailRow(_mgrs, "", _maidenhead, ""),
        _buildDetailRow(_geohash, "", _qibla, ""),
        _buildDetailRow(_what3words, ""),
      ],
    );
  }

  Widget _buildDetailRow(String label1, String value1,
      [String? label2, String? value2]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text('$label1 $value1', style: _infoTextStyle())),
          if (label2 != null && value2 != null)
            Flexible(child: Text('$label2 $value2', style: _infoTextStyle())),
        ],
      ),
    );
  }

  TextStyle _infoTextStyle() {
    return const TextStyle(fontSize: 14, color: Colors.black54);
  }

  void _showTravelAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFf8fafc),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Text(
          'Travel Alert',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          "$_country ! " + _travelAlert,
          style: TextStyle(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 16,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() {
      _travelAlert = "Loading...";
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.opencagedata.com/geocode/v1/json?q=${pos.latitude}+${pos.longitude}&key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          _updateMap(pos.latitude, pos.longitude,
              result['formatted'] ?? 'Unknown location', result);
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
