/// The `TranslatePage` class in Dart is a Flutter widget that allows users to input text, translate it
/// to different languages using Google Translate API, listen to the translated text, and display the
/// translated text with speech capabilities.
library;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelitin/core/constants/theme/app_theme.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  bool isSmallScreen = false;

  @override
  Widget build(BuildContext context) {
    isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate'),
        foregroundColor: AppTheme.accentColor,
      ),
      body: Container(
        decoration: AppTheme.glassmorphismDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: AppTheme.inputDecoration,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement translation
                setState(() {
                  _translatedText = 'Translated text will appear here';
                });
              },
              child: const Text('Translate'),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: AppTheme.glassmorphismDecoration,
              padding: const EdgeInsets.all(16),
              child: Text(
                _translatedText,
                style: AppTheme.bodyTextStyle(isSmallScreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
