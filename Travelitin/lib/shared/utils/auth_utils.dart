import 'package:firebase_auth/firebase_auth.dart';
import '../services/jwt_service.dart';

class AuthUtils {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Generate and store JWT token
      if (userCredential.user != null) {
        final token = JwtService.generateToken(
          userId: userCredential.user!.uid,
          scopes: ['user'], // Add appropriate scopes based on user role
        );
        await JwtService.saveToken(token);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Create user with email and password
  static Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Generate and store JWT token
      if (userCredential.user != null) {
        final token = JwtService.generateToken(
          userId: userCredential.user!.uid,
          scopes: ['user'], // Add appropriate scopes based on user role
        );
        await JwtService.saveToken(token);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await JwtService.removeToken();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return _auth.currentUser != null;
  }
} 