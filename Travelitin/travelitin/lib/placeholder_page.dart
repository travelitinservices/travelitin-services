import 'package:flutter/material.dart';

class PlaceholderPage extends StatefulWidget {
  final String title;

  const PlaceholderPage({Key? key, required this.title}) : super(key: key);

  @override
  State<PlaceholderPage> createState() => _PlaceholderPageState();
}

class _PlaceholderPageState extends State<PlaceholderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(
          'This is the ${widget.title}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 