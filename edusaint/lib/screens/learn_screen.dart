import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'MainScaffold.dart';
import 'chapter_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  final int courseId;
  final String subject;

  const LearnScreen({
    super.key,
    this.courseId = 4,
    this.subject = "Mathematics",
  });

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  List<Map<String, dynamic>> chapters = [];
  bool isLoading = true;

  String get apiUrl =>
      'https://byte.edusaint.in/api/v1/courses/${widget.courseId}/lessons';

  @override
  void initState() {
    super.initState();
    fetchLessons();
  }

  Future<void> fetchLessons() async {
    try {
      final res = await http.get(Uri.parse(apiUrl));
      final List data = jsonDecode(res.body)['data'];

      final parsed = data.map<Map<String, dynamic>>((item) {
        final int id = int.tryParse(item['id'].toString()) ?? 0;
        final title = (item['title'] ?? item['topic_name'] ?? 'Lesson $id')
            .toString();
        final double progress = item['progress'] != null
            ? (item['progress'] as num).toDouble().clamp(0.0, 1.0)
            : item['completion_percentage'] != null
            ? ((item['completion_percentage'] as num) / 100).clamp(0.0, 1.0)
            : item['is_completed'] == true
            ? 1.0
            : 0.0;
        final bool isCompleted = progress >= 1.0;

        return {
          "id": id,
          "title": title,
          "progress": progress,
          "isCompleted": isCompleted,
          "description": item['description'] ?? '',
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        chapters = parsed;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void onChapterTap(String chapter, int lessonId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterDetailScreen(
          subject: widget.subject,
          chapter: chapter,
          lessonId: lessonId,
          courseId: widget.courseId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return MainScaffold(
      selectedIndex: 1,
      bodyBuilder: (_) {
        return isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * .05,
                      vertical: h * .015,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        Text(
                          widget.subject,
                          style: TextStyle(
                            fontSize: w * .052,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: w * .04,
                            vertical: h * .008,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade200,
                                Colors.blue.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "38%",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: w * .05),
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        final title = chapter['title'];
                        final progress = chapter['progress'];
                        final isCompleted = chapter['isCompleted'];

                        return GestureDetector(
                          onTap: () => onChapterTap(title, chapter['id']),
                          child: Container(
                            margin: EdgeInsets.only(bottom: h * .028),
                            padding: EdgeInsets.all(w * .05),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: LinearGradient(
                                colors: isCompleted
                                    ? [
                                        Colors.green.shade50,
                                        Colors.green.shade100,
                                      ]
                                    : [
                                        Colors.orange.shade50,
                                        Colors.orange.shade100,
                                      ],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Chapter ${index + 1}",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        isCompleted
                                            ? "Completed"
                                            : "In Progress",
                                        style: TextStyle(
                                          color: isCompleted
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: w * .046,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 7,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation(
                                    isCompleted ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
      },
    );
  }
}
