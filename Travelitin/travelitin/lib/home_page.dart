import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:travelitin/features/travel/screens/TripPlanner.dart';
import 'package:travelitin/editProf.dart';
import 'package:travelitin/features/revenue/screens/revenue.dart';
import 'dart:math';
import 'package:travelitin/features/auth/screens/login_page.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:marquee/marquee.dart';
import 'package:travelitin/allfeedback.dart';
import 'package:go_router/go_router.dart';
import 'package:travelitin/core/constants/routes.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final int _currentTab = 0;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _logout(context);
          },
        ),
        title: const Text(
          'A Safety Guide',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OliveVillage',
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 183, 214, 255)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              _showProfileMenu(context, details.globalPosition);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    BootstrapIcons.list,
                    size: 30.0,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 2.0),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(255, 133, 200, 255).withOpacity(0.9),
                      const Color.fromARGB(255, 235, 120, 255).withOpacity(0.9),
                      const Color.fromARGB(255, 255, 113, 160).withOpacity(0.9),
                    ],
                    stops: [
                      0.0,
                      0.5 + 0.5 * sin(_controller.value * 2 * pi),
                      1.0,
                    ],
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcATop,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              children: <Widget>[
                const GreetingWithImageSlider(),
                const SizedBox(height: 10.0),
                const LocationAlertsWeather(),
                const SizedBox(height: 10.0),
                const ExploreFeaturesCarousel(),
                const SizedBox(height: 10.0),
                const DestinationCarousel(),
                const SizedBox(height: 30.0),
                const Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context, Offset position) async {
    const profileInfo = 'Profile Info';
    const logout = 'Logout';
    const pricing = 'Pricing';
    const feedback = 'feedback';

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem<String>(
          value: profileInfo,
          child: Text(profileInfo),
        ),
        const PopupMenuItem<String>(
          value: pricing,
          child: Text(pricing),
        ),
        const PopupMenuItem<String>(
          value: feedback,
          child: Text(feedback),
        ),
        const PopupMenuItem<String>(
          value: logout,
          child: Text(logout),
        ),
      ],
    );

    switch (selected) {
      case profileInfo:
        context.push(AppRoutes.editProfile);
        break;
      case logout:
        _logout(context);
        break;
      case pricing:
        context.push(AppRoutes.revenue);
        break;
      case feedback:
        context.push(AppRoutes.feed);
        break;
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      context.go(AppRoutes.login);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
          ),
        );
      }
    }
  }
}

class GreetingWithImageSlider extends StatefulWidget {
  const GreetingWithImageSlider({super.key});

  @override
  _GreetingWithImageSliderState createState() =>
      _GreetingWithImageSliderState();
}

class _GreetingWithImageSliderState extends State<GreetingWithImageSlider> {
  final List<String> images = const [
    'assets/carousel/picture1(1).jpg',
    'assets/carousel/picture1(2).jpg',
    'assets/carousel/picture1(3).jpg',
  ];

  String firstName = 'User';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
            isLoading = false;
          });
        } else {
          print("No user data found for email: ${user.email}");
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          isLoading
              ? 'Loading...'
              : 'Hi, $firstName! Welcome back. Where are we going today?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 50),
        CarouselSlider(
          items: images
              .map(
                (image) => ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
              )
              .toList(),
          options: CarouselOptions(
            height: 320.0,
            autoPlay: true,
            enlargeCenterPage: true,
            scrollPhysics: const BouncingScrollPhysics(),
            pageSnapping: true,
            viewportFraction: 0.6,
          ),
        ),
        const SizedBox(height: 100.0),
      ],
    );
  }
}

class AlertDetailsPage extends StatelessWidget {
  final String alertMessage;

  const AlertDetailsPage({super.key, required this.alertMessage});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Travel Alert Details",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Card(
                    elevation: 6,
                    shadowColor: Colors.blueGrey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // Future Expansion - Can add interactivity if needed
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: MarkdownBody(
                          data: alertMessage,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LocationAlertsWeather extends StatefulWidget {
  const LocationAlertsWeather({super.key});

  @override
  _LocationAlertsWeatherState createState() => _LocationAlertsWeatherState();
}

class _LocationAlertsWeatherState extends State<LocationAlertsWeather>
    with SingleTickerProviderStateMixin {
  String city = 'Fetching...';
  String state = '';
  String district = '';
  String weatherDescription = 'Loading...';
  IconData weatherIcon = Icons.not_listed_location_sharp;
  Color iconColor = Colors.grey;
  bool isLoading = true;
  String alertMessage = "No alerts available";
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        isLoading = true;
      });

