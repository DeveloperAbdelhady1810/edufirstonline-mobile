import 'course.dart';

class TeacherProfile {
  TeacherProfile({
    required this.id,
    required this.name,
    this.avatar,
    this.bio,
    this.teacherType = 'normal',
    this.subjects = const [],
    this.educationStages = const [],
    this.courses = const [],
    this.isFollowing = false,
  });

  final int id;
  final String name;
  final String? avatar;
  final String? bio;
  final String teacherType;
  final List<String> subjects;
  final List<String> educationStages;
  final List<CourseSummary> courses;
  final bool isFollowing;

  factory TeacherProfile.fromJson(Map<String, dynamic> json) => TeacherProfile(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        avatar: json['avatar'] as String?,
        bio: json['bio'] as String?,
        teacherType: json['teacher_type'] as String? ?? 'normal',
        subjects: _stringList(json['subjects']),
        educationStages: _stringList(json['education_stages']),
        courses: json['courses'] is List
            ? (json['courses'] as List)
                .map((e) => CourseSummary.fromJson(e as Map<String, dynamic>))
                .toList()
            : const [],
        isFollowing: json['is_following'] == true,
      );

  static List<String> _stringList(dynamic value) {
    if (value is List) return value.map((e) => '$e').toList();
    return const [];
  }

  bool get isPremium => teacherType == 'premium';
}
