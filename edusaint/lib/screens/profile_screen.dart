import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'edit_view.dart';
import 'MainScaffold.dart';
import 'package:edusaint/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String userClass = "";
  String profileImage = "";

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return;

    final data = await ProfileService.getProfile(token);

    if (data != null && data["data"] != null) {
      setState(() {
        name = data["data"]["name"] ?? "";
        userClass = data["data"]["class"] ?? "";
        profileImage = data["data"]["image"] != null
            ? "https://byte.edusaint.in${data["data"]["image"]}"
            : "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final themeColor = const Color(0xFF1B2B57);

    return MainScaffold(
      selectedIndex: 3,
      bodyBuilder: (int? selectedClassId) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFF3F6FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.05),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildGlassCard(
                  width,
                  child: Row(
                    children: [
                      Hero(
                        tag: 'profile_pic',
                        child: CircleAvatar(
                          radius: width * 0.12,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          backgroundImage: profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : const AssetImage("assets/images/profile.png")
                                    as ImageProvider,
                        ),
                      ),
                      SizedBox(width: width * 0.05),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isNotEmpty ? name : "Loading...",
                              style: TextStyle(
                                fontSize: width * 0.055,
                                fontWeight: FontWeight.w700,
                                color: themeColor,
                              ),
                            ),
                            SizedBox(height: width * 0.01),
                            Text(
                              userClass.isNotEmpty ? userClass : "Fetching...",
                              style: TextStyle(
                                fontSize: width * 0.042,
                                color: themeColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        iconSize: width * 0.075,
                        icon: const Icon(
                          Icons.qr_code_2_rounded,
                          color: Color(0xFF1B2B57),
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        iconSize: width * 0.075,
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: Color(0xFF1B2B57),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 500,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      FadeTransition(
                                        opacity: animation,
                                        child: const EditProfileScreen(),
                                      ),
                            ),
                          );
                          _loadProfile();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildGlassCard(
                  width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📊 Your Progress",
                        style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.w700,
                          color: themeColor,
                        ),
                      ),
                      SizedBox(height: width * 0.04),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: width * 0.04,
                        mainAxisSpacing: width * 0.04,
                        childAspectRatio: width < 380 ? 1.2 : 1,
                        children: [
                          _buildProgressItem("🔥", "Streaks", "7 Days"),
                          _buildProgressItem("🎁", "Rewards", "15"),
                          _buildProgressItem("⭐", "XP", "1240"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildGlassCard(
                  width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📅 Weekly Tracker",
                        style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.w700,
                          color: themeColor,
                        ),
                      ),
                      SizedBox(height: width * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTracker("75%", "Lessons Learned"),
                          _buildTracker("68%", "Tests Taken"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildGlassCard(
                  width,
                  color: Colors.yellow[600],
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calculate,
                        color: Colors.black,
                        size: 40,
                      ),
                      SizedBox(width: width * 0.04),
                      Expanded(
                        child: Text(
                          "🎉 Great job!\nMaths was your strongest subject this week.",
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildGlassCard(
                  width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🧭 Your Journey",
                        style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.w700,
                          color: themeColor,
                        ),
                      ),
                      SizedBox(height: width * 0.04),
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(selectedDay, day),
                        onDaySelected: (selected, focused) {
                          setState(() {
                            selectedDay = selected;
                            focusedDay = focused;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: themeColor,
                            shape: BoxShape.circle,
                          ),
                          outsideDaysVisible: false,
                        ),
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          titleTextStyle: TextStyle(
                            color: themeColor,
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _buildGlassCard(
                  width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "💳 Payment Plans",
                        style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: height * 0.32,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildPlanCard(
                              width,
                              "Basic Plan",
                              "₹199/month",
                              "Access to basic quizzes",
                              themeColor,
                            ),
                            _buildPlanCard(
                              width,
                              "Pro Plan",
                              "₹299/month",
                              "Includes premium challenges",
                              themeColor,
                            ),
                            _buildPlanCard(
                              width,
                              "Premium Plan",
                              "₹499/month",
                              "Unlocks all features",
                              themeColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Helper Widgets ----------

  Widget _buildGlassCard(double width, {required Widget child, Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withOpacity(0.7),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildProgressItem(String emoji, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border.all(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1B2B57),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildTracker(String percent, String label) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 70,
              width: 70,
              child: CircularProgressIndicator(
                value: double.parse(percent.replaceAll('%', '')) / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF1B2B57)),
              ),
            ),
            Text(percent, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildPlanCard(
    double width,
    String title,
    String price,
    String description,
    Color themeColor,
  ) {
    return Container(
      width: width * 0.6,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
              color: themeColor,
            ),
          ),
          SizedBox(height: width * 0.02),
          Text(
            price,
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: width * 0.03),
          Text(
            description,
            style: TextStyle(
              fontSize: width * 0.035,
              color: themeColor.withOpacity(0.8),
            ),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () => _showFriendlyPopup(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Buy Now"),
            ),
          ),
        ],
      ),
    );
  }

  void _showFriendlyPopup(String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🎉 Thank You!"),
        content: Text(
          "You selected the $planName.\nWe’ll redirect you to the payment page soon!",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