      await _fetchLocationAndWeather();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Initialization error: $e");
      setState(() {
        isLoading = false;
        alertMessage = "Error initializing data.";
      });
    }
  }

  Future<void> _fetchLocationAndWeather() async {
    try {
      Position position = await _getCurrentLocation();
      await _getAddressFromCoordinates(position.latitude, position.longitude);
      await _fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      print("Error in location or weather fetching: $e");
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Location services are disabled.");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    const nominatimURL = "https://nominatim.openstreetmap.org/reverse";
    final url = Uri.parse(
        '$nominatimURL?format=json&lat=$latitude&lon=$longitude&accept-language=en');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          city = data['address']['city'] ??
              data['address']['town'] ??
              data['address']['village'] ??
              'Unknown';
          district = data['address']['county'] != null
              ? ", ${data['address']['county']}"
              : '';
          state = data['address']['state'] != null
              ? ", ${data['address']['state']}"
              : '';
        });

        await _fetchAlerts("$city$district$state");
      } else {
        throw Exception("Failed to fetch address from Nominatim.");
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    final apiKey = '2c46c3bba90211c0e18241f31dd52c79';
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=en');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherDescription = data['weather'][0]['description'];
          String iconCode = data['weather'][0]['icon'];
          weatherIcon = _getWeatherIcon(iconCode);
          iconColor = _getIconColor(iconCode);
        });
      } else {
        throw Exception("Failed to fetch weather.");
      }
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  Future<void> _fetchAlerts(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://antonioroger.pythonanywhere.com/scrape?city=$cityName"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          alertMessage = data['content'] ?? "No alerts available.";
        });
      } else {
        throw Exception("Failed to fetch alerts: ${response.body}");
      }
    } catch (e) {
      print("Error fetching alerts: $e");
      setState(() {
        alertMessage = 'Unable to fetch alerts.';
      });
    }
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return Icons.wb_sunny;
      case '02d':
        return Icons.cloud_queue;
      case '03d':
        return Icons.cloud;
      case '09d':
        return Icons.grain;
      case '10d':
        return Icons.beach_access;
      case '11d':
        return Icons.flash_on;
      case '13d':
        return Icons.ac_unit;
      case '50d':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color _getIconColor(String iconCode) {
    switch (iconCode) {
      case '01d':
        return Colors.orange;
      case '02d':
        return Colors.lightBlueAccent;
      case '03d':
        return Colors.grey;
      case '09d':
        return Colors.blueGrey;
      case '10d':
        return Colors.blue;
      case '11d':
        return Colors.yellowAccent;
      case '13d':
        return Colors.white;
      case '50d':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 700;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: isSmallScreen
                ? Column(
                    children: [
                      // First Box
                      Container(
                        width: screenWidth * 0.95,
                        height: 200,
                        padding: EdgeInsets.all(isSmallScreen
                            ? 12.0
                            : 20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final textSize = _textSize(
                                    city + district + state,
                                    const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold));
                                return textSize.width > constraints.maxWidth
                                    ? SizedBox(
                                        height: 30,
                                        child: Marquee(
                                          text: city + district + state,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          scrollAxis: Axis.horizontal,
                                          blankSpace: 20.0,
                                          velocity: 50.0,
                                          startPadding: 10.0,
                                          accelerationDuration:
                                              const Duration(milliseconds: 800),
                                          accelerationCurve: Curves.linear,
                                          decelerationDuration:
                                              const Duration(milliseconds: 500),
                                          decelerationCurve: Curves.easeOut,
                                        ),
                                      )
                                    : Text(
                                        city + district + state,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                              },
                            ),
                            Icon(weatherIcon, color: iconColor, size: 70),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final textSize = _textSize(weatherDescription,
                                    const TextStyle(fontSize: 20));
                                return textSize.width > constraints.maxWidth
                                    ? SizedBox(
                                        height: 30,
                                        child: Marquee(
                                          text: weatherDescription,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          scrollAxis: Axis.horizontal,
                                          blankSpace: 20.0,
                                          velocity: 20.0,
                                          startPadding: 10.0,
                                          accelerationDuration:
                                              const Duration(seconds: 1),
                                          accelerationCurve: Curves.linear,
                                          decelerationDuration:
                                              const Duration(milliseconds: 500),
                                          decelerationCurve: Curves.easeOut,
                                        ),
                                      )
                                    : Text(
                                        weatherDescription,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Second Box
                      Container(
                        width: screenWidth * 0.95,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlertDetailsPage(
                                      alertMessage: alertMessage),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(isSmallScreen
                                  ? 14.0
                                  : 26.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.red[700],
                                        size: 34,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Travel Alerts',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[700],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final cleanAlertMessage =
                                            alertMessage.replaceAll('\n', ' ');
                                        final span = TextSpan(
                                          text: cleanAlertMessage,
                                          style: const TextStyle(
                                              fontSize: 14, height: 1.5),
                                        );

                                        final tp = TextPainter(
                                          text: span,
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.ltr,
                                          maxLines: 3,
                                        )..layout(
                                            maxWidth: constraints.maxWidth);

                                        return tp.didExceedMaxLines
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      cleanAlertMessage,
                                                      style: const TextStyle(
                                                          fontSize: 14.7,
                                                          height: 1.6),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 7.0),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                AlertDetailsPage(
                                                                    alertMessage:
                                                                        alertMessage),
                                                          ),
                                                        );
                                                      },
                                                      style: TextButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.0),
                                                        ),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 12.0,
                                                                horizontal:
                                                                    20.0),
                                                      ),
                                                      child: const Text(
                                                        "Tap to view more",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight
                                                              .bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                cleanAlertMessage,
                                                style: const TextStyle(
                                                    fontSize: 14, height: 1.5),
                                                textAlign: TextAlign.center,
                                              );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 200,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final textSize = _textSize(
                                      city + district + state,
                                      const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold));
                                  return textSize.width > constraints.maxWidth
                                      ? SizedBox(
                                          height: 30,
                                          child: Marquee(
                                            text: city + district + state,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            scrollAxis: Axis.horizontal,
                                            blankSpace: 20.0,
                                            velocity: 50.0,
                                            startPadding: 10.0,
                                            accelerationDuration:
                                                const Duration(milliseconds: 800),
                                            accelerationCurve: Curves.linear,
                                            decelerationDuration:
                                                const Duration(milliseconds: 500),
                                            decelerationCurve: Curves.easeOut,
                                          ),
                                        )
                                      : Text(
                                          city + district + state,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                },
                              ),
                              Icon(weatherIcon, color: iconColor, size: 70),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final textSize = _textSize(weatherDescription,
                                      const TextStyle(fontSize: 20));
                                  return textSize.width > constraints.maxWidth
                                      ? SizedBox(
                                          height: 30,
                                          child: Marquee(
                                            text: weatherDescription,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            scrollAxis: Axis.horizontal,
                                            blankSpace: 20.0,
                                            velocity: 20.0,
                                            startPadding: 10.0,
                                            accelerationDuration:
                                                const Duration(seconds: 1),
                                            accelerationCurve: Curves.linear,
                                            decelerationDuration:
                                                const Duration(milliseconds: 500),
                                            decelerationCurve: Curves.easeOut,
                                          ),
                                        )
                                      : Text(
                                          weatherDescription,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.0),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlertDetailsPage(
                                        alertMessage: alertMessage),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(26.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.red[700],
                                          size: 34,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Travel Alerts',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[700],
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Expanded(
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final cleanAlertMessage = alertMessage
                                              .replaceAll('\n', ' ');
                                          final span = TextSpan(
                                            text: cleanAlertMessage,
                                            style: const TextStyle(
                                                fontSize: 14, height: 1.5),
                                          );

                                          final tp = TextPainter(
                                            text: span,
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.ltr,
                                            maxLines: 3,
                                          )..layout(
                                              maxWidth: constraints.maxWidth);

                                          return tp.didExceedMaxLines
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        cleanAlertMessage,
                                                        style: const TextStyle(
                                                            fontSize: 14.7,
                                                            height: 1.6),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 7.0),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AlertDetailsPage(
                                                                      alertMessage:
                                                                          alertMessage),
                                                            ),
                                                          );
                                                        },
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 12.0,
                                                                  horizontal:
                                                                      20.0),
                                                        ),
                                                        child: const Text(
                                                          "Tap to view more",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  cleanAlertMessage,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      height: 1.5),
                                                  textAlign: TextAlign.center,
                                                );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}

