import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayFeedPage extends StatefulWidget {
  const DisplayFeedPage({super.key});

  @override
  State<DisplayFeedPage> createState() => _DisplayFeedPageState();
}

class _DisplayFeedPageState extends State<DisplayFeedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showFeedback = false;
  String _feedbackTitle = "";
  List<Map<String, dynamic>> feedbackList = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fetchFeedback(int rating) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('feedbacks')
          .where('rating', isEqualTo: rating)
          .orderBy('timestamp', descending: true) // Requires Firestore index
          .get();

      setState(() {
        feedbackList = querySnapshot.docs.map((doc) {
          return {
            'name': doc['name'] ?? 'Anonymous',
            'subject': doc['subject'] ?? 'No Subject',
            'feedback': doc['feedback'] ?? 'No Feedback',
            'rating': doc['rating'] ?? 0,
            'timestamp': doc['timestamp']?.toDate() ?? DateTime.now(),
          };
        }).toList();
        _feedbackTitle = "Feedback with Rating $rating";
        _showFeedback = true;
      });
    } catch (e) {
      print("🔥 Firestore Error: $e");
    }
  }


  void _onCardTap(int index) {
    if (index == 5) {
      _fetchFeedback(5); // Fetch feedback for rating 5
    } else if (index == 4) {
      _fetchFeedback(4); // Fetch feedback for rating 4
    }  else if (index == 3) {
      _fetchFeedback(3); // Fetch feedback for rating 3
    }  else if (index == 2) {
      _fetchFeedback(2); // Fetch feedback for rating 3
    } else if (index == 1) {
      _fetchFeedback(1); // Fetch feedback for rating 3
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Card $index Clicked"),
            content: Text("You clicked on card number $index"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double cardPosition = _showFeedback ? 100 : screenHeight / 2 - 100;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Feedbacks",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                context.go('/');
              },
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Cards Section
            // ✅ Cards Section (Now Properly Centered)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.only(top: 40), // ✅ Dynamic spacing
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // ✅ Ensures text & cards are aligned
                  children: [
                    Text(
                      "Filter Feedbacks",
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .moveY(begin: -20, end: 0),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment:
                          WrapAlignment.center, // ✅ Ensures cards are centered
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => _onCardTap(index + 1),
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1 + (_controller.value * 0.05),
                                child: child,
                              );
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent.withOpacity(0.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "${index + 1}",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(delay: (index * 200).ms),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),


            // ✅ Add dynamic space to prevent overlap
            const SizedBox(height: 40),

            // ✅ Feedback Section (Dynamically Appears Below Cards)
            if (_showFeedback)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _feedbackTitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 800.ms).moveY(begin: 20, end: 0),

                  const SizedBox(
                      height: 20), // ✅ Extra spacing between title and content

                  ListView.builder(
                    shrinkWrap: true, // ✅ Ensures it takes only required space
                    physics:
                        NeverScrollableScrollPhysics(), // ✅ Prevents nested scrolling issues
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: feedbackList.length,
                    itemBuilder: (context, index) {
                      final feedback = feedbackList[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.blue.shade100
                            ], // ✅ Gradient inside card
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feedback['name'],
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                feedback['subject'],
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                feedback['feedback'],
                                style: GoogleFonts.montserrat(fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "⭐ Rating: ${feedback['rating']}",
                                    style:
                                        const TextStyle(color: Colors.orange),
                                  ),
                                  Text(
                                    "${feedback['timestamp']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .moveY(begin: 20, end: 0);

                    },
                  ),
                ],
              ),

            const SizedBox(height: 40), // ✅ Extra spacing at the bottom
          ],
        ),
      ),

    );
  }
}
