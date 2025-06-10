import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelitin/core/constants/routes.dart';
import 'package:travelitin/core/constants/services/firebaseservice.dart';
import 'package:travelitin/core/services/error_handling_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:travelitin/core/constants/theme/appTheme.dart';
import 'package:travelitin/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final ErrorHandlingService _errorHandler = ErrorHandlingService();
  bool _isLoading = false;
  bool _isLogin = true;
  String? _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        await _firebaseService.signInWithEmail(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        if (mounted) {
          context.go(AppRoutes.home);
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e.code);
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
        _errorMessage = null;
    });
      try {
        await _firebaseService.createUserWithEmail(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
            if (mounted) {
              context.go(AppRoutes.home);
            }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e.code);
              });
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Email not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Incorrect email format';
      case 'email-already-in-use':
        return 'Email already in use';
      default:
        return 'Something went wrong';
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Incorrect email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 4) {
      return 'Password cannot be less than 4 characters';
    }
    if (value.length > 12) {
      return 'Password cannot exceed 12 characters';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (!_isLogin) {
    if (value == null || value.isEmpty) {
        return 'Username is required';
      }
      if (value.length < 4) {
        return 'Username cannot be less than 4 characters';
      }
      if (value.length > 10) {
        return 'Username cannot exceed 10 characters';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeNotifier = Provider.of<ThemeModeNotifier>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // Left side - Login/Signup form
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                    Text(
                      _isLogin ? 'Log In' : 'Sign Up',
                      style: const TextStyle(
                        fontFamily: 'CalSans',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Container(
                      width: 0,
                      height: 4,
                      color: Colors.red,
                      margin: const EdgeInsets.only(top: 8),
                    ),
                    const SizedBox(height: 48),
                    if (!_isLogin) ...[
                      _buildInputField(
                        controller: usernameController,
                        icon: Icons.person,
                        hintText: 'Username',
                        validator: _validateUsername,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildInputField(
                      controller: emailController,
                      icon: Icons.email,
                      hintText: 'Email',
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: passwordController,
                      icon: Icons.lock,
                      hintText: 'Password',
                      isPassword: true,
                      validator: _validatePassword,
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (_isLogin) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.forgotPassword),
                        child: Text(
                          'Forgot Password? Click Here!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildButton(
                          text: 'Login',
                          isPrimary: _isLogin,
                          onPressed: _isLogin ? _handleLogin : () => setState(() => _isLogin = true),
                        ),
                        const SizedBox(width: 16),
                        _buildButton(
                          text: 'Sign Up',
                          isPrimary: !_isLogin,
                          onPressed: _isLogin ? () => setState(() => _isLogin = false) : _handleSignUp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Right side - Image slider
          if (size.width > 800)
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/travel.json',
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, color: Colors.grey[600]),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 160,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.red : Colors.grey[200],
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
} 