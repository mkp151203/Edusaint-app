import 'package:edusaint/screens/widgets/bottom_nav_bar.dart';
import 'package:edusaint/screens/widgets/top_nav_bar.dart';
import 'package:flutter/material.dart';

class MainScaffold extends StatefulWidget {
  /// Either provide a direct body widget
  final Widget? body;

  /// Or provide a bodyBuilder (priority if both provided)
  final Widget Function(int? selectedClassId)? bodyBuilder;

  final int selectedIndex;

  const MainScaffold({
    super.key,
    this.body,
    this.bodyBuilder,
    required this.selectedIndex,
  }) : assert(
         body != null || bodyBuilder != null,
         'Either body or bodyBuilder must be provided',
       );

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  int? selectedClassId;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    // ✅ Priority: bodyBuilder > body
    if (widget.bodyBuilder != null) {
      try {
        content = widget.bodyBuilder!(selectedClassId);
      } catch (e) {
        debugPrint("ERROR in bodyBuilder: $e");
        content = const Center(child: Text("Error loading content"));
      }
    } else {
      content = widget.body!;
    }

    return Scaffold(
      appBar: TopNavBar(
        color: const Color(0xFFB7C6FF),
        onClassSelected: (classId) {
          debugPrint("SELECTED CLASS ID => $classId");
          if (!mounted) return;
          setState(() {
            selectedClassId = classId;
          });
        },
      ),

      body: content,

      bottomNavigationBar: BottomNavBar(
        selectedIndex: _currentIndex,
        color: const Color(0xFFB7C6FF),
      ),
    );
  }
}