class ExploreFeaturesCarousel extends StatefulWidget {
  const ExploreFeaturesCarousel({super.key});

  @override
  State<ExploreFeaturesCarousel> createState() =>
      _ExploreFeaturesCarouselState();
}

class _ExploreFeaturesCarouselState extends State<ExploreFeaturesCarousel>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> features = const [
    const {
      'icon': Icons.public,
      'label': 'Explore',
      'route': '/Explore',
      'color': const Color(0xFF2196F3),
      'gradient': const [const Color(0xFF2196F3), const Color(0xFF64B5F6)]
    },
    const {
      'icon': Icons.map,
      'label': 'Trip Planner',
      'route': '/Planner',
      'color': const Color(0xFF4CAF50),
      'gradient': const [const Color(0xFF4CAF50), const Color(0xFF81C784)]
    },
    const {
      'icon': Icons.report,
      'label': 'Report Scams',
      'route': '/report_scam',
      'color': const Color(0xFFF44336),
      'gradient': const [const Color(0xFFF44336), const Color(0xFFE57373)]
    },
    const {
      'icon': Icons.monetization_on,
      'label': 'Travel Expense',
      'route': '/travel_exp',
      'color': const Color(0xFFFF9800),
      'gradient': const [const Color(0xFFFF9800), const Color(0xFFFFB74D)]
    },
    const {
      'icon': Icons.translate,
      'label': 'Translate',
      'route': '/translate',
      'color': const Color(0xFF9C27B0),
      'gradient': const [const Color(0xFF9C27B0), const Color(0xFFBA68C8)]
    },
    const {
      'icon': Icons.chat,
      'label': 'Travel Chat',
      'route': '/Travel',
      'color': const Color(0xFFFF5722),
      'gradient': const [const Color(0xFFFF5722), const Color(0xFFFF7043)]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40.0),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16.0,
                runSpacing: 16.0,
                children: features.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final feature = entry.value;

                  return ExploreFeatureCard(
                    feature: feature,
                    onCardTap: () => _onCardTap(index),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        );
      },
    );
  }

  void _onCardTap(int index) {
    Future.delayed(const Duration(milliseconds: 300), () {
      context.push(features[index]['route']);
    });
  }
}

