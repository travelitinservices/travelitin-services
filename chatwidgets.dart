import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnhancedMessageInput extends StatefulWidget {
  final Future<void> Function(String, String, Map<String, dynamic>) onSend; 
  final String currentLocation;
  final String userEmail;
  final String userAddress;

  const EnhancedMessageInput({
    Key? key,
    required this.onSend,
    required this.currentLocation,
    required this.userEmail,
    required this.userAddress,
  }) : super(key: key);

  @override
  _EnhancedMessageInputState createState() => _EnhancedMessageInputState();
}

class _EnhancedMessageInputState extends State<EnhancedMessageInput> {
  final TextEditingController messageController = TextEditingController();
  bool isComposing = false;
  String selectedFeature = 'regular'; 
  bool showFeaturePanel = false;

  final List<Map<String, dynamic>> featureOptions = [
    {
      'id': 'regular',
      'name': 'Regular Message',
      'icon': Icons.message,
      'color': Color(0xFF3F51B5),
    },
    {
      'id': 'ridepool',
      'name': 'Ride Pool',
      'icon': Icons.directions_car,
      'color': Color(0xFF4CAF50),
      'fields': [
        {'name': 'origin', 'label': 'From', 'type': 'text'},
        {'name': 'destination', 'label': 'To', 'type': 'text'},
        {'name': 'date', 'label': 'Date', 'type': 'date'},
        {'name': 'seats', 'label': 'Available Seats', 'type': 'number'},
        {'name': 'contribution', 'label': 'Cost Sharing (optional)', 'type': 'text'},
      ],
    },
    {
      'id': 'sidequest',
      'name': 'Side Quest',
      'icon': Icons.explore,
      'color': Color(0xFFFF9800),
      'fields': [
        {'name': 'activity', 'label': 'Adventure Type', 'type': 'text'},
        {'name': 'duration', 'label': 'Estimated Duration', 'type': 'text'},
        {'name': 'difficulty', 'label': 'Difficulty Level', 'type': 'dropdown', 'options': ['Easy', 'Moderate', 'Challenging']},
        {'name': 'meetingPoint', 'label': 'Meeting Point', 'type': 'text'},
        {'name': 'items', 'label': 'What to Bring', 'type': 'text'},
      ],
    },
    {
      'id': 'detour',
      'name': 'Detour',
      'icon': Icons.alt_route,
      'color': Color(0xFF9C27B0),
      'fields': [
        {'name': 'place', 'label': 'Hidden Gem Name', 'type': 'text'},
        {'name': 'distance', 'label': 'Distance from Main Route', 'type': 'text'},
        {'name': 'type', 'label': 'Type of Place', 'type': 'dropdown', 'options': ['Scenic', 'Historical', 'Cultural', 'Culinary', 'Adventure']},
        {'name': 'timeNeeded', 'label': 'Time Required', 'type': 'text'},
        {'name': 'worthIt', 'label': 'Worth It Rating (1-5)', 'type': 'number'},
      ],
    },
    {
      'id': 'grouptravel',
      'name': 'Group Travel',
      'icon': Icons.groups,
      'color': Color(0xFF2196F3),
      'fields': [
        {'name': 'itinerary', 'label': 'Itinerary Overview', 'type': 'text'},
        {'name': 'dateRange', 'label': 'Date Range', 'type': 'text'},
        {'name': 'travelStyle', 'label': 'Travel Style', 'type': 'dropdown', 'options': ['Budget', 'Mid-range', 'Luxury', 'Adventure', 'Cultural']},
        {'name': 'groupSize', 'label': 'Max Group Size', 'type': 'number'},
        {'name': 'interests', 'label': 'Shared Interests', 'type': 'text'},
      ],
    },
    {
      'id': 'localguide',
      'name': 'Local Guide',
      'icon': Icons.tour,
      'color': Color(0xFFFF5722),
      'fields': [
        {'name': 'questions', 'label': 'What would you like to know?', 'type': 'text'},
        {'name': 'timeNeeded', 'label': 'Time Needed', 'type': 'dropdown', 'options': ['Quick Tips', 'Few Hours', 'Half Day', 'Full Day']},
        {'name': 'languages', 'label': 'Preferred Languages', 'type': 'text'},
      ],
    },
    {
      'id': 'safetybuddy',
      'name': 'Safety Buddy',
      'icon': Icons.security,
      'color': Color(0xFF795548),
      'fields': [
        {'name': 'activity', 'label': 'Activity Type', 'type': 'text'},
        {'name': 'duration', 'label': 'Duration Needed', 'type': 'text'},
        {'name': 'genderPref', 'label': 'Gender Preference', 'type': 'dropdown', 'options': ['Any', 'Female', 'Male', 'Non-binary']},
      ],
    },
  ];

  Map<String, dynamic> featureData = {};

