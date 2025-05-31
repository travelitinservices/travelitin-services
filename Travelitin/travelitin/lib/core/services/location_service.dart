import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const String _baseUrl = 'https://api.opencagedata.com/geocode/v1/json';
  final String _apiKey;

  LocationService() : _apiKey = dotenv.env['OPEN_CAGE_API_KEY'] ?? '';

  Future<List<LocationSuggestion>> searchLocations(String query) async {
    if (query.isEmpty) return [];
    if (_apiKey.isEmpty) {
      throw Exception('OpenCage API key is not configured');
    }

    final url = Uri.parse('$_baseUrl?q=$query&key=$_apiKey&limit=5');

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        return results.map((result) {
          final components = result['components'] as Map<String, dynamic>;
          final geometry = result['geometry'] as Map<String, dynamic>;
          
          return LocationSuggestion(
            formattedAddress: result['formatted'] ?? '',
            city: components['city'] ?? components['town'] ?? '',
            state: components['state'] ?? '',
            country: components['country'] ?? '',
            latitude: geometry['lat']?.toDouble() ?? 0.0,
            longitude: geometry['lng']?.toDouble() ?? 0.0,
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching locations: $e');
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }
}

class LocationSuggestion {
  final String formattedAddress;
  final String city;
  final String state;
  final String country;
  final double latitude;
  final double longitude;

  LocationSuggestion({
    required this.formattedAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => formattedAddress;
} 