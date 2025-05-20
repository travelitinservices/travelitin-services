import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences.dart';

class JwtService {
  static const String _tokenKey = 'auth_token';
  static const String _secretKey = 'your-secret-key-here'; // In production, use environment variables

  // Generate JWT token
  static String generateToken({
    required String userId,
    required List<String> scopes,
    Duration expiry = const Duration(hours: 24),
  }) {
    final now = DateTime.now();
    final payload = {
      'sub': userId,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(expiry).millisecondsSinceEpoch ~/ 1000,
      'scopes': scopes,
    };

    // In production, use a proper JWT library with proper signing
    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    final encodedHeader = base64Url.encode(utf8.encode(json.encode(header)));
    final encodedPayload = base64Url.encode(utf8.encode(json.encode(payload)));
    final signature = _generateSignature(encodedHeader, encodedPayload);

    return '$encodedHeader.$encodedPayload.$signature';
  }

  // Verify JWT token
  static bool verifyToken(String token) {
    try {
      if (JwtDecoder.isExpired(token)) {
        return false;
      }

      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }

      final header = parts[0];
      final payload = parts[1];
      final signature = parts[2];

      final expectedSignature = _generateSignature(header, payload);
      return signature == expectedSignature;
    } catch (e) {
      return false;
    }
  }

  // Get token claims
  static Map<String, dynamic>? getTokenClaims(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  // Save token to local storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token from local storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Remove token from local storage
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Generate signature for JWT
  static String _generateSignature(String header, String payload) {
    final data = '$header.$payload';
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(data);
    
    // In production, use proper HMAC-SHA256 implementation
    // This is a simplified version for demonstration
    final hmac = Hmac(sha256, key);
    final signature = hmac.convert(bytes);
    return base64Url.encode(signature.bytes);
  }
} 