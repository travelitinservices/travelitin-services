import 'package:flutter/material.dart';
import 'package:travelitin/languages.dart';
import 'package:travelitin/storage_service.dart';
import 'package:travelitin/features/language/widgets/language_dropdown.dart';
import 'package:travelitin/features/language/widgets/language_search_bar.dart';

class LanguageSuggestionPage extends StatefulWidget {
  const LanguageSuggestionPage({super.key});

  @override
  State<LanguageSuggestionPage> createState() => _LanguageSuggestionScreenState();
}

class _LanguageSuggestionScreenState extends State<LanguageSuggestionPage> {
  final StorageService _storageService = StorageService();
  String _selectedLanguage = '';
  String _searchQuery = '';
  List<String> supportedLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Chinese',
    'Japanese',
    'Korean'
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await _storageService.getLanguage();
    setState(() {
      _selectedLanguage = savedLanguage ?? supportedLanguages.first;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredLanguages = supportedLanguages
        .where((lang) => lang.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LanguageSearchBar(onSearchChanged: _onSearchChanged),
            const SizedBox(height: 16),
            LanguageDropdown(
              selectedLanguage: _selectedLanguage,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  _storageService.saveLanguage(value);
                }
              },
              items: _searchQuery.isEmpty
                  ? supportedLanguages
                  : filteredLanguages,
            ),
          ],
        ),
      ),
    );
  }
}