import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'MainScaffold.dart';
import 'learn_screen.dart';

class HomeView extends StatefulWidget {
  final int? classId;

  const HomeView({super.key, this.classId});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int? _classId;
  String studentName = "";
  bool isLoading = true;
  List<Course> courses = [];
  List<ClassItem> classes = [];
  ClassItem? selectedClass;
  String? _authToken; // Store the token

  final List<IconData> icons = [
    Icons.calculate,
    Icons.science_outlined,
    Icons.public,
    Icons.menu_book_rounded,
    Icons.text_fields,
    Icons.computer_rounded,
    Icons.language,
  ];

  final List<Color> colors = const [
    Color(0xFFDCD3FF),
    Color(0xFFA9F0EA),
    Color(0xFFFFD0A6),
    Color(0xFFBFF0C4),
    Color(0xFFFFC1B3),
    Color(0xFFD8DBFF),
  ];

  @override
  void initState() {
    super.initState();

    classes = [
      ClassItem(id: 1, name: "Class 1"),
      ClassItem(id: 2, name: "Class 2"),
      ClassItem(id: 3, name: "Class 3"),
      ClassItem(id: 4, name: "Class 4"),
      ClassItem(id: 5, name: "Class 5"),
      ClassItem(id: 6, name: "Class 6"),
      ClassItem(id: 7, name: "Class 7"),
      ClassItem(id: 8, name: "Class 8"),
      ClassItem(id: 9, name: "Class 9"),
      ClassItem(id: 10, name: "Class 10"),
      ClassItem(id: 11, name: "Class 11"),
      ClassItem(id: 12, name: "Class 12"),
    ];

    // ✅ FIRST set classId
    _classId = 6;

    // ✅ THEN sync selectedClass
    if (classes.isNotEmpty) {
      selectedClass = classes.firstWhere(
        (c) => c.id == _classId,
        orElse: () => classes.first,
      );
    }

    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Get the saved token
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('token');
    
    print('=== HOME VIEW TOKEN ===');
    print('Token loaded: $_authToken');
    print('====================');
    
    if (_authToken == null || _authToken!.isEmpty) {
      print('⚠️ NO TOKEN FOUND - User should not be here!');
    }
    
    loadStudentName();
    loadClasses();
  }

  Future<void> loadStudentName() async {
    if (_authToken == null) return;
    
    try {
      final res = await http.get(
        Uri.parse("https://byte.edusaint.in/api/v1/profile"),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode != 200) return;

      final decoded = jsonDecode(res.body);
      final data = decoded['data'];

      final name = data?['name'] ?? data?['student_name'];
      final fetchedClassId = data?['class_id'];

      if (!mounted) return;

      setState(() {
        studentName = name ?? "Student";
        // ❌ dropdown-selected class ko override mat karo
        if (_classId == null && fetchedClassId != null) {
          _classId = fetchedClassId;
        }
      });

      await loadCourses(); // ✅ SINGLE CALL
    } catch (e) {
      debugPrint("Profile error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> loadClasses() async {
    if (_authToken == null) return;
    
    try {
      final res = await http.get(
        Uri.parse('https://byte.edusaint.in/api/v1/classes'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode != 200) return;

      final decoded = jsonDecode(res.body);
      final List data = decoded['data'] ?? [];

      // 🔴 API EMPTY → fallback to local classes
      if (data.isEmpty) {
        debugPrint("Classes API returned empty list → using fallback");

        if (classes.isEmpty) {
          classes = [
            ClassItem(id: 1, name: "Class 1"),
            ClassItem(id: 2, name: "Class 2"),
            ClassItem(id: 3, name: "Class 3"),
            ClassItem(id: 4, name: "Class 4"),
            ClassItem(id: 5, name: "Class 5"),
            ClassItem(id: 6, name: "Class 6"),
            ClassItem(id: 7, name: "Class 7"),
            ClassItem(id: 8, name: "Class 8"),
            ClassItem(id: 9, name: "Class 9"),
            ClassItem(id: 10, name: "Class 10"),
            ClassItem(id: 11, name: "Class 11"),
            ClassItem(id: 12, name: "Class 12"),
          ];
        }

        // sync dropdown safely
        selectedClass = classes.firstWhere(
          (c) => c.id == (_classId ?? classes.first.id),
          orElse: () => classes.first,
        );

        _classId = selectedClass!.id;

        if (mounted) setState(() {});
        return;
      }

      // 🟢 API HAS DATA
      classes = data.map((e) => ClassItem.fromJson(e)).toList();

      selectedClass = classes.firstWhere(
        (c) => c.id == (_classId ?? classes.first.id),
        orElse: () => classes.first,
      );

      _classId = selectedClass!.id;

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Class error: $e");
    }
  }

  Future<void> loadCourses() async {
    if (_classId == null) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.get(
        Uri.parse("https://byte.edusaint.in/api/v1/classes/$_classId/courses"),
        headers: {
          'Authorization': 'Bearer ${_authToken ?? ""}',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode != 200) throw "API error";

      final decoded = jsonDecode(res.body);
      List data = decoded['data'] ?? [];

      courses = data.map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      courses = [];
      debugPrint("Course error: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  Widget buildPremiumHeader() {
    final progress = courses.isEmpty ? 0.0 : courses.first.progress;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5B6CFF), Color(0xFF4B1FD6)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, ${studentName.isEmpty ? "Student" : studentName}! 👋",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Ready for today’s learning?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Daily Goal",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContinueLearning(double w, bool isSmall, Color themeColor) {
    if (courses.isEmpty) return const SizedBox();
    final course = courses.first;
    final progress = course.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Continue Learning",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2B57),
          ),
        ),
        SizedBox(height: w * 0.04),
        Container(
          padding: EdgeInsets.all(w * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B6CFF), Color(0xFF6A4BFF)],
                  ),
                ),
              ),
              SizedBox(height: w * 0.04),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.lastSubject,
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          course.lastTopic,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LearnScreen(
                            subject: course.lastSubject,
                            courseId: course.id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF6A4BFF), Color(0xFF5B6CFF)],
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: w * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Progress",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A4BFF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE9ECF2),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF4F7BFF)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF1B2B57);

