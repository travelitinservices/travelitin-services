import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travelitin/core/services/firebase_service.dart';
import 'package:travelitin/core/services/storage_service.dart';
import 'package:travelitin/core/theme/app_theme.dart';
import 'package:travelitin/features/scam_report/widgets/location_search_bar.dart';
import 'package:travelitin/core/utils/error_handler.dart';

class ScamReportScreen extends StatefulWidget {
  const ScamReportScreen({super.key});

  @override
  _ScamReportScreenState createState() => _ScamReportScreenState();
}

class _ScamReportScreenState extends State<ScamReportScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showReportForm = true;
  bool _showSearchForm = true;
  String _firstName = 'Guest';
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadLastSearch();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('intel')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            _firstName = querySnapshot.docs[0]['firstName'] ?? 'Guest';
          });
        }
      }
    } catch (e) {
      ErrorHandler.showError(context, 'Error fetching user data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLastSearch() async {
    final lastSearch = await _storageService.getString('last_scam_search');
    if (lastSearch != null) {
      _searchController.text = lastSearch;
      await _performSearch(lastSearch);
    }
  }

  Future<void> _reportScam() async {
    if (_isSubmitting) return;
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);
    try {
      final user = _firebaseService.currentUser;
      if (user == null) {
        ErrorHandler.showError(
            context, 'You must be logged in to report a scam');
        return;
      }

      await FirebaseFirestore.instance.collection('scams').add({
        'location': _locationController.text.trim(),
        'content': _contentController.text.trim(),
        'userEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ErrorHandler.showSuccess(context, 'Scam reported successfully!');
      _locationController.clear();
      _contentController.clear();

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );

      await _performSearch(_locationController.text.trim());
    } catch (e) {
      ErrorHandler.showError(context, 'Error reporting scam: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final normalizedQuery = query.toLowerCase();
      final snapshot = await FirebaseFirestore.instance
          .collection('scams')
          .where('location', isGreaterThanOrEqualTo: normalizedQuery)
          .where('location', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
          .orderBy('timestamp', descending: true)
          .get();

      final filteredScams = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'timestamp': data['timestamp']?.toDate(),
        };
      }).toList();

      setState(() => _searchResults = filteredScams);
      await _storageService.saveString('last_scam_search', query);
    } catch (e) {
      ErrorHandler.showError(context, 'Error searching for scams');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateForm() {
    if (_locationController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ErrorHandler.showError(context, 'Please fill in all fields');
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scam Alerts'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome,',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        Text(
                          _firstName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color:
                                            Color.fromARGB(255, 255, 132, 0)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Report a Scam',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    _showReportForm
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  ),
                                  onPressed: () => setState(
                                      () => _showReportForm = !_showReportForm),
                                ),
                              ),
                              if (_showReportForm)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      LocationSearchBar(
                                        controller: _locationController,
                                        labelText: 'Location',
                                        onSelected: (suggestion) =>
                                            _locationController.text =
                                                suggestion,
                                        onTap: () => setState(
                                            () => _showSearchForm = false),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _contentController,
                                        decoration: AppTheme.inputDecoration(
                                                'Describe the scam in detail...')
                                            .copyWith(alignLabelWithHint: true),
                                        maxLines: 4,
                                        keyboardType: TextInputType.multiline,
                                        autofillHints: const [],
                                        onTap: () => setState(
                                            () => _showSearchForm = false),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _isSubmitting
                                              ? null
                                              : _reportScam,
                                          style: AppTheme.elevatedButtonStyle,
                                          child: _isSubmitting
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                )
                                              : const Text('Submit Report'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: const Row(
                                  children: [
                                    Icon(Icons.search, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text(
                                      'Search Reported Scams',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    _showSearchForm
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                  ),
                                  onPressed: () => setState(
                                      () => _showSearchForm = !_showSearchForm),
                                ),
                              ),
                              if (_showSearchForm)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      LocationSearchBar(
                                        controller: _searchController,
                                        labelText:
                                            'Search by Location or Content',
                                        onSelected: (suggestion) {
                                          _searchController.text = suggestion;
                                          _performSearch(suggestion);
                                          setState(
                                              () => _showReportForm = false);
                                        },
                                        onTap: () => setState(
                                            () => _showReportForm = false),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _performSearch(
                                                _searchController.text.trim());
                                            setState(() {
                                              _showReportForm = false;
                                              _showSearchForm = false;
                                            });
                                          },
                                          icon: const Icon(Icons.search),
                                          label: const Text('Search'),
                                          style: AppTheme.elevatedButtonStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_searchResults.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Search Results (${_searchResults.length})',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              final timestamp =
                                  result['timestamp'] as DateTime?;
                              final formattedDate = timestamp != null
                                  ? DateFormat('MMM d, yyyy h:mm a')
                                      .format(timestamp)
                                  : 'Date unknown';
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: AppTheme.primaryColor),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              result['location'] ??
                                                  'Unknown Location',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        result['content'] ?? 'No Details',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ] else if (_searchController.text.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No scams reported in this area yet.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
