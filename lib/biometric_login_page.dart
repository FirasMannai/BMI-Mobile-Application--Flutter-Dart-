// Importing necessary packages
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

// Biometric login page
// This page handles biometric authentication for app access
class BiometricLoginPage extends StatefulWidget {
  const BiometricLoginPage({super.key});

  @override
  _BiometricLoginPageState createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  String _message = 'Please authenticate to access the app';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  // Function to handle biometric authentication
  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        setState(() {
          _message = 'Biometric authentication is not available on this device';
          _isAuthenticating = false;
        });
        return;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access BMI Calculator',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/input');
      } else {
        setState(() {
          _message = 'Authentication failed. Please try again.';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Authentication error. Please try again.';
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (!_isAuthenticating)
              ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Try Again'),
              ),
            if (_isAuthenticating) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
