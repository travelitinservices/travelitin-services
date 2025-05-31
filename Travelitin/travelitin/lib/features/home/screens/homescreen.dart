import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travelitin/core/constants/routes.dart';
import 'package:travelitin/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Guide Home'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildNavButton(context, 'Feed', Icons.feed, AppRoutes.feed),
            _buildNavButton(context, 'Trip Planner', Icons.map, AppRoutes.planner),
            _buildNavButton(context, 'Travel Chat', Icons.chat, AppRoutes.travel),
            _buildNavButton(context, 'Explore', Icons.explore, AppRoutes.explore),
            _buildNavButton(context, 'Report Scams', Icons.warning, AppRoutes.scamReport),
            _buildNavButton(context, 'Travel Expenses', Icons.money, AppRoutes.travelExpense),
            _buildNavButton(context, 'Translate', Icons.translate, AppRoutes.translate),
            _buildNavButton(context, 'Language', Icons.language, AppRoutes.language),
            _buildNavButton(context, 'Map View', Icons.map_outlined, AppRoutes.map),
            _buildNavButton(context, 'Pricing', Icons.monetization_on, AppRoutes.revenue),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}