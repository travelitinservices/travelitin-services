import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false; // Track submission state
  double _rating = 3;
  bool _showFireworks = false;
  bool _showSadAnimation = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleRatingChange(double value) {
    setState(() {
      _rating = value;
      _showFireworks = value == 5;
      _showSadAnimation = value < 2;
    });

    if (_showFireworks || _showSadAnimation) {
      Timer(Duration(seconds: 10), () {
        setState(() {
          _showFireworks = false;
          _showSadAnimation = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Feedback',
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 🎇 Fireworks Animation (Full-Screen)
          if (_showFireworks)
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  children: List.generate(30, (index) {
                    return Positioned(
                      left:
                          MediaQuery.of(context).size.width * (index % 10) / 10,
                      top: MediaQuery.of(context).size.height * (index % 5) / 5,
                      child: Icon(
                        Icons.circle,
                        size: 12 + (index % 8).toDouble() * 2,
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .move(
                            begin: Offset(0, 200),
                            end: Offset(0, -200),
                            duration: Duration(seconds: 2),
                          )
                          .fadeOut(
                            duration: Duration(seconds: 2),
                          ),
                    );
                  }),
                ),
              ),
            ),

          // 😢 Full-Screen Sad Rain Animation
          if (_showSadAnimation)
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  children: [
                    ...List.generate(30, (index) {
                      return Positioned(
                        left: MediaQuery.of(context).size.width *
                            (index % 10) /
                            10,
                        top: MediaQuery.of(context).size.height *
                            (index % 5) /
                            5,
                        child: Icon(
                          Icons.water_drop,
                          size: 15 + (index % 5).toDouble() * 2,
                          color: Colors.blueAccent,
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .move(
                              begin: Offset(0, -100),
                              end: Offset(0, 500),
                              duration: Duration(seconds: 2),
                            )
                            .fadeOut(
                              duration: Duration(seconds: 2),
                            ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          LayoutBuilder(
            builder: (context, constraints) {
              double formWidth = constraints.maxWidth > 600
                  ? constraints.maxWidth * 0.5
                  : constraints.maxWidth * 0.9;

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            width: formWidth,
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.blue.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2)
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "We value your feedback!",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 20),

                                  // Name Input
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: "Your Name",
                                      prefixIcon: Icon(Icons.person_outline),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 15),

                                  // Email Input
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: "Your Email",
                                      prefixIcon: Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(
                                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                          .hasMatch(value)) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 15),

                                  // Subject Input
                                  TextFormField(
                                    controller: _subjectController,
                                    decoration: InputDecoration(
                                      labelText: "Subject",
                                      prefixIcon: Icon(Icons.subject),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a subject';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 15),

                                  // Feedback Input
                                  TextFormField(
                                    controller: _feedbackController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      labelText: "Your Feedback",
                                      prefixIcon: Icon(Icons.feedback_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please provide your feedback';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // Rating Slider
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Rating: ",
                                        style:
                                            GoogleFonts.poppins(fontSize: 16),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: _rating,
                                          min: 1,
                                          max: 5,
                                          divisions: 4,
                                          label: _rating.round().toString(),
                                          activeColor: Colors.blueAccent,
                                          onChanged: _handleRatingChange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _isSubmitting
                                        ? null // ✅ Disable button while submitting
                                        : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                _isSubmitting =
                                                    true; // ✅ Prevent multiple taps
                                              });

                                              try {
                                                await FirebaseFirestore.instance
                                                    .collection("feedbacks")
                                                    .add({
                                                  "name": _nameController.text,
                                                  "email":
                                                      _emailController.text,
                                                  "subject":
                                                      _subjectController.text,
                                                  "feedback":
                                                      _feedbackController.text,
                                                  "rating": _rating,
                                                  "timestamp": FieldValue
                                                      .serverTimestamp(),
                                                });

                                                // ✅ Show success message
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Feedback Submitted Successfully!"),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );

                                                // ✅ Clear fields after submission
                                                _nameController.clear();
                                                _emailController.clear();
                                                _subjectController.clear();
                                                _feedbackController.clear();
                                                setState(() {
                                                  _rating = 3; // Reset rating
                                                  _isSubmitting =
                                                      false; // Re-enable button
                                                });
                                              } catch (error) {
                                                // ❌ Show error message
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Error submitting feedback!"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );

                                                setState(() {
                                                  _isSubmitting =
                                                      false; // Re-enable button on failure
                                                });
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: _isSubmitting
                                        ? CircularProgressIndicator() // ✅ Show loading spinner while submitting
                                        : Text(
                                            "Submit",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
