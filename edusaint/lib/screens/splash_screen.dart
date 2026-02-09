import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'home_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    // Debug logging
    print('=== PERSISTENT LOGIN DEBUG ===');
    print('Token exists: ${token != null}');
    print('Token value: $token');
    print('Token is empty: ${token?.isEmpty ?? true}');
    
    if (!mounted) return;
    
    if (token != null && token.isNotEmpty) {
      // User is logged in, navigate to HomeView
      print('Navigating to HomeView (logged in)');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } else {
      // User is not logged in, navigate to OnboardingScreen
      print('Navigating to OnboardingScreen (not logged in)');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A6BEE), Color(0xFF3A5DC8)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Image
            Container(
              height: height * 0.30,
              width: height * 0.30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 4,
                ),
              ),
              child: ClipOval(
                child: Image.asset("assets/logo.jpeg", fit: BoxFit.cover),
              ),
            ),

            SizedBox(height: height * 0.03),

            // Text under Logo
            Text(
              "Edusaint",
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