    return MainScaffold(
      selectedIndex: 3,
      bodyBuilder: (selectedClassId) {
        final filteredCourses = courses;

        return RefreshIndicator(
          onRefresh: () async {
            if (_classId != null) await loadCourses();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPremiumHeader(),
                const SizedBox(height: 20),
                if (!isLoading) buildContinueLearning(400, false, themeColor),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Subjects",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2B57),
                      ),
                    ),

                    // 👉 Classes Dropdown (RIGHT SIDE)
                    DropdownButtonHideUnderline(
                      child: DropdownButton<ClassItem>(
                        key: ValueKey(selectedClass?.id),
                        value: selectedClass,

                        hint: const Text(
                          "Class",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1B2B57),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF1B2B57),
                        ),
                        items: classes.map((cls) {
                          return DropdownMenuItem<ClassItem>(
                            value: cls,
                            child: Text(
                              cls.name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1B2B57),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (cls) async {
                          if (cls == null) return;

                          setState(() {
                            selectedClass = cls;
                            _classId = cls.id;
                            courses.clear();
                            isLoading = true;
                          });

                          await loadCourses(); // 🔥 SAME FLOW
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredCourses.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.85,
                        ),
                    itemBuilder: (context, i) {
                      final course = filteredCourses[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LearnScreen(
                              subject: course.name,
                              courseId: course.id,
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors[i % colors.length],
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 12,
                                offset: Offset(6, 8),
                              ),
                              BoxShadow(
                                color: Color(0xFFFFFFFF),
                                blurRadius: 6,
                                offset: Offset(-4, -4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 46,
                                width: 46,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x11000000),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  icons[i % icons.length],
                                  size: 24,
                                  color: themeColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  course.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Course {
  final int id;
  final String name;
  final double progress;
  final String lastTopic;
  final String lastSubject;

  Course({
    required this.id,
    required this.name,
    required this.progress,
    required this.lastTopic,
    required this.lastSubject,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    double progress = 0.0;

    return Course(
      id: json['id'] ?? 0,
      name: json['title'] ?? 'Untitled Course',
      progress: progress,
      lastTopic: json['description']?.toString().isNotEmpty == true
          ? json['description']
          : 'Start your first lesson',
      lastSubject: json['category'] ?? 'General',
    );
  }
}

class ClassItem {
  final int id;
  final String name;

  ClassItem({required this.id, required this.name});

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      id: json['id'],
      name: json['name'] ?? json['title'] ?? 'Class',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
