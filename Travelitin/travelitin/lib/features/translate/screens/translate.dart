/// The `TranslateScreen` class is a Flutter widget that provides a comprehensive translation interface.
/// It supports text input, speech-to-text, language selection, text-to-speech output, translation history,
/// and clipboard functionality using Google Translate API with enhanced UI/UX.
library;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelitin/core/constants/theme/appTheme.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _textController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  String _translatedText = '';
  String _sourceLang = 'en';
  String _targetLang = 'es';
  bool _isLoading = false;
  bool _isListening = false;
  List<Map<String, String>> _translationHistory = [];
  bool isSmallScreen = false;

  // Available languages
  final Map<String, String> _languages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'ja': 'Japanese',
    'zh-cn': 'Chinese',
    'ru': 'Russian',
    'ar': 'Arabic',
    'hi': 'Hindi',
  };

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
  }

  void _initializeSpeech() async {
    await _speech.initialize();
  }

  void _initializeTts() async {
    await _tts.setLanguage(_targetLang);
    await _tts.setSpeechRate(0.5);
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _textController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _translateText() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to translate')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final translation = await _translator.translate(
        _textController.text,
        from: _sourceLang,
        to: _targetLang,
      );
      setState(() {
        _translatedText = translation.text;
        _translationHistory.insert(0, {
          'input': _textController.text,
          'translated': translation.text,
          'from': _sourceLang,
          'to': _targetLang,
        });
        if (_translationHistory.length > 5) _translationHistory.removeLast();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _speakTranslatedText() async {
    await _tts.setLanguage(_targetLang);
    await _tts.speak(_translatedText);
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _translatedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Translated text copied to clipboard')),
    );
  }

  void _clearInput() {
    _textController.clear();
    setState(() => _translatedText = '');
  }

  @override
  Widget build(BuildContext context) {
    isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: Text('Translate', style: GoogleFonts.poppins()),
        foregroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearInput,
            tooltip: 'Clear Input',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: AppTheme.glassmorphismDecoration,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _sourceLang,
                      items: _languages.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _sourceLang = value!),
                    ),
                    const Icon(Icons.arrow_forward),
                    DropdownButton<String>(
                      value: _targetLang,
                      items: _languages.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _targetLang = value!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                child: TextField(
                  controller: _textController,
                  decoration: AppTheme.inputDecoration.copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      onPressed: _startListening,
                    ),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              FadeInLeft(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _translateText,
                      style: AppTheme.elevatedButtonStyle,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Translate'),
                    ),
                    ElevatedButton(
                      onPressed: _translatedText.isEmpty ? null : _speakTranslatedText,
                      style: AppTheme.elevatedButtonStyle,
                      child: const Icon(Icons.volume_up),
                    ),
                    ElevatedButton(
                      onPressed: _translatedText.isEmpty ? null : _copyToClipboard,
                      style: AppTheme.elevatedButtonStyle,
                      child: const Icon(Icons.copy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeInRight(
                child: Container(
                  decoration: AppTheme.glassmorphismDecoration,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _translatedText.isEmpty
                        ? 'Translated text will appear here'
                        : _translatedText,
                    style: AppTheme.bodyTextStyle(isSmallScreen),
                  ),
                ),
              ),
              if (_translationHistory.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Recent Translations',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                FadeInUp(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _translationHistory.length,
                    itemBuilder: (context, index) {
                      final history = _translationHistory[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text('${history['input']}'),
                          subtitle: Text(
                            '${history['translated']} (${_languages[history['from']]} → ${_languages[history['to']]}',
                          ),
                          onTap: () {
                            setState(() {
                              _textController.text = history['input']!;
                              _translatedText = history['translated']!;
                              _sourceLang = history['from']!;
                              _targetLang = history['to']!;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
}
