import 'package:flutter/material.dart';
import 'package:travelitin/core/services/location_service.dart';
import 'package:travelitin/features/location/widgets/location_search_bar.dart';

class SearchPlacePage extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();

  SearchPlacePage({super.key});

  void _onLocationSelected(LocationSuggestion location) {
    // Handle the selected location
    debugPrint('Selected location: ${location.formattedAddress}');
    debugPrint('Coordinates: ${location.latitude}, ${location.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search by Place'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LocationSearchBar(
              controller: searchController,
              labelText: 'Search for a place',
              onSelected: _onLocationSelected,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_searching,
                      size: 64,
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search for a place to get started',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 