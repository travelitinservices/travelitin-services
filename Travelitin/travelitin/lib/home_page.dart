import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:travelitin/report_scams.dart'; // Import for ReportScamsPage
import 'package:travelitin/chatwidgets.dart'; // Import for TravelChatPage
import 'package:travelitin/placeholder_page.dart'; // Import for PlaceholderPage
import 'package:travelitin/features/travel/screens/TripPlanner.dart';
import 'package:travelitin/features/travel/screens/travel_expense.dart';
import 'package:travelitin/features/translate/screens/translate.dart';
import 'package:travelitin/features/travel/screens/Travelchat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  String _userName = "Traveler";
  String? currentLocation;
  String travelAlert = '⚠️ Heavy rain expected in Coimbatore today. Please plan accordingly!';
  bool isFetchingLocation = true;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> navTabs = [
    {'icon': FontAwesomeIcons.plane, 'label': 'Flights'},
    {'icon': FontAwesomeIcons.hotel, 'label': 'Hotels'},
    {'icon': FontAwesomeIcons.house, 'label': 'Homestays & Villas'},
    {'icon': FontAwesomeIcons.suitcaseRolling, 'label': 'Holiday Packages'},
    {'icon': FontAwesomeIcons.train, 'label': 'Trains'},
    {'icon': FontAwesomeIcons.bus, 'label': 'Buses'},
    {'icon': FontAwesomeIcons.taxi, 'label': 'Cabs'},
    {'icon': FontAwesomeIcons.passport, 'label': 'Visa'},
    {'icon': FontAwesomeIcons.moneyBillWave, 'label': 'Forex Card & Currency'},
    {'icon': FontAwesomeIcons.shieldAlt, 'label': 'Travel Insurance'},
  ];

  final List<String> searchTabs = [
    'Flights', 'Hotels', 'Trains', 'Cabs', 'Visa', 'Forex'
  ];

  final List<String> offersTabs = [
    'All Offers', 'Bank Offers', 'Flights', 'Hotels', 'Holidays', 'Trains', 'Cabs', 'Bus', 'Forex'
  ];

  final List<Map<String, String>> offers = [
    {
      'img': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'title': 'NEW: Special Amarnath Yatra Holiday Packages.',
      'desc': 'Get confirmed registration, free Shikara ride & more.',
      'cta': 'BOOK NOW'
    },
    {
      'img': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=400&q=80',
      'title': 'FOR 3, 6 OR 9-HOUR STAYS:',
      'desc': 'Book Hourly Stays @ FLAT 20% OFF*.',
      'cta': 'BOOK NOW'
    },
    {
      'img': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=400&q=80',
      'title': 'Grab Up to 40% OFF*',
      'desc': 'on Hotels, Homestays & Villas in India with our Check-in to a Break Sale!',
      'cta': 'BOOK NOW'
    },
    {
      'img': 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=400&q=80',
      'title': 'Grab FLAT 15% OFF* on International Hotels',
      'desc': 'and book a comfy stay with big savings!',
      'cta': 'VIEW DETAILS'
    },
  ];

  final List<Map<String, String>> collections = [
    {
      'img': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
      'title': "Stays in & Around Delhi for a Weekend Getaway",
      'tag': 'TOP 8'
    },
    {
      'img': 'https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=400&q=80',
      'title': "Stays in & Around Mumbai for a Weekend Getaway",
      'tag': 'TOP 8'
    },
    {
      'img': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=400&q=80',
      'title': "Stays in & Around Bangalore for a Weekend Getaway",
      'tag': 'TOP 9'
    },
    {
      'img': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'title': "Beach Destinations",
      'tag': 'TOP 11'
    },
    {
      'img': 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=400&q=80',
      'title': "Weekend Getaways",
      'tag': 'TOP 11'
    },
    {
      'img': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=400&q=80',
      'title': "Hill Stations",
      'tag': 'TOP 11'
    },
  ];

  final List<Map<String, String>> locations = [
    {'city': 'Delhi', 'code': 'DEL', 'desc': 'Delhi Airport India'},
    {'city': 'Bengaluru', 'code': 'BLR', 'desc': 'Bengaluru International Airport'},
    {'city': 'Mumbai', 'code': 'BOM', 'desc': 'Mumbai Airport India'},
    {'city': 'Chennai', 'code': 'MAA', 'desc': 'Chennai Airport India'},
    {'city': 'Kolkata', 'code': 'CCU', 'desc': 'Kolkata Airport India'},
    {'city': 'Hyderabad', 'code': 'HYD', 'desc': 'Hyderabad Airport India'},
    {'city': 'Goa', 'code': 'GOI', 'desc': 'Goa Airport India'},
  ];

  String? fromLocationDisplay;
  String? toLocationDisplay;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    
  }

  Future<void> fetchUserName() async {
    try {
    final user = FirebaseAuth.instance.currentUser;
    print('Current user: ${user?.uid ?? "null"}');

    final idToken = await user?.getIdToken();
    if (idToken == null) {
      setState(() => _userName = 'Not signed in');
      return;
    }

    final response = await http.get(
      Uri.parse('https://username-retrieval-api.onrender.com/api/username'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched username data: $data');
      setState(() {
        _userName = data['username'] ?? "Traveler";
      });
    } else {
      print('Failed to fetch username. Status: ${response.statusCode}');
      setState(() => _userName = 'Unknown');
    }
  } catch (e) {
    print('Error during username fetch: $e');
    setState(() => _userName = 'Error');
  }
}

  

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
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    labelText: 'Search city or airport',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                suggestionsCallback: (pattern) {
                  return locations.where((loc) =>
                    (loc['city'] ?? '').toLowerCase().contains(pattern.toLowerCase()) ||
                    (loc['code'] ?? '').toLowerCase().contains(pattern.toLowerCase()) ||
                    (loc['desc'] ?? '').toLowerCase().contains(pattern.toLowerCase())
                  ).toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['city'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${suggestion['code'] ?? ''} - ${suggestion['desc'] ?? ''}'),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    if (isFrom) {
                      fromLocationDisplay = suggestion['city'];
                    } else {
                      toLocationDisplay = suggestion['city'];
                    }
                  });
                  Navigator.pop(context);
                },
                noItemsFoundBuilder: (context) => const Padding(
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
                      title: Text(loc['city'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${loc['code'] ?? ''} - ${loc['desc'] ?? ''}'),
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

  Widget _buildTopBarItem(String label, IconData? icon) {
    return TextButton.icon(
      onPressed: () {},
      icon: icon != null ? Icon(icon, size: 16, color: Colors.white) : const SizedBox(),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildLanguageCurrencySelector() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white30),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text('EN', style: GoogleFonts.poppins(color: Colors.white)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'en', child: Text('English')),
        const PopupMenuItem(value: 'hi', child: Text('हिंदी')),
        const PopupMenuItem(value: 'ta', child: Text('தமிழ்')),
      ],
    );
  }

  Widget _fareOption(String label, bool selected, {String? extraText, bool hasExtraSavings = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.blue[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? Colors.blue : Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasExtraSavings)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('EXTRA SAVINGS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)),
            ),
          if (hasExtraSavings) const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87)),
          if (extraText != null) const SizedBox(width: 4),
          if (extraText != null)
            Text(extraText, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _shortcut(String label, IconData icon, {bool hasNew = false}) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[50],
              radius: 28,
              child: Icon(icon, color: Colors.blue, size: 28),
            ),
            if (hasNew)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('new', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 100,
          child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _offerCard(Map<String, String> offer) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: offer['img'] ?? '',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(offer['desc'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(offer['cta'] ?? '', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _collectionCard(Map<String, String> collection) {
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: collection['img'] ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(collection['tag'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Text(
                  collection['title'] ?? '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinkItem(String label, IconData icon, {bool hasNew = false, VoidCallback? onTap, Color iconColor = Colors.blue}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.1),
                radius: 28,
                child: Icon(icon, color: iconColor, size: 28),
              ),
              if (hasNew)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('new', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 100,
            child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = isDarkMode ? ThemeData.dark() : ThemeData.light();

    final appBar = PreferredSize(
          preferredSize: const Size.fromHeight(145),
          child: Column(
            children: [
              Container(
                color: const Color(0xFF1A1A1A),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text('Travelitin', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                    const SizedBox(width: 24),
                    _buildTopBarItem('List Your Property', null),
                    const SizedBox(width: 16),
                    _buildTopBarItem('Introducing myBiz', null),
                    const Spacer(),
                    _buildTopBarItem('My Trips', Icons.airplane_ticket),
                    const SizedBox(width: 16),
                    _buildTopBarItem('Hi $_userName', Icons.person),
                    const SizedBox(width: 16),
                    _buildLanguageCurrencySelector(),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: isDarkMode ? Colors.yellow : Colors.white),
                      onPressed: () => setState(() => isDarkMode = !isDarkMode),
                      tooltip: 'Toggle Dark Mode',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    width: MediaQuery.of(context).size.width * 0.9,
                    constraints: const BoxConstraints(maxWidth: 1100),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(navTabs.length, (i) => GestureDetector(
                          onTap: () => setState(() => navTabIndex = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: navTabIndex == i ? Colors.blue : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(navTabs[i]['icon'], color: navTabIndex == i ? Colors.blue : Colors.grey[600], size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  navTabs[i]['label'],
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontWeight: navTabIndex == i ? FontWeight.bold : FontWeight.w500,
                                    color: navTabIndex == i ? Colors.blue : Colors.grey[800],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
    print("Rendering UI with username: $_userName");
    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(theme.textTheme),
        scaffoldBackgroundColor: isDarkMode ? const Color(0xFF181A20) : const Color(0xFFF7F8FA),
        cardColor: isDarkMode ? const Color(0xFF23262F) : Colors.white,
      ),
      child: Scaffold(
        appBar: appBar,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - appBar.preferredSize.height - MediaQuery.of(context).padding.top),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider('https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1920&q=80'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.2),
                              BlendMode.darken),
                        ),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Where do you want to go, $_userName?",
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
                                  ),
                                ),
                                if (!isFetchingLocation && currentLocation != null && currentLocation!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.10),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(color: Colors.blueGrey.withOpacity(0.22)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on, color: Colors.blue[700], size: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          currentLocation!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            if (travelAlert.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 8.0, right: 40.0),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.orange[200]!, width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.08),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 18),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            travelAlert,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -60),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          constraints: const BoxConstraints(maxWidth: 1100),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(searchTabs.length, (i) => GestureDetector(
                                    onTap: () => setState(() => searchTabIndex = i),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: searchTabIndex == i ? Colors.blue[50] : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: searchTabIndex == i ? Colors.blue : Colors.grey[300]!),
                                      ),
                                      child: Text(
                                        searchTabs[i],
                                        style: TextStyle(
                                          color: searchTabIndex == i ? Colors.blue : Colors.grey[800],
                                          fontWeight: searchTabIndex == i ? FontWeight.bold : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _showLocationSearchSheet(true),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('From', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                            const SizedBox(height: 4),
                                            Text(
                                              fromLocationDisplay ?? 'Select City',
                                              style: TextStyle(
                                                color: fromLocationDisplay != null ? Colors.black : Colors.grey[400],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _showLocationSearchSheet(false),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('To', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                            const SizedBox(height: 4),
                                            Text(
                                              toLocationDisplay ?? 'Select City',
                                              style: TextStyle(
                                                color: toLocationDisplay != null ? Colors.black : Colors.grey[400],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  _fareOption('Economy', true),
                                  _fareOption('Premium Economy', false),
                                  _fareOption('Business', false),
                                  _fareOption('First', false),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('Search Flights', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Offers For You', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(offersTabs.length, (i) => GestureDetector(
                                onTap: () => setState(() => offersTabIndex = i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: offersTabIndex == i ? Colors.blue[50] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: offersTabIndex == i ? Colors.blue : Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    offersTabs[i],
                                    style: TextStyle(
                                      color: offersTabIndex == i ? Colors.blue : Colors.grey[800],
                                      fontWeight: offersTabIndex == i ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                                height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: offers.length,
                              itemBuilder: (context, index) => Container(
                                width: 300,
                                margin: const EdgeInsets.only(right: 16),
                                child: _offerCard(offers[index]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Inspiration for your next trip', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: collections.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _collectionCard(collections[index]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quick Links', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 20.0,
                            runSpacing: 20.0,
                            children: [
                                  _buildQuickLinkItem('Trip Planner', Icons.calendar_today, hasNew: true, iconColor: Colors.orange, onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => TripPlanner()));
                                  }),
                                  _buildQuickLinkItem('Report Scams', Icons.report_problem, hasNew: true, iconColor: Colors.red, onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ScamReportPage()));
                                  }),
                                  _buildQuickLinkItem('Travel Expense', Icons.money, hasNew: true, iconColor: Colors.green, onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => TravelExpense()));
                                  }),
                                  _buildQuickLinkItem('Translate', Icons.translate, hasNew: true, iconColor: Colors.purple, onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => TranslateScreen()));
                                  }),
                                  _buildQuickLinkItem('Travel Chat', Icons.chat, hasNew: true, iconColor: Colors.teal, onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Travelchat()));
                                  }),
                            ],
                          ),
                        ],
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
