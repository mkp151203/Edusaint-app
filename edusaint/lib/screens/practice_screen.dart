import 'package:flutter/material.dart';
import 'MainScaffold.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  Widget build(BuildContext context) {
    final Color themeColor = const Color(0xFF1B2B57);

    final List<Map<String, dynamic>> topResults = [
      {
        'subject': 'Science',
        'score': '80%',
        'color1': Colors.greenAccent,
        'color2': Colors.green,
        'rank': '🥇',
      },
      {
        'subject': 'English',
        'score': '78%',
        'color1': Colors.lightBlueAccent,
        'color2': Colors.blue,
        'rank': '🥈',
      },
      {
        'subject': 'G.K',
        'score': '75%',
        'color1': Colors.orangeAccent,
        'color2': Colors.deepOrange,
        'rank': '🥉',
      },
    ];

    final subjects = [
      "Maths",
      "Science",
      "Social Science",
      "English",
      "Hindi",
      "Computer Science",
      "General Knowledge",
    ];

    final subjectIcons = [
      Icons.calculate,
      Icons.science,
      Icons.public,
      Icons.menu_book,
      Icons.language,
      Icons.computer,
      Icons.lightbulb,
    ];

    final subjectColors = [
      const Color(0xFFD8C8FF),
      const Color(0xFFA5F0E9),
      const Color(0xFFFFC9A3),
      const Color(0xFFB3E5BE),
      const Color(0xFFFFB6A3),
      const Color(0xFFD5D4FF),
      const Color(0xFFFFECA3),
    ];

    return MainScaffold(
      selectedIndex: 2,

      // ✅ ONLY bodyBuilder (as MainScaffold expects)
      bodyBuilder: (int? selectedClassId) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isSmall = width < 360;
            final bool isLarge = width > 600;
            final double fontScale = width / 400;

            int gridCount = 3;
            if (isSmall) gridCount = 2;
            if (isLarge) gridCount = 4;

            return SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(width * 0.05),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Try Improving Social Studies",
                          style: TextStyle(
                            fontSize: 16 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: width * 0.02),
                        Text(
                          "Attend a test on History to boost your XP",
                          style: TextStyle(
                            fontSize: 14 * fontScale,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: width * 0.05),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: width * 0.03,
                                horizontal: width * 0.1,
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              "Start",
                              style: TextStyle(
                                color: const Color(0xFF4CAF50),
                                fontSize: 15 * fontScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: width * 0.07),

                  Text(
                    "All Subjects",
                    style: TextStyle(
                      fontSize: 20 * fontScale,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),

                  SizedBox(height: width * 0.04),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subjects.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridCount,
                      mainAxisSpacing: width * 0.04,
                      crossAxisSpacing: width * 0.04,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: subjectColors[index],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${subjects[index]} button is tapped',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: themeColor,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.03),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  subjectIcons[index],
                                  color: themeColor,
                                  size: width * 0.1,
                                ),
                                SizedBox(height: width * 0.03),
                                Text(
                                  subjects[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isSmall ? 12 : 14 * fontScale,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: width * 0.08),

                  Text(
                    "Top Results",
                    style: TextStyle(
                      fontSize: 20 * fontScale,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),

                  SizedBox(height: width * 0.04),

                  SizedBox(
                    height: width * 0.5,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: topResults.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: width * 0.04),
                      itemBuilder: (context, index) {
                        final result = topResults[index];
                        final scoreRaw = result['score'];
                        final score =
                            double.parse(scoreRaw.replaceAll('%', '')) / 100;

                        return Container(
                          width: width * 0.45,
                          padding: EdgeInsets.all(width * 0.04),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [result['color1'], result['color2']],
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                result['rank'],
                                style: TextStyle(
                                  fontSize: 28 * fontScale,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(Icons.emoji_events, color: Colors.white),
                              Text(
                                result['subject'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Score: $scoreRaw",
                                style: const TextStyle(color: Colors.white),
                              ),
                              LinearProgressIndicator(
                                value: score,
                                color: Colors.white,
                                backgroundColor: Colors.white.withOpacity(0.3),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
