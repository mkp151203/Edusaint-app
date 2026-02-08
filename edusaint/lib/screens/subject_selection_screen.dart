import 'package:flutter/material.dart';
import 'home_view.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  String selectedSyllabus = "CBSE";
  String selectedClass = "8th";
  List<String> selectedSubjects = [];
  String? secondLang;
  String? thirdLang;

  final subjects = [
    "Science",
    "Mathematics",
    "Social Science",
    "English",
    "General Knowledge",
    "Computer Science",
  ];

  final languages = ["Hindi", "Sanskrit", "French", "German", "Tamil"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
        title: const Text("Setup Your Profile"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Select Syllabus",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: selectedSyllabus,
              items: [
                "CBSE",
                "ICSE",
                "State Board",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => selectedSyllabus = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Class",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: selectedClass,
              items: [
                "3rd",
                "4th",
                "5th",
                "6th",
                "7th",
                "8th",
                "9th",
                "10th",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => selectedClass = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Subjects",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: subjects
                    .map(
                      (sub) => CheckboxListTile(
                        title: Text(sub),
                        value: selectedSubjects.contains(sub),
                        activeColor: Colors.blueAccent,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedSubjects.add(sub);
                            } else {
                              selectedSubjects.remove(sub);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Second Language",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: secondLang,
              hint: const Text("Select"),
              items: languages
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => secondLang = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Third Language",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: thirdLang,
              hint: const Text("Select"),
              items: languages
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => thirdLang = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeView()),
                );
              },
              child: const Text("Continue", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
