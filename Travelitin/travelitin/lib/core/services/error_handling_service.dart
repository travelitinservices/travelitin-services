import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void handleFirebaseAuthError(BuildContext context, FirebaseAuthException e) {
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
    showErrorSnackBar(context, message);
  }

  void handleFirestoreError(BuildContext context, FirebaseException e) {
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
    showErrorSnackBar(context, message);
  }

  void handleNetworkError(BuildContext context, Exception e) {
    showErrorSnackBar(
      context,
      'Network error occurred. Please check your internet connection.',
    );
  }

  void handleGenericError(BuildContext context, dynamic error) {
    showErrorSnackBar(
      context,
      'An unexpected error occurred. Please try again later.',
    );
  }
} 