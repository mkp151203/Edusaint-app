import 'package:flutter/material.dart';
import 'MainScaffold.dart';

class EdusaintView extends StatelessWidget {
  const EdusaintView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: 2,
      bodyBuilder: (_) => const _EdusaintBody(),
    );
  }
}

class _EdusaintBody extends StatelessWidget {
  const _EdusaintBody();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0A0F).withOpacity(0.92),
            const Color(0xFF1A2339).withOpacity(0.85),
            const Color(0xFFB7C6FF).withOpacity(0.65),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.06,
            vertical: height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TITLE
              Text(
                "Welcome to Edusaint",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.075,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.02),
              // DESCRIPTION
              Text(
                "Our App helps students from Classes 1-10 master subjects with short, easy to understand lessons, daily practice, and fun interactive activities.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.90),
                  fontSize: width * 0.043,
                  height: 1.4,
                ),
              ),
              SizedBox(height: height * 0.04),
              // WHAT WE OFFER
              Text(
                "What we Offer",
                style: TextStyle(
                  fontSize: width * 0.065,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: height * 0.02),

              /// HORIZONTAL SCROLLABLE OFFER CARDS
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    offerCard("Bite Sized\nLessons"),
                    SizedBox(width: 12),
                    offerCard("Practice that\nBuilds Skill"),
                    SizedBox(width: 12),
                    offerCard("Daily\nProgress Tracking"),
                  ],
                ),
              ),
              SizedBox(height: height * 0.04),
              // UNLOCK EXPERIENCE
              Text(
                "Unlock the full\nLearning Experience",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.065,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                "Premium learners finish more chapters, build stronger subject foundations, and practice better with unlimited access.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.043,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
              SizedBox(height: height * 0.04),
              // PLANS (MATCHED TO SCREENSHOT)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: planCard(
                      title: "Yearly",
                      trial: "14-day free trial",
                      price: "₹ 999/Year",
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: planCard(
                      title: "Monthly",
                      trial: "7-day free trial",
                      price: "₹ 199/Month",
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  /// OFFER CARD
  Widget offerCard(String text) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2234),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// PLAN CARD (FULLY MATCHED UI)
  Widget planCard({
    required String title,
    required String trial,
    required String price,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9FB4FF), Color(0xFF728BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trial,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: const TextStyle(
              fontSize: 21,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1636),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Choose Plan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
