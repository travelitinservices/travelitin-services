import 'package:flutter/material.dart';

class LanguageDropdown extends StatelessWidget {
  final String selectedLanguage;
  final Function(String?) onChanged;
  final List<String> items;

  const LanguageDropdown({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedLanguage,
        isExpanded: true,
        underline: const SizedBox(),
        items: items.map((String language) {
          return DropdownMenuItem<String>(
            value: language,
            child: Text(language),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
} 