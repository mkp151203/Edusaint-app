import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:edusaint/screens/settings.dart';
import 'package:edusaint/screens/notification.dart';
import 'package:edusaint/screens/leaderboard.dart';
import 'package:http/http.dart' as http;

class TopNavBar extends StatefulWidget implements PreferredSizeWidget {
  final Color color;
  final Function(int classId) onClassSelected;

  const TopNavBar({
    super.key,
    required this.color,
    required this.onClassSelected,
  });

  @override
  State<TopNavBar> createState() => _TopNavBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

class _TopNavBarState extends State<TopNavBar>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> classes = [];
  Map<String, dynamic>? selectedClass;

  bool isLoadingClasses = true;
  bool _initialCallbackDone = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    fetchClasses();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onIconTap(VoidCallback onPressed) {
    _controller.forward(from: 0);
    onPressed();
  }

  // ================= API CALL =================
  Future<void> fetchClasses() async {
    if (!mounted) return;
    setState(() => isLoadingClasses = true);

    try {
      final res = await http.get(
        Uri.parse('https://byte.edusaint.in/api/v1/classes'),
      );

      final Map<String, dynamic> json =
          jsonDecode(res.body) as Map<String, dynamic>;

      // ✅ FIX: support both `data` & `classes`
      final List? data = json['data'] ?? json['classes'];

      if (data != null && data.isNotEmpty) {
        classes = data
            .map<Map<String, dynamic>>(
              (e) => Map<String, dynamic>.from(e as Map),
            )
            .toList();

        selectedClass ??= classes.first;

        // ✅ fire callback ONLY ONCE
        if (!_initialCallbackDone && selectedClass != null) {
          final classId = int.tryParse(selectedClass!['id'].toString());
          if (classId != null) {
            _initialCallbackDone = true;
            widget.onClassSelected(classId);
          }
        }
      } else {
        classes = [];
        selectedClass = null;
      }
    } catch (e) {
      debugPrint("Class fetch error: $e");
    }

    if (!mounted) return;
    setState(() => isLoadingClasses = false);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0A0A0F).withOpacity(0.95),
                const Color(0xFF101A36).withOpacity(0.85),
                widget.color.withOpacity(0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.15),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildLogo(), _buildRightSection(context)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: const [
        Icon(Icons.school, color: Colors.white),
        SizedBox(width: 8),
        Text(
          "EduSaint",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRightSection(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          alignment: Alignment.center,
          child: isLoadingClasses
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: selectedClass,
                    dropdownColor: const Color(0xFF0E152B),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() => selectedClass = value);

                      final classId = int.tryParse(value['id'].toString());
                      if (classId != null) {
                        widget.onClassSelected(classId);
                      }
                    },
                    items: classes.map((cls) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: cls,
                        child: Text(
                          cls['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
        _icon(Icons.notifications, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          );
        }),
        _icon(Icons.emoji_events, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
          );
        }),
        _icon(Icons.settings, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        }),
      ],
    );
  }

  Widget _icon(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => _onIconTap(onTap),
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 0.85).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
          ),
          child: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
