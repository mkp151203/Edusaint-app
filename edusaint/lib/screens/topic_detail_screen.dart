import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chapter_detail_screen.dart';
import 'package:collection/collection.dart';

class TopicDetailScreen extends StatefulWidget {
  final int courseId;
  final int lessonId;
  final int topicId;
  final String chapter;
  final String subject;

  const TopicDetailScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.topicId,
    required this.chapter,
    required this.subject,
  });

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  String getText(dynamic value) {
    if (value == null) return "";
    if (value is String) return value;
    if (value is List) {
      return value.map((e) => e is Map ? e['text'] ?? "" : "").join(" ");
    }
    if (value is Map) {
      return value['text'] ?? "";
    }
    return value.toString();
  }

  final Map<int, TextEditingController> blankControllers = {};
  Map<int, Map<String, String>> matchSelections =
      {}; // 🔹 store user answers for match-the-following

  Set<String> attemptedQuizIds = {};
  Set<int> submittedCards = {};

  bool isLoading = true;
  bool hasError = false;
  List<Map<String, dynamic>> cards = [];
  int currentIndex = 0;

  // XP & Streak
  int totalXP = 0;
  int streak = 0;
  int maxStreak = 0;

  // Score
  int totalQuizzes = 0;
  int correctAnswers = 0;

  int currentQuizIndex = 0;
  Map<int, int> selectedOptionMap = {};
  Set<int> submittedQuizIndex = {};
  Map<int, bool> quizResultMap = {};

  @override
  void dispose() {
    for (final c in blankControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadCards();
  }

  Future<void> loadCards() async {
    try {
      final url =
          "https://byte.edusaint.in/api/v1/courses/${widget.courseId}/lessons/${widget.lessonId}/topics/${widget.topicId}/cards";

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) throw "Status ${res.statusCode}";

      final decoded = jsonDecode(res.body);
      final List rawCards = decoded['data'];

      final filteredCards = rawCards.where((c) {
        return c is Map && c['topic_id'] == widget.topicId;
      }).toList();

      cards = filteredCards.map((e) => Map<String, dynamic>.from(e)).toList()
        ..sort(
          (a, b) =>
              (a['display_order'] ?? 0).compareTo(b['display_order'] ?? 0),
        );

      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      debugPrint("LOAD ERROR => $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Widget quizFeedbackBox({required bool isCorrect, required String message}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isCorrect
            ? LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100],
              )
            : LinearGradient(colors: [Colors.red.shade50, Colors.red.shade100]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCorrect ? Colors.green : Colors.red),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget premiumImageWidget({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: child, // 👈 image khud apni height decide karegi
      ),
    );
  }

  Widget premiumTextBlock(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.7,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget premiumDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.blue.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 6),
              ],
            ),
            child: const Icon(Icons.star_rounded, size: 14, color: Colors.blue),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.blue.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== PREMIUM CARD UI =====================
  Widget premiumCard({
    required String title,
    required Widget child,
    Color? headerColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: headerColor ?? Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ===================== PREMIUM CONCEPT CARD =====================
  Widget renderConcept(Map<String, dynamic> card) {
    try {
      final raw = card['data_json'];
      if (raw == null) return const Text("No concept available");

      final parsed = raw is String ? jsonDecode(raw) : raw;
      final List blocks = parsed['blocks'] is List ? parsed['blocks'] : [];

      List<Widget> widgets = [];

      for (final b in blocks) {
        if (b == null || b['type'] == null) continue;

        switch (b['type']) {
          case 'image':
            final rawImg = b['url'] ?? b['image'];
            if (rawImg == null) break;

            final String img = rawImg.toString().trim();
            Widget imageWidget;

            if (img.startsWith("data:image")) {
              final base64Str = img.split(',').last;

              imageWidget = premiumImageWidget(
                child: Image.memory(
                  base64Decode(base64Str),
                  width: double.infinity,
                  fit: BoxFit.contain, // 🔥 stretch nahi karega
                ),
              );
            } else if (Uri.tryParse(img)?.isAbsolute == true) {
              imageWidget = premiumImageWidget(
                child: Image.network(
                  img,
                  width: double.infinity,
                  fit: BoxFit.contain, // 🔥 maintain ratio
                  loadingBuilder: (c, child, progress) => progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (c, o, s) => const Icon(
                    Icons.broken_image,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              );
            } else {
              break;
            }

            widgets.add(imageWidget);
            widgets.add(const SizedBox(height: 16));
            break;

          case 'text':
            final text = b['text']?.toString();
            if (text != null && text.isNotEmpty) {
              widgets.add(premiumTextBlock(text));
            }
            break;

          case 'divider':
            widgets.add(premiumDivider());
            break;

          case 'keypoints':
            final points = b['points'] is List ? b['points'] : [];
            if (points.isNotEmpty) {
              widgets.add(
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade50,
                        Colors.green.shade100.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.green.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Key Points",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...points.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.toString(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: Color(0xFF064E3B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }
            break;

          default:
            debugPrint("Unknown block type: ${b['type']}");
        }
      }

      if (widgets.isEmpty) return const Text("No concept available");

      return premiumCard(
        title: "${card['topic_title'] ?? card['title'] ?? widget.chapter}",
        child: Column(children: widgets),
        headerColor: Colors.blue.shade50,
      );
    } catch (e) {
      debugPrint("CONCEPT ERROR => $e");
      return const Text("Invalid concept data");
    }
  }

  String buildQuestionText(Map<String, dynamic> q) {
    // 1️⃣ question object ho to usko use karo, warna q
    final questionObj = q['question'] is Map
        ? q['question'] as Map<String, dynamic>
        : q;

    // 2️⃣ blocks se text build karo
    if (questionObj['blocks'] is List) {
      final blocks = questionObj['blocks'] as List;

      return blocks
          .where((b) => b is Map && b['type'] == 'text')
          .map((b) => b['text']?.toString() ?? "")
          .join(" ");
    }

    // 3️⃣ fallback (agar sirf text aata ho)
    return questionObj['text']?.toString() ?? "Question not available";
  }

  // ===================== PREMIUM QUIZ CARD =====================
  Widget renderQuiz(Map<String, dynamic> card) {
    try {
      final raw = card['data_json'];
      if (raw == null) return const Text("No quiz data");

      final parsed = raw is String ? jsonDecode(raw) : raw;
      final List questions = parsed['questions'] ?? [];

      if (questions.isEmpty) return const Text("No quiz questions");

      final int quizIndex = currentQuizIndex.clamp(0, questions.length - 1);
      final Map<String, dynamic> q =
          questions[quizIndex] as Map<String, dynamic>;

      final Map<String, dynamic> questionObj =
          q['question'] is Map<String, dynamic> ? q['question'] : q;

      final String questionText = buildQuestionText(q);

      final String rawType =
          q['type']?.toString().toLowerCase().trim() ?? 'mcq';

      final bool hasBlankBlock =
          questionObj['blocks'] is List &&
          (questionObj['blocks'] as List).any(
            (b) =>
                b is Map &&
                (b['type'] == 'blank' ||
                    b['type'] == 'fill_blank' ||
                    b['type'] == 'input'),
          );

      final String questionType =
          hasBlankBlock ||
              rawType == 'fill_in_the_blank' ||
              rawType == 'fillblank' ||
              rawType == 'fib'
          ? 'fill_blank'
          : (rawType == 'match_the_following' ? 'match' : 'mcq');

      final List options = q['options'] ?? [];

      final bool submitted = submittedQuizIndex.contains(quizIndex);
      final bool selectedIsCorrect = quizResultMap[quizIndex] ?? false;

      return premiumCard(
        title:
            "${card['topic_title'] ?? card['title']} • Quiz ${quizIndex + 1}/${questions.length}",
        headerColor: Colors.orange.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// ---------- FILL BLANK ----------
            if (questionType == 'fill_blank')
              TextField(
                controller: blankControllers.putIfAbsent(
                  quizIndex,
                  () => TextEditingController(),
                ),
                enabled: !submitted,
                decoration: InputDecoration(
                  hintText: "Type your answer here",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

            /// ---------- MCQ ----------
            if (questionType == 'mcq')
              ...List.generate(options.length, (index) {
                final option = options[index];
                final bool isCorrect =
                    option['is_correct'] == true ||
                    option['is_correct'] == 1 ||
                    option['is_correct'].toString().toLowerCase() == "true";

                final int selectedIndex = selectedOptionMap[quizIndex] ?? -1;

                Color bg = Colors.white;
                Color border = Colors.grey.shade300;
                IconData icon = Icons.radio_button_off;

                if (submitted) {
                  if (isCorrect) {
                    bg = Colors.green.shade50;
                    border = Colors.green;
                    icon = Icons.check_circle;
                  } else if (index == selectedIndex) {
                    bg = Colors.red.shade50;
                    border = Colors.red;
                    icon = Icons.cancel;
                  }
                } else if (index == selectedIndex) {
                  bg = Colors.blue.shade50;
                  border = Colors.blue;
                  icon = Icons.radio_button_checked;
                }

                return GestureDetector(
                  onTap: submitted
                      ? null
                      : () {
                          setState(() {
                            selectedOptionMap[quizIndex] = index;
                          });
                        },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: border),
                        const SizedBox(width: 12),
                        Expanded(child: Text(option['text'] ?? '')),
                      ],
                    ),
                  ),
                );
              }),

            /// ---------- MATCH ----------
            if (questionType == 'match') ..._buildMatchUI(q, quizIndex),

            const SizedBox(height: 12),

            /// ---------- SUBMIT ----------
            if (!submitted)
              ElevatedButton(
                onPressed: () {
                  bool finalIsCorrect = false;

                  if (questionType == 'fill_blank') {
                    final user = blankControllers[quizIndex]?.text
                        .trim()
                        .toLowerCase();
                    if (user == null || user.isEmpty) return;
                    finalIsCorrect =
                        user == q['answer']?.toString().toLowerCase();
                  }

                  if (questionType == 'mcq') {
                    final index = selectedOptionMap[quizIndex] ?? -1;
                    if (index == -1) return;
                    final raw = options[index]['is_correct'];
                    finalIsCorrect =
                        raw == true ||
                        raw == 1 ||
                        raw.toString().toLowerCase() == "true";
                  }

                  if (questionType == 'match') {
                    final userMap = matchSelections[quizIndex] ?? {};
                    final correctMap = Map<String, String>.from(
                      q['answer'] ?? {},
                    );
                    finalIsCorrect = const MapEquality().equals(
                      userMap,
                      correctMap,
                    );
                  }

                  setState(() {
                    submittedQuizIndex.add(quizIndex);
                    quizResultMap[quizIndex] = finalIsCorrect;
                  });
                },
                child: const Text("Submit Answer"),
              ),

            /// ---------- FEEDBACK ----------
            if (submitted)
              quizFeedbackBox(
                isCorrect: selectedIsCorrect,
                message: selectedIsCorrect
                    ? "Correct! +10 XP 🔥"
                    : "Wrong answer. Streak reset.",
              ),
          ],
        ),
      );
    } catch (e) {
      return const Text("Invalid quiz data");
    }
  }

  List<Widget> _buildMatchUI(Map<String, dynamic> q, int quizIndex) {
    final questionObj = q['question'] ?? q;

    final left = List<String>.from(questionObj['left'] ?? []);
    final right = List<String>.from(questionObj['right'] ?? []);
    final correctMap = Map<String, String>.from(questionObj['answer'] ?? {});

    matchSelections.putIfAbsent(quizIndex, () => {});
    final bool submitted = submittedQuizIndex.contains(quizIndex);

    return left.map((l) {
      final userValue = matchSelections[quizIndex]![l];
      final correctValue = correctMap[l];

      bool isCorrect = submitted && userValue == correctValue;
      bool isWrong = submitted && userValue != correctValue;

      Color border = Colors.grey;
      IconData? icon;

      if (isCorrect) {
        border = Colors.green;
        icon = Icons.check_circle;
      } else if (isWrong) {
        border = Colors.red;
        icon = Icons.cancel;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(child: Text(l)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: right.contains(userValue) ? userValue : null,
                items: right
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: submitted
                    ? null
                    : (val) {
                        setState(() {
                          matchSelections[quizIndex]![l] = val!;
                        });
                      },
              ),
            ),
            if (icon != null) Icon(icon, color: border),
          ],
        ),
      );
    }).toList();
  }

  void nextCard() {
    if (currentIndex < cards.length - 1) {
      setState(() {
        currentIndex++;

        // reset quiz state
        currentQuizIndex = 0;
        selectedOptionMap.clear();
        submittedQuizIndex.clear();

        // 🔥 IMPORTANT: clear fill-in-the-blank answers
        blankControllers.forEach((_, c) => c.dispose());
        blankControllers.clear();
        matchSelections.clear();
      });
    } else {
      showLessonSummary();
    }
  }

  void previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;

        // reset quiz state
        currentQuizIndex = 0;
        selectedOptionMap.clear();
        submittedQuizIndex.clear();

        // 🔥 IMPORTANT: clear fill-in-the-blank answers
        blankControllers.forEach((_, c) => c.dispose());
        blankControllers.clear();
        matchSelections.clear();
      });
    }
  }

  void showLessonSummary() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final accuracy = totalQuizzes == 0
            ? 0
            : ((correctAnswers / totalQuizzes) * 100).round();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Lesson Summary 📊",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              summaryRow("Total Quizzes", totalQuizzes.toString()),
              summaryRow("Correct Answers", correctAnswers.toString()),
              summaryRow("Accuracy", "$accuracy%"),
              summaryRow("XP Earned", "$totalXP XP"),
              summaryRow("Max Streak", "🔥 $maxStreak"),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChapterDetailScreen(
                        subject: widget.subject,
                        chapter: widget.chapter,
                        lessonId: widget.lessonId,
                        courseId: widget.courseId,
                      ),
                    ),
                  );
                },
                child: const Text("Continue"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError || cards.isEmpty) {
      return const Scaffold(body: Center(child: Text("No cards available")));
    }

    final card = cards[currentIndex];
    final int cardId = card['id'];
    final bool isQuizSubmitted = submittedCards.contains(cardId);

    return Scaffold(
      backgroundColor: Colors.transparent,

      /// 🧭 AppBar
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white.withOpacity(0.85),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEAF0FF), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              card['card_type'] == 'quiz' ? "Quick Quiz" : "Concept",
              style: TextStyle(
                color: const Color.fromARGB(255, 15, 13, 13),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Text(
                "${currentIndex + 1}/${cards.length}",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      /// 🧩 Body
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F5FF), Color(0xFFE8EEFF), Color(0xFFF9FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),

                /// 📊 Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (currentIndex + 1) / cards.length,
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4A6CF7)),
                  ),
                ),

                const SizedBox(height: 16),

                /// 📦 Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final offsetAnim = Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(animation);

                      return SlideTransition(
                        position: offsetAnim,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: SingleChildScrollView(
                      key: ValueKey("$cardId-$currentQuizIndex"),

                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          if (card['card_type'] == 'concept')
                            renderConcept(card),

                          if (card['card_type'] == 'quiz') renderQuiz(card),
                        ],
                      ),
                    ),
                  ),
                ),

                /// ⏮️ ⏭️ Navigation
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: previousCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Previous",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            (card['card_type'] == 'quiz' && !isQuizSubmitted)
                            ? null
                            : nextCard,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          currentIndex == cards.length - 1
                              ? "Finish Lesson"
                              : "Continue",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
