import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:thingqbator/home_page.dart';
import 'firebase_options.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatwidgets.dart';
import 'package:go_router/go_router.dart';
class Travelchatee extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Trip Planner',
      theme: ThemeData(
        primaryColor: const Color(0xFF3B82F6),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Travelchat(),
    );
  }
}

class Travelchat extends StatefulWidget {
  const Travelchat({super.key});

  @override
  State<Travelchat> createState() => _TravelchatState();
}

class _TravelchatState extends State<Travelchat> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Chat',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: Color(0xFF1E88E5),
          secondary: Color(0xFF64B5F6),
          surface: Color(0xFFFFFFFF),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Color(0xFF424242),
                displayColor: Color(0xFF424242),
              ),
        ),
        cardTheme: CardTheme(
          color: Color(0xFFFFFFFF),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Color(0xFF1E88E5).withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF1E88E5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF1E88E5).withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF1E88E5)),
          ),
        ),
      ),
      home: LocationChatPage(),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String message;

  const ExpandableText({Key? key, required this.message}) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: isExpanded || widget.message.length <= 100
                  ? widget.message
                  : "${widget.message.substring(0, 100)}...",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
            if (!isExpanded && widget.message.length > 100)
              TextSpan(
                text: " Tap to read more",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        softWrap: true,
      ),
    );
  }
}

class LocationChatPage extends StatefulWidget {
  const LocationChatPage({super.key});

  @override
  _LocationChatPageState createState() => _LocationChatPageState();
}

