import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thingqbator/core/constants/routes.dart';
import 'package:thingqbator/core/services/firebase_service.dart';
import 'package:thingqbator/features/auth/widgets/login_form.dart';
import 'dart:math';

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
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: ParticlePainter(_controller),
            ),
          ),
          LoginForm(size: size),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;

  ParticlePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = animation.value * (size.width / 2 + 60);
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final dx = centerX + radius * cos(i * pi / 2);
      final dy = centerY + radius * sin(i * pi / 2);
      canvas.drawCircle(Offset(dx, dy), 10, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) =>
      animation.value != oldDelegate.animation.value;
}