import 'course.dart';

/// A course bundle. Two endpoints return slightly different shapes (list
/// vs. detail) - this model accepts either by checking for the field each
/// one actually provides instead of assuming one fixed shape.
class CoursePackage {
  CoursePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.stage = '',
    this.grade = '',
    this.teacherName = '',
    this.coursesCount,
    this.courses,
    this.alreadyPurchased,
  });

  final int id;
  final String name;
  final String description;
  final String price;
  final String stage;
  final String grade;
  final String teacherName;
  final int? coursesCount;
  final List<CourseSummary>? courses;
  final bool? alreadyPurchased;

  factory CoursePackage.fromJson(Map<String, dynamic> json) {
    final teacherJson = json['teacher'];
    final teacherName = json['teacher_name'] as String? ??
        (teacherJson is Map<String, dynamic> ? (teacherJson['name'] as String? ?? '') : '');

    return CoursePackage(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: '${json['price'] ?? '0'}',
      stage: json['stage'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      teacherName: teacherName,
      coursesCount: (json['courses_count'] as num?)?.toInt(),
      courses: json['courses'] is List
          ? (json['courses'] as List)
              .map((e) => CourseSummary.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      alreadyPurchased: json['already_purchased'] as bool?,
    );
  }

  int get courseCount => coursesCount ?? courses?.length ?? 0;
}
