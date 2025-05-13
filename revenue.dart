import 'package:flutter/material.dart';
import 'dart:math';

class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  _RevenuePageState createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Duration for full animation loop
    )..repeat(); // Infinite loop
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AnimatedAppBar(controller: _controller),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int columns = 1; // Default for small screens

          if (constraints.maxWidth >= 1200) {
            columns = 4;
          } else if (constraints.maxWidth >= 900) {
            columns = 3;
          } else if (constraints.maxWidth >= 600) {
            columns = 2;
          }

          double cardWidth =
              constraints.maxWidth / columns - 40; // Adjust width

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center horizontally
                children: [
                  SizedBox(
                      height: 56), // Add some spacing between appbar and cards

                  // Centering the Wrap widget inside the Column
                  Center(
                    child: Wrap(
                      spacing: 34.0,
                      runSpacing: 24.0,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildCard(
                          context,
                          title: "FREE\nRS. 0\nfor first trip",
                          details: [
                            "✔ Real-Time Safety Alerts",
                            "✔ Trip Planner",
                            "✔ Expense Tracker",
                            "✔ Language Translate (Text Only)",
                            "❌ Scam Reporting",
                            "✔ Emergency Services",
                            "❌ Customer Support",
                            "❌ Ad-free content",
                          ],
                          color: const Color(0xFF8c52ff),
                          width: cardWidth,
                        ),
                        _buildCard(
                          context,
                          title: "STANDARD\nRS. 200\nfor two trips",
                          details: [
                            "✔ Real-Time Safety Alerts",
                            "✔ Trip Planner",
                            "✔ Expense Tracker",
                            "✔ Language Translate (Text Only)",
                            "✔ Scam Reporting",
                            "✔ Emergency Services",
                            "✔ Customer Support",
                            "❌ Ad-free content",
                          ],
                          color: const Color(0xFFfd603a),
                          width: cardWidth,
                        ),
                        _buildCard(
                          context,
                          title: "PREMIUM\nRS. 500\nper month",
                          details: [
                            "✔ Real-Time Safety Alerts",
                            "✔ Trip Planner",
                            "✔ Expense Tracker",
                            "✔ Language Translate (Text Only)",
                            "✔ Scam Reporting",
                            "✔ Emergency Services",
                            "✔ Customer Support",
                            "✔ Ad-free content",
                          ],
                          color: const Color(0xFF2bcfb6),
                          width: cardWidth,
                        ),
                        _buildCard(
                          context,
                          title: "ELITE\nRS. 1500\nper year",
                          details: [
                            "✔ Real-Time Safety Alerts",
                            "✔ Trip Planner",
                            "✔ Expense Tracker",
                            "✔ Language Translate (Text Only)",
                            "✔ Scam Reporting",
                            "✔ Emergency Services",
                            "✔ Customer Support",
                            "✔ Ad-free content",
                          ],
                          color: const Color(0xFF004aad),
                          width: cardWidth,
                        ),
                      ],
                    ),
                  ), // Optional: Add space at the bottom for better appearance
                ],
              ),
            ),
          );
        },
      ),

    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required List<String> details,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      height: MediaQuery.of(context).size.height *
          0.77, // Increased height for better spacing
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Colored title section
          Container(
            height: MediaQuery.of(context).size.height * 0.30, 
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            alignment: Alignment.center,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title.split('\nRS.')[0] + "\n",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      height: 1.9,
                    ),
                  ),
                  TextSpan(
                    text: "RS." + title.split('\nRS.')[1].split('\n')[0] + "\n",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 29.0,
                      fontWeight: FontWeight.bold,
                      height: 1.9,
                    ),
                  ),
                  TextSpan(
                    text: title.split('\nRS.')[1].split('\n')[1],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      height: 1.9,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details section with scrollable content
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                // Prevents overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: details
                      .map((detail) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              detail,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                height: 1.5,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class AnimatedAppBar extends StatelessWidget {
  final AnimationController controller;

  const AnimatedAppBar({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Sine wave background
            AppBar(
              flexibleSpace: CustomPaint(
                painter: SinWavePainter(controller.value),
                child: Container(),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            // Title and leading button with proper box size and border-radius
            AppBar(
              leading: Container(
                height: kToolbarHeight, // Full height of the app bar
                width: kToolbarHeight + 10, // Slightly wider for increased size
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor, // Match page background
                  borderRadius: BorderRadius.circular(12.0), // Rounded corners
                ),
                child: IconButton(
                  iconSize: 28.0, // Increased size for the icon
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              title: Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor, // Match page background
                    borderRadius:
                        BorderRadius.circular(12.0), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 38.0, // Adjusted for compact title
                    vertical: 9.0,
                  ),
                  child: const Text(
                    'Pricing',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
            ),
          ],
        );
      },
    );
  }

}

class SinWavePainter extends CustomPainter {
  final double animationValue;

  SinWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
    ];

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i].withOpacity(0.5);

      path.reset();
      for (double x = 0; x < size.width; x++) {
        double y = size.height / 2 +
            sin((x / size.width * 2 * pi) +
                    (i * pi / 4) - // Offset for multiple waves
                    animationValue * 2 * pi) *
                20;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
