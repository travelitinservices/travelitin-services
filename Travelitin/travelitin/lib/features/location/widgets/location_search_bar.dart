import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:travelitin/core/services/location_service.dart';
import 'package:travelitin/core/theme/app_theme.dart';

class LocationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Function(LocationSuggestion) onSelected;
  final VoidCallback? onTap;
  final LocationService _locationService = LocationService();

  LocationSearchBar({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onSelected,
    this.onTap,
  });

  Future<List<LocationSuggestion>> _fetchSuggestions(String query) async {
    try {
      return await _locationService.searchLocations(query);
    } catch (e) {
      debugPrint('Error fetching location suggestions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<LocationSuggestion>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: AppTheme.inputDecoration(labelText).copyWith(
            prefixIcon: const Icon(Icons.location_pin),
          ),
          keyboardType: TextInputType.text,
          autofillHints: const [],
          onTap: onTap,
        );
      },
      suggestionsCallback: _fetchSuggestions,
      itemBuilder: (context, LocationSuggestion suggestion) {
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(suggestion.formattedAddress),
          subtitle: Text(
            [suggestion.city, suggestion.state, suggestion.country]
                .where((s) => s.isNotEmpty)
                .join(', '),
          ),
        );
      },
      onSelected: onSelected,
      errorBuilder: (context, error) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Error loading suggestions: ${error.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
      noItemsFoundBuilder: (context) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No locations found'),
        );
      },
      loadingBuilder: (context) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
} 