import 'dart:ui';
import 'package:flutter/material.dart';
import '../home_view.dart';
import '../learn_screen.dart';
import '../practice_screen.dart';
import '../profile_screen.dart';
import '../edusaint.dart'; // ⬅ REQUIRED FOR LOGO NAVIGATION

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Color color;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.color,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void onTabSelected(int index) {
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);

    Widget screen;

    switch (index) {
      case 0:
        screen = const HomeView();
        break;
      case 1:
        screen = const LearnScreen(subject: "Mathematics", courseId: 4);
        break;
      case 2:
        screen = const EdusaintView();
        break;
      case 3:
        screen = const PracticeScreen();
        break;
      case 4:
        screen = const ProfileScreen();
        break;
      default:
        screen = const HomeView();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A0A0F).withOpacity(0.92),
                  const Color(0xFF1A2339).withOpacity(0.85),
                  widget.color.withOpacity(0.65),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.2,
              ),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              onTap: onTabSelected,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.45),
              items: [
                buildNavItem(Icons.home_filled, "Home", 0),
                buildNavItem(Icons.menu_book_rounded, "Learn", 1),
                buildCenterLogoItem(2), // ⬅ BIG CENTER LOGO FIXED
                buildNavItem(Icons.edit_note_rounded, "Practice", 3),
                buildNavItem(Icons.person_rounded, "Profile", 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NORMAL NAV ITEMS
  BottomNavigationBarItem buildNavItem(IconData icon, String label, int index) {
    bool selected = _currentIndex == index;

    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 45,
        width: 45,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: selected
              ? LinearGradient(
                  colors: [
                    widget.color.withOpacity(0.9),
                    widget.color.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.white.withOpacity(0.07),
          border: Border.all(
            color: Colors.white.withOpacity(selected ? 0.3 : 0.12),
          ),
        ),
        child: Icon(
          icon,
          size: selected ? 26 : 22,
          color: selected ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  // BIG CENTER LOGO ITEM
  BottomNavigationBarItem buildCenterLogoItem(int index) {
    bool selected = _currentIndex == index;

    return BottomNavigationBarItem(
      label: "",
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        height: selected ? 78 : 68,
        width: selected ? 78 : 68,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: selected
              ? LinearGradient(
                  colors: [
                    widget.color.withOpacity(0.95),
                    widget.color.withOpacity(0.65),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.white.withOpacity(0.08),
          border: Border.all(
            color: Colors.white.withOpacity(selected ? 0.4 : 0.18),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.7),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipOval(
          child: Image.asset("assets/logo.jpeg", fit: BoxFit.cover),
        ),
      ),
    );
  }
}
