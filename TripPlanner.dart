import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thingqbator/home_page.dart';
import 'firebase_options.dart';

class Planner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Trip Planner',
      theme: ThemeData(
        primaryColor: const Color(0xFF3B82F6),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TripPlanner(),
    );
  }
}

class TripPlanner extends StatefulWidget {
  final Map<String, dynamic>? locationData;

  const TripPlanner({Key? key, this.locationData}) : super(key: key);

  @override
  TripPlannerState createState() => TripPlannerState();
}

class TripPlannerState extends State<TripPlanner>
    with SingleTickerProviderStateMixin {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _fromLocationController = TextEditingController();
  String? _travelType;
  String? _costPreference;
  int _numberOfPeople = 1;
  String userEmail = "Guest";
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String _itinerary = "";
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _searchResults = [];
  Position? _currentPosition;

  static const String _apiKey = '492cdff6b79e46adb5938059495eacc9';

  final List<String> _travelTypes = [
    'Adventurous',
    'Sightseeing',
    'Religious',
    'Family',
    'Romantic',
  ];

  final List<String> _costPreferences = [
    'Luxurious (4 of 4)',
    'Moderate (3 of 4)',
    'Economy (2 of 4)',
    'Cheap (1 of 4)',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _getCurrentLocation();

    if (widget.locationData != null) {
      _destinationController.text = widget.locationData!['destination'] ?? '';
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _fromLocationController.text = data['display_name'] ?? '';
          _currentPosition = position;
        });
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _activeSearchField = '';

  Future<void> _handleSearch(String query, {required String field}) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _activeSearchField = '';
      });
      return;
    }
    setState(() => _activeSearchField = field);

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.opencagedata.com/geocode/v1/json?q=${Uri.encodeComponent(query)}&key=$_apiKey&limit=2',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        setState(() {
          _searchResults = results
              .map((result) =>
                  {"formatted": result['formatted'] ?? "Unknown location"})
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedStartDate != null && _selectedEndDate != null
          ? DateTimeRange(start: _selectedStartDate!, end: _selectedEndDate!)
          : DateTimeRange(
              start: DateTime.now(),
              end: DateTime.now().add(Duration(days: 1)),
            ),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 220)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF2563EB),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
    }
  }

  Future<void> fetchUserEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      setState(() {
        userEmail = user?.email ?? "Guest";
      });
    } catch (e) {
      print("Error fetching user email: $e");
    }
  }

  Future<void> generateItinerary() async {
    final destination = _destinationController.text.trim();
    final fromLocation = _fromLocationController.text.trim();

    if (destination.isEmpty ||
        fromLocation.isEmpty ||
        _selectedStartDate == null ||
        _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    const groqApiKey =
        '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';
    const groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
    const searchApiEndpoint = 'https://antonioroger.pythonanywhere.com/scrape';

    String? finalItinerary;

    try {
      bool useSearchData = false;
      String? searchContent;

      try {
        print('\n🔍 Attempting to fetch data from Custom Search API...');
        final mode = 'planner';
        final searchResponse = await http.get(
          Uri.parse('$searchApiEndpoint?city=$destination&mode=$mode'),
          headers: {"Content-Type": "application/json"},
        );

        if (searchResponse.statusCode == 200) {
          print('✅ Custom Search API response received successfully');

          final searchData = json.decode(searchResponse.body);
          final content = searchData['content'] as String?;
          final sources = searchData['sources'] as List<dynamic>?;

          if (content != null &&
              content.isNotEmpty &&
              content != "Safe to travel.") {
            searchContent = '''
Travel Alert Information:
$content

Sources:
${sources?.join('\n') ?? 'No sources available'}
''';
          }
        }
      } catch (e) {
        print('❌ Custom Search API error: $e');
      }

      String groqPrompt;
      if (useSearchData) {
        groqPrompt = """
        Based on the following travel-related details, create a detailed date-by-date time wise itinerary:
        - Travel dates: ${DateFormat.yMMMd().format(_selectedStartDate!)} to ${DateFormat.yMMMd().format(_selectedEndDate!)}
        - From: $fromLocation
        - Destination: $destination
        - Number of persons: $_numberOfPeople
        - Budget preference: ${_costPreference ?? 'moderate'}
        
        Travel Data:
        $searchContent
        
        1.Solely rely on given data no  Local attractions and activities, considering provided travel data , Recommended restaurants and dining incorporating the travel information and costs
        2. At last Important local rules and customs Safety tips and alerts (incorporating the travel information)
        note :Estimated costs in INR (Indian Rupees) No markdown symbols than direct ascii special characters only without adding inaccurate or fabricated details or hallucinations.response is directly displayed to user. dont address the user in any way. avoid intros/outro

        Format each day clearly with bullet points , bold for sub/headings , tour locations finally include travel tips and alerts if any.
      """;
      } else {
        groqPrompt = """
        Create a detailed travel itinerary for a trip with the following details:
        
        Trip Details:
        - Travel dates: ${DateFormat.yMMMd().format(_selectedStartDate!)} to ${DateFormat.yMMMd().format(_selectedEndDate!)}
        - From: $fromLocation
        - Destination: $destination
        - Number of persons: $_numberOfPeople
        - Budget preference: ${_costPreference ?? 'moderate'}

        Please create a comprehensive day-by-day itinerary that includes:
        1. Major attractions and must-visit places
        2. Popular local restaurants and cuisine
        3. Important local customs and rules
        4. Common tourist scams to avoid
        5. Safety considerations
        6. Transportation options
        7. Estimated costs in INR (Indian Rupees)
        8. Local weather considerations
        9. without adding inaccurate or fabricated details or hallucinations.response is directly displayed to user. dont address the user in any way. avoid intros/outro

        Format the response as a detailed day-by-day itinerary with bullet points. Include specific recommendations for activities, dining, and experiences. Add relevant travel tips and safety information throughout the itinerary.
      """;
      }

      String? itineraryContent = await _processWithGroqRetry(
        groqPrompt,
        groqEndpoint,
        groqApiKey,
      );

      if (itineraryContent != null) {
        finalItinerary = itineraryContent;
      } else {
        throw Exception('Failed to generate itinerary after multiple attempts');
      }

      if (finalItinerary != null) {
        final user = FirebaseAuth.instance.currentUser;
        final userEmail = user?.email ?? 'Guest';
        final userDocRef =
            FirebaseFirestore.instance.collection('itineraries').doc(userEmail);

        await userDocRef.collection('userItineraries').add({
          'destination': destination,
          'fromLocation': fromLocation,
          'itinerary': finalItinerary,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Itinerary saved successfully!')),
        );

        setState(() {
          _itinerary = "$finalItinerary";
        });

        _destinationController.clear();
        _fromLocationController.clear();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
      setState(() {
        _itinerary =
            "An error occurred while generating the itinerary. Error: $error";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _processWithGroqRetry(
    String prompt,
    String groqEndpoint,
    String groqApiKey, {
    int maxRetries = 5,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final groqPayload = {
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "model": "llama-3.3-70b-versatile",
          "temperature": 1,
          "max_tokens": 4000,
          "top_p": 1,
          "stream": false
        };

        final groqResponse = await http.post(
          Uri.parse(groqEndpoint),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $groqApiKey",
          },
          body: json.encode(groqPayload),
        );

        if (groqResponse.statusCode == 429) {
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception('Max retries reached for rate limit');
          }

          final backoffMs =
              math.min(1000 * math.pow(2, retryCount), 10000).toInt();
          final jitter = math.Random().nextInt(1000);
          await Future.delayed(Duration(milliseconds: backoffMs + jitter));
          continue;
        }

        if (groqResponse.statusCode != 200) {
          throw Exception('Groq API error: ${groqResponse.statusCode}');
        }

        final groqData = json.decode(groqResponse.body);
        final choices = groqData['choices'] ?? [];

        if (choices.isEmpty) {
          throw Exception('No choices found in Groq response.');
        }

        return choices[0]['message']['content'];
      } catch (e) {
        if (e.toString().contains('429') && retryCount < maxRetries) {
          retryCount++;
          final backoffMs =
              math.min(1000 * math.pow(2, retryCount), 10000).toInt();
          final jitter = math.Random().nextInt(1000);
          await Future.delayed(Duration(milliseconds: backoffMs + jitter));
          continue;
        }
        rethrow;
      }
    }
    return null;
  }

  void showItineraryDashboard(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String userEmail = user?.email ?? 'Guest';

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('itineraries')
              .doc(userEmail)
              .collection('userItineraries')
              .orderBy('timestamp', descending: true)
              .get();

      List<Map<String, dynamic>> itineraries = querySnapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      if (itineraries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No saved itineraries found!')),
        );
        return;
      }

      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Your Saved Itineraries',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: itineraries.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> itinerary = itineraries[index];
                        String destination =
                            itinerary['destination'] ?? 'No destination';
                        String fromLocation =
                            itinerary['fromLocation'] ?? 'Unknown location';
                        Timestamp? timestamp =
                            itinerary['timestamp'] as Timestamp?;
                        String dateStr = timestamp != null
                            ? DateFormat('MMM d, yyyy')
                                .format(timestamp.toDate())
                            : 'No date';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              destination,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'From: $fromLocation',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                Text(
                                  'Created: $dateStr',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () => _viewItineraryDetails(
                                    context,
                                    itineraries,
                                    index,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deleteItinerary(
                                    context,
                                    userEmail,
                                    itinerary['id'],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _viewItineraryDetails(
                              context,
                              itineraries,
                              index,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading itineraries: $e')),
        );
      }
    }
  }

  Future<void> _deleteItinerary(
    BuildContext context,
    String userEmail,
    String itineraryId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('itineraries')
          .doc(userEmail)
          .collection('userItineraries')
          .doc(itineraryId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Itinerary deleted successfully')),
        );
        Navigator.pop(context);
        showItineraryDashboard(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting itinerary: $e')),
        );
      }
    }
  }

  void _viewItineraryDetails(BuildContext context,
      List<Map<String, dynamic>> itineraries, int selectedIndex) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Map<String, dynamic> selectedItinerary = itineraries[selectedIndex];
    String itineraryContent =
        selectedItinerary['itinerary'] ?? 'No itinerary content';

    setState(() {
      _itinerary = itineraryContent;
    });
  }

  void resetForm() {
    setState(() {
      _destinationController.clear();
      _travelType = null;
      _costPreference = null;
      _selectedStartDate = null;
      _selectedEndDate = null;
      _itinerary = "";
      _isLoading = false;
      _searchResults = [];
    });
    _getCurrentLocation();
  }

  static const textColor = Color(0xFF1E293B);
  static const borderColor = Color(0xFFE2E8F0);

  Widget _buildInputField({
    required Widget child,
    required String label,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: borderColor,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'AI Trip Planner',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(1),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: _itinerary.isEmpty
                  ? _buildPlanningForm()
                  : _buildItineraryView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchCard(),
          SizedBox(height: 16),
          _buildPreferencesCard(),
          SizedBox(height: 16),
          _buildGenerateButton(),
          SizedBox(height: 16),
          _buildItineraryDashboardButton(),
        ],
      ),
    );
  }

  Widget _buildItineraryDashboardButton() {
    return ElevatedButton(
      onPressed: () {
        showItineraryDashboard(context);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        backgroundColor: Colors.grey.shade700,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard,
            color: Theme.of(context).primaryColorLight,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'Itinerary Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Stack(
      children: [
        Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Where to?',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 20),
                _buildLocationField(
                  controller: _fromLocationController,
                  icon: Icons.my_location,
                  label: 'Current Location',
                  readOnly: false,
                  onChanged: (query) => _handleSearch(query, field: 'from'),
                ),
                if (_activeSearchField == 'from' && _searchResults.isNotEmpty)
                  _buildSearchResults(),
                SizedBox(height: 16),
                _buildLocationField(
                  controller: _destinationController,
                  icon: Icons.search,
                  label: 'Search destination',
                  onChanged: (query) => _handleSearch(query, field: 'to'),
                ),
                if (_activeSearchField == 'to' && _searchResults.isNotEmpty)
                  _buildSearchResults(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Details',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 20),
            _buildDateRangePicker(),
            SizedBox(height: 16),
            _buildTravellerCounter(),
            SizedBox(height: 16),
            _buildPreferenceDropdowns(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          hintText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: _searchResults.map((result) {
          return ListTile(
            leading:
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
            title: Text(result['formatted']),
            onTap: () {
              setState(() {
                if (_activeSearchField == 'from') {
                  _fromLocationController.text = result['formatted'];
                } else if (_activeSearchField == 'to') {
                  _destinationController.text = result['formatted'];
                }
                _searchResults = [];
                _activeSearchField = '';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return InkWell(
      onTap: _pickDateRange,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedStartDate != null && _selectedEndDate != null
                    ? '${DateFormat.yMMMd().format(_selectedStartDate!)} - ${DateFormat.yMMMd().format(_selectedEndDate!)}'
                    : 'Select dates',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravellerCounter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Theme.of(context).primaryColor),
              SizedBox(width: 12),
              Text(
                'Travelers',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () {
                  if (_numberOfPeople > 1) {
                    setState(() => _numberOfPeople--);
                  }
                },
                color: Theme.of(context).primaryColor,
              ),
              Text(
                '$_numberOfPeople',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {
                  if (_numberOfPeople < 10) {
                    setState(() => _numberOfPeople++);
                  }
                },
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceDropdowns() {
    return Column(
      children: [
        _buildDropdown(
          value: _travelType,
          items: _travelTypes,
          icon: Icons.group,
          label: 'Travel Type',
          onChanged: (value) => setState(() => _travelType = value),
        ),
        SizedBox(height: 16),
        _buildDropdown(
          value: _costPreference,
          items: _costPreferences,
          icon: Icons.attach_money,
          label: 'Budget',
          onChanged: (value) => setState(() => _costPreference = value),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required IconData icon,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              SizedBox(width: 12),
              Text(label),
            ],
          ),
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down,
              color: Theme.of(context).primaryColor),
          dropdownColor: Colors.white,
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, color: Theme.of(context).primaryColor),
                  SizedBox(width: 12),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: generateItinerary,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: _isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Creating your perfect trip...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : Text(
              'Generate AI Itinerary',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildItineraryView() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Personalized Itinerary',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Divider(height: 30),
                  MarkdownBody(data: _itinerary),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Theme.of(context).primaryColor),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Generated by AI using Llama 3 70B',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: resetForm,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: Text(
              'Go to Planner Home',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildItineraryDashboardButton(),
        ],
      ),
    );
  }
}
