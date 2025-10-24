import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../../helpers/dialogs.dart';
import '../../main.dart';
import '../home_screen.dart';
import 'email_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

  @override
  void initState() {
    super.initState();

    // For auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isAnimate = true);
      }
    });
  }

  // Check if running on Windows
  bool get isWindows => !kIsWeb && Platform.isWindows;

  // Handles Google login button click (Android only)
  _handleGoogleBtnClick() {
    // Show progress bar
    Dialogs.showLoading(context);

    _signInWithGoogle().then((user) async {
      // Hide progress bar
      if (mounted) {
        Navigator.pop(context);
      }

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if (await APIs.userExists() && mounted) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        } else {
          await APIs.createUser();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
      }
    });
  }

  // Sign in with Google (Android only)
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Check if user cancelled the sign-in
      if (googleUser == null) {
        log('User cancelled the sign-in');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle ERROR: $e');
      log('Error type: ${e.runtimeType}');

      if (mounted) {
        Dialogs.showSnackbar(context, 'Google Sign-In failed: $e');
      }

      return null;
    }
  }

  // Navigate to Email Login Screen (Windows)
  void _navigateToEmailLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Chat BA'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // App logo
          AnimatedPositioned(
            top: isWindows ? mq.height * .1 : mq.height * .15,
            right: _isAnimate
                ? (isWindows ? mq.width * .35 : mq.width * .25)
                : -mq.width * .5,
            width: isWindows
                ? math.min(mq.width * .4, 300) // Limit max width on Windows
                : mq.width * .5,
            // ignore: sort_child_properties_last
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isWindows ? 300 : double.infinity,
                maxHeight: isWindows ? 300 : double.infinity,
              ),
              child: Image.asset('assets/images/icon.png', fit: BoxFit.contain),
            ),
            duration: const Duration(seconds: 1),
          ),

          // Platform-specific login button
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            child: Column(
              children: [
                // Windows: Email/Password Login
                if (isWindows) ...[
                  SizedBox(
                    width: double.infinity,
                    height: mq.height * .06,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 1,
                      ),
                      onPressed: _navigateToEmailLogin,
                      icon: const Icon(Icons.email, size: 24),
                      label: const Text(
                        'Login with Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],

                // Android: Google Login
                if (!isWindows) ...[
                  SizedBox(
                    width: double.infinity,
                    height: mq.height * .06,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          223,
                          255,
                          187,
                        ),
                        shape: const StadiumBorder(),
                        elevation: 1,
                      ),
                      onPressed: _handleGoogleBtnClick,
                      icon: Image.asset(
                        'assets/images/google.png',
                        height: mq.height * .03,
                      ),
                      label: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          children: [
                            TextSpan(text: 'Login with '),
                            TextSpan(
                              text: 'Google',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: mq.height * .02),

                // Platform info text
                Text(
                  isWindows ? 'Use Email & Password' : 'Use Google Sign-In',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
