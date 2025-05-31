import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _languageKey = 'selected_language';

  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
} 