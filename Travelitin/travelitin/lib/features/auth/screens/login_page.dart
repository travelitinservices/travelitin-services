import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/sign_up_page.dart';
import '../screens/forgot_password_page.dart';
import 'package:travelitin/home_page.dart';
import 'package:travelitin/core/constants/routes.dart';
import 'package:travelitin/core/constants/services/firebaseservice.dart';
import 'package:travelitin/core/services/error_handling_service.dart';
import 'package:travelitin/inputfields.dart';
import 'package:travelitin/features/auth/widgets/input_fields.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final ErrorHandlingService _errorHandler = ErrorHandlingService();
  bool _obscureText = true;
  late AnimationController _controller;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isOtpLogin = false; // Toggle for OTP login
  String? _verificationId; // Make this nullable
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
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
        if (mounted) {
          context.go(AppRoutes.home);
        }
      } on FirebaseAuthException catch (e) {
        _errorHandler.handleFirebaseAuthError(context, e);
      } catch (e) {
        _errorHandler.handleGenericError(context, e);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
      phoneNumber: phoneController.text.trim(),
          verificationCompleted: (credential) async {
            await _firebaseService.signInWithPhoneCredential(credential);
            if (mounted) {
              context.go(AppRoutes.home);
            }
          },
          verificationFailed: (e) {
            if (mounted) {
              _errorHandler.handleFirebaseAuthError(context, e);
              setState(() => _isLoading = false);
            }
          },
          codeSent: (verificationId, _) {
            if (mounted) {
        setState(() {
          _verificationId = verificationId;
                _isLoading = false;
              });
            }
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      } catch (e) {
        if (mounted) {
          _errorHandler.handleGenericError(context, e);
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _verifyOtp(BuildContext context) async {
    if (_verificationId != null) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text.trim(),
      );

      try {
        await _firebaseService.signInWithPhoneCredential(credential);
        if (mounted) {
          context.go(AppRoutes.home);
        }
      } on FirebaseAuthException catch (e) {
        _errorHandler.handleFirebaseAuthError(context, e);
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#\\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD700), // Golden Yellow
              Color(0xFFFFFFFF), // White
              Color(0xFF1A237E), // Dark Blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome message with glassy background and gradient text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFF1A237E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Welcome Back',
                          style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white, // This will be masked by the gradient
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        blendMode: BlendMode.srcIn,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your journey',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: const Color(0xFF1A237E),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.7),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Login Card (NO blur)
                Container(
                  width: size.width < 500 ? size.width * 0.9 : 400,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isOtpLogin) ...[
                          _buildModernTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 20),
                          _buildModernTextField(
                            controller: passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: _validatePassword,
                          ),
                        ] else ...[
                          _buildModernTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            validator: _validatePhone,
                          ),
                          if (_verificationId != null) ...[
                            const SizedBox(height: 20),
                            _buildModernTextField(
                              controller: otpController,
                              label: 'OTP',
                              icon: Icons.security_outlined,
                            ),
                          ],
                        ],
                        const SizedBox(height: 28),
                        _buildModernLoginButton(),
                        const SizedBox(height: 20),
                        _buildModernSocialButtons(),
                        const SizedBox(height: 12),
                        _buildModernAdditionalOptions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
        child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
              if (!_isOtpLogin) ...[
                _buildModernTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),
                _buildModernTextField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: _validatePassword,
                ),
              ] else ...[
                _buildModernTextField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  validator: _validatePhone,
                ),
                if (_verificationId != null) ...[
                  const SizedBox(height: 20),
                  _buildModernTextField(
                    controller: otpController,
                    label: 'OTP',
                    icon: Icons.security_outlined,
                  ),
                ],
              ],
              const SizedBox(height: 30),
              _buildModernLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscureText,
      validator: validator,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
            decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: Colors.black54),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: const Color(0xFFFFD700), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.10),
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideX(begin: -0.2, end: 0);
  }

  Widget _buildModernLoginButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700), // Golden Yellow
              const Color(0xFF1A237E), // Dark Blue
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : () => _isOtpLogin ? _sendOtp() : _loginWithEmail(),
            borderRadius: BorderRadius.circular(15),
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _isOtpLogin ? 'Send OTP' : 'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .scale(delay: 200.ms);
  }

  Widget _buildModernSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModernSocialButton(
          icon: Icons.g_mobiledata,
          onPressed: () {},
          color: Colors.red,
          label: 'Google',
        ),
        const SizedBox(width: 16),
        _buildModernSocialButton(
          icon: Icons.facebook,
          onPressed: () {},
          color: Colors.blue,
          label: 'Facebook',
        ),
        const SizedBox(width: 16),
        _buildModernSocialButton(
          icon: Icons.apple,
          onPressed: () {},
          color: Colors.black,
          label: 'Apple',
        ),
      ],
    );
  }

  Widget _buildModernSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required String label,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
      children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .scale(delay: 200.ms);
  }

  Widget _buildModernAdditionalOptions() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFF1A237E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: TextButton(
            onPressed: () {
              setState(() => _isOtpLogin = !_isOtpLogin);
            },
            child: Text(
              _isOtpLogin ? 'Login with Email' : 'Login with OTP',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white, // masked by gradient
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFF1A237E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
              );
            },
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white, // masked by gradient
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFF1A237E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                "Don't have an account?",
                style: GoogleFonts.poppins(
                  color: Colors.white, // masked by gradient
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFF1A237E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // masked by gradient
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