  @override
  void initState() {
    super.initState();
    messageController.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    messageController.removeListener(_handleTextChange);
    messageController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      isComposing = messageController.text.isNotEmpty;
    });
  }

  void _toggleFeaturePanel() {
    setState(() {
      showFeaturePanel = !showFeaturePanel;
    });
  }

  void _selectFeature(String featureId) {
    setState(() {
      selectedFeature = featureId;
      featureData = {};
      showFeaturePanel = false;
    });
  }

  void _updateFeatureData(String fieldName, dynamic value) {
    setState(() {
      featureData[fieldName] = value;
    });
  }

  bool _canSubmitFeature() {
    if (selectedFeature == 'regular') {
      return messageController.text.isNotEmpty;
    }

    final feature = featureOptions.firstWhere((f) => f['id'] == selectedFeature);
    

    if (feature.containsKey('fields')) {
      for (var field in feature['fields']) {
        if (!featureData.containsKey(field['name']) || featureData[field['name']] == null || featureData[field['name']].toString().isEmpty) {
          return false;
        }
      }
    }
    
    return true;
  }

void _sendMessage() async {
  String messageText = messageController.text.trim();


  if (selectedFeature == 'regular' && messageText.isEmpty) return;

  Map<String, dynamic> metadata = {
    'featureType': selectedFeature,
    'featureData': featureData,
    'userEmail': widget.userEmail,
    'interested': [],
    'interestedCount': 0,
  };


  if (selectedFeature != 'regular' && messageText.isEmpty) {
    messageText = "🔹 @ ${widget.userEmail.replaceAll('_', ' ').toUpperCase()} POSTED";
  }

  await widget.onSend(messageText, selectedFeature, metadata);


  setState(() {
    messageController.clear();
    featureData = {};
    selectedFeature = 'regular';
    isComposing = false;
  });
}



  String _formatFeatureMessage(Map<String, dynamic> feature, Map<String, dynamic> data) {

    switch (feature['id']) {
      case 'ridepool':
        return "🚗 Ride Pool: ${data['origin']} to ${data['destination']} on ${data['date']}";
      case 'sidequest':
        return "🔍 Side Quest: ${data['activity']} (${data['difficulty']}) - ${data['duration']}";
      case 'detour':
        return "🔄 Detour: ${data['place']} - ${data['type']} - ${data['distance']} from route";
      case 'grouptravel':
        return "👥 Group Travel: ${data['itinerary']} - ${data['dateRange']}";
      case 'localguide':
        return "🧭 Local Guide Request: ${data['questions']}";
      case 'safetybuddy':
        return "🛡️ Safety Buddy: ${data['activity']} - ${data['duration']}";
      default:
        return messageController.text;
    }
  }

  Widget _buildFeatureFields() {
    final feature = featureOptions.firstWhere((f) => f['id'] == selectedFeature);
    
    if (selectedFeature == 'regular' || !feature.containsKey('fields')) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: feature['color'].withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(feature['icon'], color: feature['color']),
              SizedBox(width: 8),
              Text(
                feature['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: feature['color'],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Divider(),
          ...feature['fields'].map<Widget>((field) {
            switch (field['type']) {
              case 'text':
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: field['label'],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onChanged: (value) => _updateFeatureData(field['name'], value),
                  ),
                );
              case 'number':
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: field['label'],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateFeatureData(field['name'], value),
                  ),
                );
              case 'date':
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: field['label'],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) {
                        final formattedDate = "${date.day}/${date.month}/${date.year}";
                        setState(() {
                          featureData[field['name']] = formattedDate;
                        });

                        (context as Element).markNeedsBuild();
                      }
                    },
                    controller: TextEditingController(
                      text: featureData[field['name']] ?? '',
                    ),
                  ),
                );
              case 'dropdown':
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: field['label'],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: (field['options'] as List).map<DropdownMenuItem<String>>((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) => _updateFeatureData(field['name'], value),
                  ),
                );
              default:
                return SizedBox.shrink();
            }
          }).toList(),
        ],
      ),
    );
  }
