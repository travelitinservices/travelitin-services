import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'package:travelitin/core/constants/theme/appTheme.dart';
import 'package:travelitin/core/constants/theme/color_extension.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 255, 0.907),
      cardTheme: CardTheme(
        elevation: 4,
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    ),
    home: ScamReportPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class ScamReportPage extends StatefulWidget {
  const ScamReportPage({super.key});

  @override
  _ScamReportPageState createState() => _ScamReportPageState();
}

class _ScamReportPageState extends State<ScamReportPage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  int? _selectedRating;

  bool isLoading = true;
  bool isSubmitting = false;
  bool showReportForm = true;
  bool showSearchForm = true;
  String firstName = 'Guest';
  List<Map<String, dynamic>> searchResults = [];
  final ScrollController _scrollController = ScrollController();

  final Map<String, String> _helplineNumbers = {
    'India': '+91-112',
    'United States': '+1-911',
    'United Kingdom': '+44-999',
    'Canada': '+1-911',
    'Australia': '+61-000',
    'Global': '+1-800-XXX-XXXX',
  };

  String _currentHelpline = '+1-800-XXX-XXXX';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    locationController.addListener(_updateHelpline);
  }

  @override
  void dispose() {
    locationController.removeListener(_updateHelpline);
    locationController.dispose();
    contentController.dispose();
    searchController.dispose();
    _reviewController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateHelpline() {
    final locationText = locationController.text.toLowerCase();
    String matchedHelpline = _helplineNumbers['Global']!;

    _helplineNumbers.forEach((country, number) {
      if (locationText.contains(country.toLowerCase())) {
        matchedHelpline = number;
      }
    });

    setState(() {
      _currentHelpline = matchedHelpline;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('intel')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var docSnapshot = querySnapshot.docs[0];
          setState(() {
            firstName = docSnapshot['firstName'] ?? 'Guest';
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching user data');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> reportScam() async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showErrorSnackBar('You must be logged in to report a scam');
        return;
      }

      final location = locationController.text.trim();
      final content = contentController.text.trim();

      if (location.isEmpty || content.isEmpty) {
        _showErrorSnackBar('Please fill in all fields');
        return;
      }

      await FirebaseFirestore.instance.collection('scams').add({
        'location': location,
        'content': content,
        'userEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSuccessSnackBar('Scam reported successfully!');

      locationController.clear();
      contentController.clear();

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );

      await performSearch(location);
    } catch (e) {
      _showErrorSnackBar('Error reporting scam');
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<List<String>> fetchSuggestions(String query) async {
    if (query.isEmpty) return [];
    const apiKey = '492cdff6b79e46adb5938059495eacc9';
    final url = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?q=$query&key=$apiKey&limit=2');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(
          data['results'].map((result) => result['formatted'] ?? ''),
        );
      } else {
        print('Error fetching suggestions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final normalizedQuery = query.toLowerCase();

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scams')
          .orderBy('timestamp', descending: true)
          .get();

      final filteredScams = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final location = (data['location'] ?? '').toString().toLowerCase();
        final content = (data['content'] ?? '').toString().toLowerCase();

        return location.contains(normalizedQuery) ||
            normalizedQuery.contains(location) ||
            content.contains(normalizedQuery);
      }).map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
          'timestamp': data['timestamp']?.toDate(),
        };
      }).toList();

      setState(() {
        searchResults = filteredScams;
      });
    } catch (e) {
      _showErrorSnackBar('Error searching for scams');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Scams'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: false,
            snap: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.lightTheme.primaryColor.withOpacity(0.9),
                      AppTheme.lightTheme.primaryColor.darken(0.1),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Safety, Our Priority',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Report online scams and get immediate support.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Report a Scam Section
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.report_problem, color: Colors.redAccent, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Report a Scam',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Provide details of the scam to help us take action.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          TypeAheadField<String>(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: locationController,
                              decoration: InputDecoration(
                                labelText: 'Location (Country, City, etc.)',
                                hintText: 'e.g., India, New Delhi',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                            ),
                            suggestionsCallback: fetchSuggestions,
                            itemBuilder: (context, String suggestion) {
                              return ListTile(
                                title: Text(suggestion),
                              );
                            },
                            onSuggestionSelected: (String suggestion) {
                              locationController.text = suggestion;
                            },
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: contentController,
                            decoration: InputDecoration(
                              labelText: 'Scam Description',
                              hintText: 'Describe the scam in detail...',
                              alignLabelWithHint: true,
                            ),
                            maxLines: 6,
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isSubmitting ? null : reportScam,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              icon: isSubmitting ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Icon(Icons.send),
                              label: Text(
                                isSubmitting ? 'Submitting...' : 'Submit Report',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Rate Your Experience Section
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Rate Your Experience',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Help us improve by rating your experience with our reporting process.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < (_selectedRating ?? 0) ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 36,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedRating = index + 1;
                                  });
                                },
                              );
                            }),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _reviewController,
                            decoration: InputDecoration(
                              labelText: 'Your Comments (Optional)',
                              hintText: 'Share your feedback...',
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Implement review submission logic here
                                _showSuccessSnackBar('Thank you for your feedback!');
                                setState(() {
                                  _selectedRating = null;
                                  _reviewController.clear();
                                });
                              },
                              icon: Icon(Icons.feedback, color: Colors.white),
                              label: Text('Submit Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Helpline & Support Section
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.green, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Helpline & Support',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Contact relevant authorities in your region for immediate assistance.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Helpline:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
                                _currentHelpline,
                                style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Note: The helpline number displayed is based on the location you entered. Always verify with local official sources. In case of immediate danger, contact your local emergency services (e.g., 911 in the US, 112 in EU, 999 in UK, 100 in India).',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Search Reported Scams Section
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.search, color: Colors.blue, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Search Reported Scams',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Search our database for previously reported scams by location or description.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          TypeAheadField<String>(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: searchController,
                              decoration: InputDecoration(
                                labelText: 'Search by Location or Content',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                            suggestionsCallback: fetchSuggestions,
                            itemBuilder: (context, String suggestion) {
                              return ListTile(
                                leading: Icon(Icons.location_on),
                                title: Text(
                                  suggestion,
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            },
                            onSuggestionSelected: (String suggestion) {
                              searchController.text = suggestion;
                              performSearch(suggestion);
                            },
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                performSearch(searchController.text.trim());
                              },
                              icon: Icon(Icons.search, color: Colors.white),
                              label: Text('Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Search Results Display
                  if (isLoading) ...[
                    Center(child: CircularProgressIndicator()),
                  ] else if (searchResults.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Recent Scam Reports',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        final timestamp = result['timestamp'] as DateTime?;
                        final formattedDate = timestamp != null
                            ? DateFormat('MMM d, yyyy h:mm a').format(timestamp)
                            : 'Date unknown';

                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.blue[600], size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        result['location'] ?? 'Unknown Location',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  result['content'] ?? 'No Details Provided',
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.grey[500], size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ] else if (searchController.text.isNotEmpty) ...[
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No scams reported in this area yet.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 40), // Spacing at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportScams extends StatefulWidget {
  const ReportScams({super.key});

  @override
  State<ReportScams> createState() => _ReportScamsState();
}

class _ReportScamsState extends State<ReportScams> {
  final TextEditingController _descriptionController = TextEditingController();
  bool isSmallScreen = false;

  @override
  Widget build(BuildContext context) {
    isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Scams'),
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Container(
        decoration: AppTheme.glassmorphismDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: AppTheme.inputDecoration.copyWith(
                labelText: 'Describe the scam',
                hintText: 'Please provide details about the scam you encountered...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement scam reporting
              },
              child: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