class _LocationChatPageState extends State<LocationChatPage>
    with TickerProviderStateMixin {
  final TextEditingController messageController = TextEditingController();
  String currentLocation = "";
  String userEmail = "Guest";
  String useraddress = "Unknown Address";
  bool isComposing = true;
  final FocusNode _focusNode = FocusNode();
  static const String _apiKey = '492cdff6b79e46adb5938059495eacc9';

  @override
  void initState() {
    super.initState();

    fetchCurrentLocation();
    fetchUserEmail();
  }

  @override
  void dispose() {
    messageController.removeListener(_handleTextChange);
    messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      isComposing = messageController.text.isNotEmpty;
    });
  }

  String containsPhoneNumber(String text) {
    RegExp phonePattern = RegExp(
        r'\b(?:\+\d{1,3}\s?)?(?:\d{3}|\(\d{3}\))[\s.-]?\d{3}[\s.-]?\d{4}\b');
    RegExp emailPattern =
        RegExp(r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b');
    RegExp urlPattern = RegExp(
        r'\b(?:https?:\/\/|www\.)[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:\/\S*)?\b');

    return text
        .replaceAll(
            RegExp(
                r'\b(?:\+\d{1,3}\s?)?(?:\d{3}|\(\d{3}\))[\s.-]?\d{3}[\s.-]?\d{4}\b'),
            '[Hidden Phone]')
        .replaceAll(
            RegExp(r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b'),
            '[Hidden Email]')
        .replaceAll(
            RegExp(
                r'\b(?:https?:\/\/|www\.)[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:\/\S*)?\b'),
            '[Hidden URL]');
  }

  Future<bool> checkWithPerspectiveAPI(String text) async {
    final apiKey = 'AIzaSyBNs6NdRGkGEAguMheGho25jB0QfA8v0E4';
    final url =
        'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=$apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'comment': {'text': text},
          'languages': ['en'],
          'requestedAttributes': {
            'TOXICITY': {},
            'INSULT': {},
            'IDENTITY_ATTACK': {},
            'PROFANITY': {},
            'THREAT': {},
            'SEXUALLY_EXPLICIT': {}
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final toxicityScore =
            data['attributeScores']['TOXICITY']['summaryScore']['value'] ?? 0.0;
        final identityAttackScore = data['attributeScores']['IDENTITY_ATTACK']
                ['summaryScore']['value'] ??
            0.0;
        final profanityScore = data['attributeScores']['PROFANITY']
                ['summaryScore']['value'] ??
            0.0;
        final threatScore =
            data['attributeScores']['THREAT']['summaryScore']['value'] ?? 0.0;
        final sexuallyExplicitScore = data['attributeScores']
                ['SEXUALLY_EXPLICIT']['summaryScore']['value'] ??
            0.0;
        final insultScore =
            data['attributeScores']['INSULT']['summaryScore']['value'] ?? 0.0;

        return toxicityScore > 0.65 ||
            identityAttackScore > 0.5 ||
            profanityScore > 0.6 ||
            threatScore > 0.45 ||
            sexuallyExplicitScore > 0.25 ||
            insultScore > 0.5;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchCurrentLocation() async {
    try {
      Position position = await _getCurrentLocation();
      await _getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        currentLocation = "Unknown Location";
      });
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
          String stateDistrict = data['address']['state_district'] ?? '';
          String city = data['address']['city'] ??
              data['address']['town'] ??
              data['address']['village'] ??
              'Unknown';
          String state = data['address']['state'] ?? 'Unknown';

          String town = city;
          String localdistrict = data['address']['county'] != null
              ? ", ${data['address']['county']}"
              : '';
          String statedata = data['address']['state'] != null
              ? ", ${data['address']['state']}"
              : '';

          useraddress = town + localdistrict + statedata;

          currentLocation =
              '${stateDistrict.isNotEmpty ? stateDistrict : city}, $state';
        });
      } else {
        throw Exception("Failed to fetch address from Nominatim.");
      }
    } catch (e) {
      setState(() {
        currentLocation = "Unknown Location";
      });
    }
  }

  Future<void> fetchUserEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      setState(() {
        userEmail = user?.displayName ?? "Guest";
      });
    } catch (e) {
      print("Error fetching user email: $e");
    }
  }

  Future<void> sendMessage(
      String message, String featureType, Map<String, dynamic> metadata) async {
    var trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty || currentLocation.isEmpty) return;

    try {
      trimmedMessage = containsPhoneNumber(trimmedMessage);
      bool isPerspectiveViolation =
          await checkWithPerspectiveAPI(trimmedMessage);
      final isViolation = isPerspectiveViolation;
      final moderatedMessage = isViolation
          ? "Message removed for violating Community guidelines"
          : trimmedMessage;

      final chatThreadRef =
          FirebaseFirestore.instance.collection('chats').doc(currentLocation);

      await chatThreadRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'location': currentLocation,
        'initiatedBy': userEmail,
      }, SetOptions(merge: true));

      await chatThreadRef.collection('messages').add({
        'message': moderatedMessage,
        'userEmail': userEmail,
        'address': useraddress,
        'timestamp': FieldValue.serverTimestamp(),
        'isViolation': isViolation,
        'featureType': featureType,
        'featureData': metadata['featureData'], // Ensure correct storage
        'interested': metadata['interested'],
        'interestedCount': metadata['interestedCount'],
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Stream<QuerySnapshot> getMessagesStream() {
    if (currentLocation.isEmpty) {
      return Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(currentLocation)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFF1E88E5).withOpacity(0.01),
                  Color(0xFF1E88E5).withOpacity(0),
                ],
              ),
            ),
          ),
          Icon(
            Icons.location_on,
            color: Color(0xFF1E88E5),
            size: 24,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Travel Chat',
              style: TextStyle(
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              currentLocation,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1E88E5)),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop(); // Go back if possible
            } else {
              context.go('/HomePage'); // Navigate to a fallback route
            }
          },
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getMessagesStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                      ),
                    );
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final data =
                          messages[index].data() as Map<String, dynamic>;
                      final message = data['message'] ?? '';
                      final email = data['userEmail'] ?? 'Unknown Email';
                      final address = data['address'] ?? 'Unknown Address';
                      final isViolation = data['isViolation'] ?? false;
                      final featureType = data['featureType'] ?? 'regular';
                      final featureData = data['featureData'] ?? {};

                      final timestamp = data['timestamp'] != null
                          ? (data['timestamp'] as Timestamp).toDate().toLocal()
                          : null;
                      final formattedTime = timestamp != null
                          ? "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}"
                          : '';
                      final formattedDate = timestamp != null
                          ? "${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year.toString().substring(2)}"
                          : '';

                      final isCurrentUser = email == userEmail;

                      bool isFirstInChain = true;
                      if (index < messages.length - 1) {
                        final prevData =
                            messages[index + 1].data() as Map<String, dynamic>;
                        if (prevData['userEmail'] == email) {
                          isFirstInChain = false;
                        }
                      }
                      if (featureType != 'regular') {
                        return FeatureMessageCard(
                          messageData: data,
                          userEmail: userEmail,
                          onInterested: () =>
                              handleInterested(messages[index].id),
                          isCurrentUser: isCurrentUser,
                        );
                      } else if (!isViolation) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (isFirstInChain && !isCurrentUser)
                                Padding(
                                  padding: EdgeInsets.only(left: 12, bottom: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        email,
                                        style: TextStyle(
                                          color: Color(0xFF1E88E5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        address,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width >
                                          1600
                                      ? MediaQuery.of(context).size.width * 0.50
                                      : MediaQuery.of(context).size.width < 900
                                          ? MediaQuery.of(context).size.width *
                                              0.70
                                          : MediaQuery.of(context).size.width *
                                              (0.50 +
                                                  (1600 -
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width) /
                                                      (1600 - 900) *
                                                      (0.70 - 0.50)),
                                ),
                                margin: EdgeInsets.only(
                                  left: isCurrentUser ? 50 : 12,
                                  right: isCurrentUser ? 12 : 50,
                                  top: 2,
                                  bottom: 2,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ExpandableText(message: message),
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisAlignment: isCurrentUser
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$formattedTime - $formattedDate',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.redAccent,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '$formattedTime - $formattedDate',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: EnhancedMessageInput(
                onSend: (messageText, featureType, metadata) async =>
                    await sendMessage(messageText, featureType, metadata),
                currentLocation: currentLocation,
                userEmail: userEmail,
                userAddress: useraddress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendEnhancedMessage(
      String message, String messageType, Map<String, dynamic> metadata) {
    if (message.isEmpty && messageType == 'regular') return;

    FirebaseFirestore.instance.collection('messages').add({
      'message': message,
      'userEmail': userEmail,
      'address': useraddress,
      'timestamp': FieldValue.serverTimestamp(),
      'location': currentLocation,
      'isViolation': false,
      'messageType': messageType,
      if (metadata.isNotEmpty) ...metadata,
    });
  }

  void handleInterested(String messageId) {
    FirebaseFirestore.instance
        .collection('messages')
        .doc(messageId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final List interested = List.from(data['interested'] ?? []);

        if (interested.contains(userEmail)) {
          interested.remove(userEmail);

          FirebaseFirestore.instance
              .collection('messages')
              .doc(messageId)
              .update({
            'interested': interested,
            'interestedCount': FieldValue.increment(-1),
          });
        } else {
          interested.add(userEmail);

          FirebaseFirestore.instance
              .collection('messages')
              .doc(messageId)
              .update({
            'interested': interested,
            'interestedCount': FieldValue.increment(1),
          });
        }
      }
    });
  }
}
