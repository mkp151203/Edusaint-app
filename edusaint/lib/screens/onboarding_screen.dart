import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ----------- Circular Logo -----------
                Container(
                  height: height * 0.20,
                  width: height * 0.20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.indigo, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.asset("assets/logo.jpeg", fit: BoxFit.cover),
                  ),
                ),

                SizedBox(height: height * 0.04),

                // ---------- Title ----------
                Text(
                  "Welcome to Edusaint",
                  style: TextStyle(
                    fontSize: width * 0.055,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade900,
                  ),
                ),

                SizedBox(height: height * 0.08),

                // ---------- "Get Started" Button ----------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      side: const BorderSide(color: Colors.indigo, width: 2),
                      padding: EdgeInsets.symmetric(vertical: height * 0.018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.indigo.shade900,
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),

                // ---------- "Already have account" Button ----------
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.indigo, width: 2),
                      padding: EdgeInsets.symmetric(vertical: height * 0.018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "I already have an account",
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Colors.indigo.shade900,
                        fontWeight: FontWeight.w500,
                      ),
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
}
