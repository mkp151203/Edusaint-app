class Course {
  final int id;
  final String name;

  Course({required this.id, required this.name});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      name: (json['course_name'] ?? json['name'] ?? "Untitled Course")
          .toString(),
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "course_name": name};
}