@override
Widget build(BuildContext context) {
  final selectedFeatureInfo =
      featureOptions.firstWhere((f) => f['id'] == selectedFeature);

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [

      AnimatedContainer(
  duration: Duration(milliseconds: 17),
  height: showFeaturePanel ? 100 : 0,
  child: showFeaturePanel
      ? Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: ListView(
            shrinkWrap: true, 
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: featureOptions.map((feature) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: InkWell(
                        onTap: () => _selectFeature(feature['id']),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: feature['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: feature['color'],
                                  width: selectedFeature == feature['id'] ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                feature['icon'],
                                color: feature['color'],
                                size: 24,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              feature['name'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selectedFeature == feature['id']
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            : SizedBox.shrink(),
      ),

      if (selectedFeature != 'regular')
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: _buildFeatureFields(),
        ),

      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Feature selector button
              IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: selectedFeatureInfo['color'],
                      size: 28,
                    ),
                    if (selectedFeature != 'regular')
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          selectedFeatureInfo['icon'],
                          size: 12,
                          color: selectedFeatureInfo['color'],
                        ),
                      ),
                  ],
                ),
                onPressed: _toggleFeaturePanel,
              ),

              // Message text field
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 120.0,
                  ),
                  child: TextField(
                    controller: messageController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      color: Color(0xFF424242),
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: selectedFeature == 'regular'
                          ? 'Connect with fellow travelers...'
                          : 'Add a description for your ${selectedFeatureInfo['name']}...',
                      hintStyle: TextStyle(color: Color(0xFF757575)),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isCollapsed: true,
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {
                        isComposing = text.trim().isNotEmpty;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(width: 12),

              // Send button
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _canSubmitFeature() ? _sendMessage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedFeatureInfo['color'],
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(60, 48),
                  ),
                  child: Text('Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
}

class FeatureMessageCard extends StatelessWidget {
  final Map<String, dynamic> messageData;
  final String userEmail;
  final Function onInterested;
  final bool isCurrentUser;

  const FeatureMessageCard({
    Key? key,
    required this.messageData,
    required this.userEmail,
    required this.onInterested,
    required this.isCurrentUser,
  }) : super(key: key);

  bool _hasUserShownInterest() {
    final List interested = messageData['interested'] ?? [];
    return interested.contains(userEmail);
  }

  Widget _buildFeatureSpecificContent() {
    final String featureType = messageData['featureType'] ?? 'regular';
    final Map<String, dynamic> featureData = messageData['featureData'] ?? {};
    
    switch (featureType) {
      case 'ridepool':
        return _buildRidepoolContent(featureData);
      case 'sidequest':
        return _buildSidequestContent(featureData);
      case 'detour':
        return _buildDetourContent(featureData);
      case 'grouptravel':
        return _buildGroupTravelContent(featureData);
      case 'localguide':
        return _buildLocalGuideContent(featureData);
      case 'safetybuddy':
        return _buildSafetyBuddyContent(featureData);
      default:
        return Text(
          messageData['message'] ?? '',
          style: TextStyle(fontSize: 15),
        );
    }
  }

  Widget _buildRidepoolContent(Map<String, dynamic> featureData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJourneyCard(
          from: featureData['origin'] ?? 'Not specified',
          to: featureData['destination'] ?? 'Not specified',
          date: featureData['date'] ?? 'Not specified',
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildInfoChip(
              Icons.airline_seat_recline_normal,
              "${featureData['seats'] ?? '?'} seats",
              Color(0xFF4CAF50).withOpacity(0.1),
            ),
            SizedBox(width: 8),
            if (featureData['contribution'] != null && featureData['contribution'].isNotEmpty)
              _buildInfoChip(
                Icons.attach_money,
                featureData['contribution'],
                Color(0xFF4CAF50).withOpacity(0.1),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSidequestContent(Map<String, dynamic> featureData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFF9800).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                featureData['activity'] ?? 'Adventure',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFFF9800),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.black54),
                  SizedBox(width: 4),
                  Text(
                    featureData['duration'] ?? 'Not specified',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.trending_up, size: 16, color: Colors.black54),
                  SizedBox(width: 4),
                  Text(
                    featureData['difficulty'] ?? 'Not specified',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                Icons.meeting_room,
                "Meeting Point",
                featureData['meetingPoint'] ?? 'Not specified',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                Icons.backpack,
                "Bring",
                featureData['items'] ?? 'Not specified',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetourContent(Map<String, dynamic> featureData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      featureData['place'] ?? 'Hidden Gem',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF9C27B0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      featureData['type'] ?? 'Amazing Place',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoChip(
              Icons.social_distance,
              featureData['distance'] ?? 'Unknown',
              Color(0xFF9C27B0).withOpacity(0.1),
            ),
            _buildInfoChip(
              Icons.timer,
              featureData['timeNeeded'] ?? 'Unknown',
              Color(0xFF9C27B0).withOpacity(0.1),
            ),
            _buildInfoChip(
              Icons.star,
              "${featureData['worthIt'] ?? '?'}/5",
              Color(0xFF9C27B0).withOpacity(0.1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupTravelContent(Map<String, dynamic> featureData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.map, color: Color(0xFF2196F3)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      featureData['itinerary'] ?? 'Not specified',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                featureData['dateRange'] ?? 'Dates not specified',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                Icons.style,
                "Travel Style",
                featureData['travelStyle'] ?? 'Not specified',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                Icons.group,
                "Group Size",
                featureData['groupSize'] ?? 'Not specified',
              ),
            ),
          ],
        ),
        if (featureData['interests'] != null && featureData['interests'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildInfoCard(
              Icons.interests,
              "Interests",
              featureData['interests'],
            ),
          ),
      ],
    );
  }

  Widget _buildLocalGuideContent(Map<String, dynamic> featureData) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFF5722).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "I need help with:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            featureData['questions'] ?? 'Not specified',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.timer,
                featureData['timeNeeded'] ?? 'Unknown',
                Color(0xFFFF5722).withOpacity(0.1),
              ),
              SizedBox(width: 12),
              _buildInfoChip(
                Icons.language,
                featureData['languages'] ?? 'Any',
                Color(0xFFFF5722).withOpacity(0.1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBuddyContent(Map<String, dynamic> featureData) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF795548).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Color(0xFF795548)),
              SizedBox(width: 8),
              Text(
                "Safety Buddy for:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            featureData['activity'] ?? 'Not specified',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.timelapse,
                featureData['duration'] ?? 'Unknown',
                Color(0xFF795548).withOpacity(0.1),
              ),
              SizedBox(width: 12),
              _buildInfoChip(
                Icons.person,
                "Prefer: ${featureData['genderPref'] ?? 'Any'}",
                Color(0xFF795548).withOpacity(0.1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyCard({required String from, required String to, required String date}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                child: Column(
                  children: [
                    Icon(Icons.circle_outlined, size: 14, color: Color(0xFF4CAF50)),
                    Container(
                      width: 2,
                      height: 20,
                      color: Color(0xFF4CAF50),
                    ),
                    Icon(Icons.location_on, size: 14, color: Color(0xFF4CAF50)),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      from,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      to,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.black54),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getFeatureColor() {
    switch (messageData['featureType']) {
      case 'ridepool': return Color(0xFF4CAF50);
      case 'sidequest': return Color(0xFFFF9800);
      case 'detour': return Color(0xFF9C27B0);
      case 'grouptravel': return Color(0xFF2196F3);
      case 'localguide': return Color(0xFFFF5722);
      case 'safetybuddy': return Color(0xFF795548);
      default: return Color(0xFF3F51B5);
    }
  }

  IconData _getFeatureIcon() {
    switch (messageData['featureType']) {
      case 'ridepool': return Icons.directions_car;
      case 'sidequest': return Icons.explore;
      case 'detour': return Icons.alt_route;
      case 'grouptravel': return Icons.groups;
      case 'localguide': return Icons.tour;
      case 'safetybuddy': return Icons.security;
      default: return Icons.message;
    }
  }

  String _getFeatureTitle() {
    switch (messageData['featureType']) {
      case 'ridepool': return "Ride Pool";
      case 'sidequest': return "Side Quest";
      case 'detour': return "Detour";
      case 'grouptravel': return "Group Travel";
      case 'localguide': return "Local Guide Request";
      case 'safetybuddy': return "Safety Buddy";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String featureType = messageData['featureType'] ?? 'regular';
    if (featureType == 'regular') {
      return SizedBox.shrink();
    }

    final bool hasShownInterest = _hasUserShownInterest();
    final int interestedCount = messageData['interestedCount'] ?? 0;
    final timestamp = messageData['timestamp'] != null
        ? (messageData['timestamp'] as Timestamp).toDate().toLocal()
        : DateTime.now();
    final String formattedTime = "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    final String formattedDate = "${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year.toString().substring(2)}";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender info for non-current user
          if (!isCurrentUser)
            Padding(
              padding: EdgeInsets.only(left: 12, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageData['userName'] ?? messageData['userEmail'] ?? 'Anonymous',
                    style: TextStyle(
                      color: Color(0xFF1E88E5),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    messageData['userLocation'] ?? 'Unknown location',
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
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getFeatureColor().withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: _getFeatureColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Feature header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _getFeatureColor().withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFeatureIcon(),
                        color: _getFeatureColor(),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _getFeatureTitle(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _getFeatureColor(),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "$formattedTime - $formattedDate",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Message content
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (messageData['message'] != null && messageData['message'].isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            messageData['message'],
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      

                      _buildFeatureSpecificContent(),
                      
                      SizedBox(height: 12),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Interest counter
                          Text(
                            "$interestedCount ${interestedCount == 1 ? 'person' : 'people'} interested",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          
                          // Interest button (don't show for own messages)
                          if (!isCurrentUser)
                            ElevatedButton.icon(
                              onPressed: () => onInterested(),
                              icon: Icon(
                                hasShownInterest ? Icons.check_circle : Icons.add_circle_outline,
                                size: 18,
                              ),
                              label: Text(
                                hasShownInterest ? "Interested" : "I'm Interested",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasShownInterest
                                    ? Colors.grey.shade200
                                    : _getFeatureColor().withOpacity(0.8),
                                foregroundColor: hasShownInterest
                                    ? _getFeatureColor()
                                    : Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
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
  }
}