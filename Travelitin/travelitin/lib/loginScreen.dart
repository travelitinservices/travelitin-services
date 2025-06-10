import 'package:flutter/material.dart';
import 'package:travelitin/core/constants/routes.dart';
import 'package:travelitin/core/services/firebase_service.dart';
import 'package:travelitin/features/auth/widgets/login_form.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'core/constants/theme/appTheme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'A Safety Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            tooltip: 'Toggle theme',
            onPressed: () => themeNotifier.toggleTheme(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ParticlePainter(_controller, isDark: isDark),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Image.asset(
                      'travelitin_services/travelitin/assets/company-logo.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  LoginForm(size: size),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;
  ParticlePainter(this.animation, {this.isDark = false}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = animation.value * (size.width / 2 + 60);
    // Gold/Yellow color from logo
    final gold = const Color(0xFFFFC107); // Material gold
    final blue = const Color(0xFF4FC3F7); // Lighter blue to match logo
    final white = Colors.white.withOpacity(0.7);
    // Main particles (blue)
    final paint = Paint()
      ..color = blue.withOpacity(0.22)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 12; i++) {
      final dx = centerX + radius * cos(i * 2 * pi / 12);
      final dy = centerY + radius * sin(i * 2 * pi / 12);
      canvas.drawCircle(Offset(dx, dy), 12, paint);
    }
    // Gold/yellow accent particles
    final goldPaint = Paint()
      ..color = gold.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final dx = centerX + (radius - 30) * cos(i * 2 * pi / 6 + pi / 6);
      final dy = centerY + (radius - 30) * sin(i * 2 * pi / 6 + pi / 6);
      canvas.drawCircle(Offset(dx, dy), 8, goldPaint);
    }
    // White smaller particles for depth
    final whitePaint = Paint()
      ..color = white
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 18; i++) {
      final dx = centerX + (radius - 50) * cos(i * 2 * pi / 18);
      final dy = centerY + (radius - 50) * sin(i * 2 * pi / 18);
      canvas.drawCircle(Offset(dx, dy), 5, whitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) =>
      animation.value != oldDelegate.animation.value || isDark != oldDelegate.isDark;
}