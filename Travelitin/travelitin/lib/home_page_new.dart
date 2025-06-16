import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDarkMode = false;
  int navTabIndex = 0;
  int searchTabIndex = 0;
  int offersTabIndex = 0;
  final String userName = "Traveler";
  final TextEditingController _searchController = TextEditingController();

  // ... (keep all your existing lists and data)

  void _showLocationSearchSheet(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select ${isFrom ? 'Origin' : 'Destination'}', 
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TypeAheadField<Map<String, String>>(
                controller: _searchController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      labelText: 'Search city or airport',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  );
                },
                suggestionsCallback: (pattern) {
                  return locations.where((loc) =>
                    loc['city']!.toLowerCase().contains(pattern.toLowerCase()) ||
                    loc['code']!.toLowerCase().contains(pattern.toLowerCase()) ||
                    loc['desc']!.toLowerCase().contains(pattern.toLowerCase())
                  ).toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['city']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${suggestion['code']} - ${suggestion['desc']}'),
                  );
                },
                onSelected: (suggestion) {
                  setState(() {
                    if (isFrom) {
                      fromLocationDisplay = suggestion['city'];
                    } else {
                      toLocationDisplay = suggestion['city'];
                    }
                  });
                  Navigator.pop(context);
                },
                emptyBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No location found'),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final loc = locations[index];
                    return ListTile(
                      title: Text(loc['city']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${loc['code']} - ${loc['desc']}'),
                      onTap: () {
                        setState(() {
                          if (isFrom) {
                            fromLocationDisplay = loc['city'];
                          } else {
                            toLocationDisplay = loc['city'];
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ... (keep all your other widget methods)

  @override
  Widget build(BuildContext context) {
    // ... (keep your existing build method)
  }
} 