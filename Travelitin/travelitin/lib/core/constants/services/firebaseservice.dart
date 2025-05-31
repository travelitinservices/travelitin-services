import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User related methods
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Authentication methods
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> createUserWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Phone authentication methods
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // User profile methods
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _firestore.collection('intel').doc(uid).set(userData, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('intel').doc(uid).get();
      return doc.data();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // Scam reporting methods
  Future<void> reportScam({
    required String location,
    required String content,
    required String userEmail,
  }) async {
    try {
      await _firestore.collection('scams').add({
        'location': location,
        'content': content,
        'userEmail': userEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  Future<List<Map<String, dynamic>>> searchScams(String query) async {
    try {
      final snapshot = await _firestore
          .collection('scams')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final location = (data['location'] ?? '').toString().toLowerCase();
            final content = (data['content'] ?? '').toString().toLowerCase();
            final normalizedQuery = query.toLowerCase();

            return location.contains(normalizedQuery) ||
                normalizedQuery.contains(location) ||
                content.contains(normalizedQuery);
          })
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
                'timestamp': doc.data()['timestamp']?.toDate(),
              })
          .toList();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // Feedback methods
  Future<void> submitFeedback({
    required String name,
    required String email,
    required String subject,
    required String feedback,
    required int rating,
  }) async {
    try {
      await _firestore.collection('feedbacks').add({
        'name': name,
        'email': email,
        'subject': subject,
        'feedback': feedback,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  Future<List<Map<String, dynamic>>> getFeedbacksByRating(int rating) async {
    try {
      final snapshot = await _firestore
          .collection('feedbacks')
          .where('rating', isEqualTo: rating)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'name': doc['name'] ?? 'Anonymous',
          'subject': doc['subject'] ?? 'No Subject',
          'feedback': doc['feedback'] ?? 'No Feedback',
          'rating': doc['rating'] ?? 0,
          'timestamp': doc['timestamp']?.toDate() ?? DateTime.now(),
        };
      }).toList();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // Error handling methods
  FirebaseException _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        message = 'Email is already in use.';
        break;
      case 'invalid-email':
        message = 'Email address is invalid.';
        break;
      case 'weak-password':
        message = 'Password is too weak.';
        break;
      case 'operation-not-allowed':
        message = 'Operation not allowed.';
        break;
      default:
        message = 'An error occurred. Please try again.';
    }
    return FirebaseAuthException(code: e.code, message: message);
  }

  FirebaseException _handleFirestoreException(FirebaseException e) {
    String message;
    switch (e.code) {
      case 'permission-denied':
        message = 'You do not have permission to perform this operation.';
        break;
      case 'not-found':
        message = 'The requested document was not found.';
        break;
      case 'already-exists':
        message = 'The document already exists.';
        break;
      case 'resource-exhausted':
        message = 'The operation was aborted due to resource constraints.';
        break;
      default:
        message = 'An error occurred while accessing the database.';
    }
    return FirebaseException(plugin: 'cloud_firestore', code: e.code, message: message);
  }
}