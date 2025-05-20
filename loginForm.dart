import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:thingqbator/core/constants/routes.dart';
import 'package:thingqbator/core/services/firebase_service.dart';
import 'package:thingqbator/features/auth/widgets/input_fields.dart';

class LoginForm extends StatefulWidget {
  final Size size;

  const LoginForm({super.key, required this.size});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  bool _obscureText = true;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isOtpLogin = false;
  String? _verificationId;
  String? _phoneNumber;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
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
        context.go(AppRoutes.home);
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e.code);
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        await _firebaseService.verifyPhoneNumber(
          phoneNumber: _phoneNumber!,
          verificationCompleted: (credential) async {
            await _firebaseService.signInWithPhoneCredential(credential);
            context.go(AppRoutes.home);
          },
          verificationFailed: (e) {
            setState(() {
              _errorMessage = _getErrorMessage(e.code);
              _isLoading = false;
            });
          },
          codeSent: (verificationId, _) {
            setState(() {
              _verificationId = verificationId;
              _isLoading = false;
            });
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Error sending OTP: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate() && _verificationId != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otpController.text.trim(),
        );
        await _firebaseService.signInWithPhoneCredential(credential);
        context.go(AppRoutes.home);
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e.code);
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-verification-code':
        return 'Incorrect OTP. Please try again.';
      default:
        return 'Something went wrong: $errorCode';
    }
  }

  void _toggleObscureText() {
    setState(() => _obscureText = !_obscureText);
  }

  void _toggleLoginMode() {
    setState(() {
      _isOtpLogin = !_isOtpLogin;
      _errorMessage = null;
      _verificationId = null;
      emailController.clear();
      passwordController.clear();
      otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = widget.size.width < 600;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: isSmallScreen ? widget.size.width * 0.85 : 370,
            padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  InputFields(
                    isOtpLogin: _isOtpLogin,
                    emailController: emailController,
                    passwordController: passwordController,
                    otpController: otpController,
                    onPhoneChanged: (phone) => _phoneNumber = phone,
                    obscureText: _obscureText,
                    toggleObscureText: _toggleObscureText,
                    verificationId: _verificationId,
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else ...[
                    if (!_isOtpLogin)
                      ElevatedButton(
                        onPressed: _loginWithEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (_isOtpLogin && _verificationId == null)
                      ElevatedButton(
                        onPressed: _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Send OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (_isOtpLogin && _verificationId != null)
                      ElevatedButton(
                        onPressed: _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.signup),
                    child: const Text(
                      'Create New Account',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _toggleLoginMode,
                    child: Text(
                      _isOtpLogin ? 'Login with Email' : 'Login with OTP',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}