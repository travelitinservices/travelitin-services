import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:thingqbator/core/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Function(String) onSelected;
  final VoidCallback? onTap;

  const LocationSearchBar({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onSelected,
    this.onTap,
  });

  Future<List<String>> _fetchSuggestions(String query) async {
    if (query.isEmpty) return [];
    final apiKey = dotenv.env['OPEN_CAGE_API_KEY'] ?? '';
    final url = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?q=$query&key=$apiKey&limit=5');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(
          data['results'].map((result) => result['formatted'] ?? ''),
        );
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
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
      itemBuilder: (context, String suggestion) {
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(suggestion, style: const TextStyle(color: Colors.black)),
        );
      },
      onSelected: onSelected,
    );
  }
}