class ExploreFeatureCard extends StatefulWidget {
  final Map<String, dynamic> feature;
  final VoidCallback onCardTap;

  const ExploreFeatureCard({
    required this.feature,
    required this.onCardTap,
    super.key,
  });

  @override
  State<ExploreFeatureCard> createState() => _ExploreFeatureCardState();
}

class _ExploreFeatureCardState extends State<ExploreFeatureCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _iconController;
  late Animation<double> _cardAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _cardAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeInOut,
      ),
    );

    _iconAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onCardTap();
        _cardController.forward().then((_) {
          _cardController.reverse();
        });
        _iconController.forward().then((_) {
          _iconController.reverse();
        });
      },
      child: MouseRegion(
        onEnter: (_) {
          _cardController.forward();
          _iconController.forward();
        },
        onExit: (_) {
          _cardController.reverse();
          _iconController.reverse();
        },
        child: ScaleTransition(
          scale: _cardAnimation,
          child: SizedBox(
            width: 160.0,
            child: Card(
              elevation: 8,
              shadowColor: widget.feature['color'].withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.feature['gradient'][0].withOpacity(0.1),
                      widget.feature['gradient'][1].withOpacity(0.2),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _iconAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.feature['gradient'][0].withOpacity(0.2),
                              widget.feature['gradient'][1].withOpacity(0.3),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.feature['color'].withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.feature['icon'],
                          size: 48.0,
                          color: widget.feature['color'],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      widget.feature['label'],
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: widget.feature['color'].withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DestinationCarousel extends StatelessWidget {
  final List<Map<String, String>> destinations = const [
    const {'image': 'assets/carousel/picture1(4).jpg', 'name': 'London, UK'},
    const {'image': 'assets/carousel/picture1(5).jpg', 'name': 'Sydney, Australia'},
    const {'image': 'assets/carousel/picture1(6).jpg', 'name': 'Berlin, Germany'},
    const {'image': 'assets/carousel/picture1(4).jpg', 'name': 'Delhi, India'},
    const {'image': 'assets/carousel/picture1(5).jpg', 'name': 'Mumbai, India'},
    const {'image': 'assets/carousel/picture1(6).jpg', 'name': 'Toronto, Canada'},
    const {'image': 'assets/carousel/picture1(4).jpg', 'name': 'Bengaluru, India'},
    const {'image': 'assets/carousel/picture1(5).jpg', 'name': 'Kolkata, India'},
    const {
      'image': 'assets/carousel/picture1(6).jpg',
      'name': 'Vancouver, Canada',
    },
  ];

  const DestinationCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          child: Text(
            "Frequently Visited Places",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 48.0),
          width: MediaQuery.of(context).size.width * 0.6,
          height: 2.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9.0),
          ),
        ),
        Center(
          child: SizedBox(
            height: 250.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: destinations.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelPlannerPage(
                          cityName: destinations[index]['name']!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    width: 300.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: const Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.asset(
                            destinations[index]['image']!,
                            height: 250.0,
                            width: 300.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              destinations[index]['name']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class TravelPlannerPage extends StatefulWidget {
  final String cityName;

  const TravelPlannerPage({super.key, required this.cityName});

  @override
  _TravelPlannerPageState createState() => _TravelPlannerPageState();
}

class _TravelPlannerPageState extends State<TravelPlannerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cityImages = const {
      'London, UK': 'assets/carousel/picture1(4).jpg',
      'Sydney, Australia': 'assets/carousel/picture1(5).jpg',
      'Berlin, Germany': 'assets/carousel/picture1(6).jpg',
      'Delhi, India': 'assets/carousel/picture1(4).jpg',
      'Mumbai, India': 'assets/carousel/picture1(5).jpg',
      'Toronto, Canada': 'assets/carousel/picture1(6).jpg',
      'Bengaluru, India': 'assets/carousel/picture1(4).jpg',
      'Kolkata, India': 'assets/carousel/picture1(5).jpg',
      'Rio de Janeiro, Brazil': 'assets/carousel/picture1(6).jpg',
    };

    final imagePath = cityImages[widget.cityName] ?? 'assets/default_image.jpg';

    return Scaffold(
      appBar: AppBar(title: const Text('Popular Destinations')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Frequently Visited Places',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Great Choice! ${widget.cityName} it is this time! Plan your trip here.',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripPlanner(
                      locationData: {
                        'destination': widget.cityName,
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                shadowColor: Colors.black54,
              ),
              child: const Text('Start Planning'),
            ),
          ],
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  void _sendEmail() async {
    const email = 'mailto:asafetyguide@gmail.com';
    if (await canLaunch(email)) {
      await launch(email);
    } else {
      throw 'Could not launch $email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50.0),
          Container(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 183, 214, 255),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Made by : Gomathi Manisha , Antonio Roger, Ravula Akshith, Raghuram Sekar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.email),
                        iconSize: 28.0,
                        onPressed: _sendEmail,
                      ),
                      IconButton(
                        icon: const Icon(BootstrapIcons.instagram),
                        iconSize: 28.0,
                        onPressed: () {
                          _launchURL(
                              'https://www.instagram.com/a_safety_guide/profilecard/?igsh=Nnd1YnR1NnZnM2U4');
                        },
                      ),
                      IconButton(
                        icon: const Icon(BootstrapIcons.youtube),
                        iconSize: 28.0,
                        onPressed: () {
                          _launchURL(
                              'https://www.youtube.com/@gomathimanishaa');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30.0),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
