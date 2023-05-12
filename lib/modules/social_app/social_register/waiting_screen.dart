import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../social_login/social_login_screen.dart';
import 'cubit/cubit.dart';
import 'dart:async';

class WaitingVerificationScreen extends StatefulWidget {
  const WaitingVerificationScreen({super.key});

  @override
  _WaitingVerificationScreenState createState() => _WaitingVerificationScreenState();
}


class _WaitingVerificationScreenState extends State<WaitingVerificationScreen> {
  late Timer refreshTimer;

  @override
  void initState() {
    super.initState();
    checkEmailVerificationStatus();
    startRefreshTimer();
  }

  void checkEmailVerificationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user?.emailVerified == true) {
      setState(() {
        navigateToLoginScreen();
      });
    }
  }

  void startRefreshTimer() {
    const refreshInterval = Duration(seconds: 5); // Set the refresh interval as desired
    refreshTimer = Timer.periodic(refreshInterval, (_) {
      checkEmailVerificationStatus();
    });
  }

  void stopRefreshTimer() {
    refreshTimer.cancel();
  }

  void navigateToLoginScreen() {
    stopRefreshTimer(); // Stop the refresh timer before navigating
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SocialLoginScreen()),
          (route) => false,
    );
  }

  @override
  void dispose() {
    stopRefreshTimer(); // Stop the refresh timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Account Verification',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'We sent you a verification email.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
