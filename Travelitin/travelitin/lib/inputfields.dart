import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class InputFields extends StatelessWidget {
  final bool isOtpLogin;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController otpController;
  final Function(String) onPhoneChanged;
  final bool obscureText;
  final VoidCallback toggleObscureText;
  final String? verificationId;

  const InputFields({
    super.key,
    required this.isOtpLogin,
    required this.emailController,
    required this.passwordController,
    required this.otpController,
    required this.onPhoneChanged,
    required this.obscureText,
    required this.toggleObscureText,
    this.verificationId,
  });

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

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isOtpLogin) ...[
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: const TextStyle(color: Colors.black),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [],
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(color: Colors.black),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.black),
              ),
              suffixIcon: IconButton(
                padding: const EdgeInsets.only(right: 8.0),
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: toggleObscureText,
              ),
            ),
            obscureText: obscureText,
            style: const TextStyle(color: Colors.black),
            keyboardType: TextInputType.visiblePassword,
            autofillHints: const [],
            validator: _validatePassword,
          ),
        ] else ...[
          IntlPhoneField(
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            initialCountryCode: 'IN',
            onChanged: (phone) => onPhoneChanged(phone.completeNumber),
          ),
          if (verificationId != null) ...[
            const SizedBox(height: 20),
            TextFormField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              autofillHints: const [],
              validator: _validateOtp,
            ),
          ],
        ],
      ],
    );
  }
}