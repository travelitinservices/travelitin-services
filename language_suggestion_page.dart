import 'package:flutter/material.dart';
import 'package:thingqbator/core/constants/languages.dart';
import 'package:thingqbator/core/services/storage_service.dart';
import 'package:thingqbator/features/language/widgets/language_dropdown.dart';
import 'package:thingqbator/features/language/widgets/language_search_bar.dart';

class LanguageSuggestionScreen extends StatefulWidget {
  const LanguageSuggestionScreen({super.key});

  @override
  _LanguageSuggestionScreenState createState() =>
      _LanguageSuggestionScreenState();
}

class _LanguageSuggestionScreenState extends State<LanguageSuggestionScreen> {
  final StorageService _storageService = StorageService();
  String? _selectedLanguage;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await _storageService.getLanguage();
    setState(() {
      _selectedLanguage = savedLanguage ?? supportedLanguages.first;
      _isLoading = false;
    });
  }

  void _onLanguageChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedLanguage = newValue;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<void> _saveLanguage() async {
    if (_selectedLanguage != null) {
      await _storageService.saveLanguage(_selectedLanguage!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language set to $_selectedLanguage'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLanguages = supportedLanguages
        .where((language) =>
        language.toLowerCase().contains(_searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Language'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LanguageSearchBar(onSearchChanged: _onSearchChanged),
            const SizedBox(height: 20),
            LanguageDropdown(
              selectedLanguage: _selectedLanguage,
              languages: filteredLanguages.isNotEmpty
                  ? filteredLanguages
                  : supportedLanguages,
              onChanged: _onLanguageChanged,
            ),
            const SizedBox(height: 20),
            Text(
              'Selected Language: ${_selectedLanguage ?? "None"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveLanguage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Language',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}