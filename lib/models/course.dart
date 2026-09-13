import '../utils/json_num.dart';

/// A published course as returned by the public `GET /courses` list and
/// (in a lighter shape) inside package details. Field names match the raw
/// column aliases the backend selects - confirmed live against production.
class CourseSummary {
  CourseSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.grade,
    required this.subject,
    this.views = 0,
    this.teacherName = '',
    this.teacherAvatar,
    this.isFree = false,
  });

  final int id;
  final String title;
  final String description;
  final String price;
  final String grade;
  final String subject;
  final int views;
  final String teacherName;
  final String? teacherAvatar;
  final bool isFree;

  factory CourseSummary.fromJson(Map<String, dynamic> json) => CourseSummary(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: '${json['price'] ?? '0'}',
        grade: json['grade'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        views: asInt(json['views']) ?? 0,
        teacherName: json['teacher_name'] as String? ?? '',
        teacherAvatar: json['teacher_avatar'] as String?,
        isFree: json['is_free'] == true || json['is_free'] == 1,
      );
}

/// One lecture inside a course/section - shape varies slightly by which
/// endpoint returned it (progress fields only appear for an enrolled
/// student's own view), so every progress-related field is nullable.
class LectureSummary {
  LectureSummary({
    required this.id,
    required this.title,
    required this.type,
    this.isFree = false,
    this.videoDuration,
    this.order = 0,
    this.completed = false,
    this.lastPosition,
    this.progressPercentage,
  });

  final int id;
  final String title;

  /// One of: video, external_link, document_link, live_session.
  final String type;
  final bool isFree;
  final int? videoDuration;
  final int order;
  final bool completed;
  final int? lastPosition;
  final int? progressPercentage;

  factory LectureSummary.fromJson(Map<String, dynamic> json) => LectureSummary(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        type: json['type'] as String? ?? 'video',
        isFree: json['is_free'] == true || json['is_free'] == 1,
        videoDuration: asInt(json['video_duration']),
        order: asInt(json['order']) ?? 0,
        completed: json['completed'] == true || json['completed'] == 1,
        lastPosition: asInt(json['last_position']),
        progressPercentage: asInt(json['progress_percentage']),
      );
}

class CourseSection {
  CourseSection({
    required this.id,
    required this.title,
    this.order = 0,
    this.lectures = const [],
  });

  final int id;
  final String title;
  final int order;
  final List<LectureSummary> lectures;

  factory CourseSection.fromJson(Map<String, dynamic> json) => CourseSection(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        order: asInt(json['order']) ?? 0,
        lectures: (json['lectures'] as List<dynamic>? ?? [])
            .map((e) => LectureSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  int get completedCount => lectures.where((l) => l.completed).length;
}

/// Full course detail from `GET /courses/{id}`, including its curriculum.
class CourseDetail {
  CourseDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.grade,
    required this.subject,
    this.teacherName = '',
    this.teacherAvatar,
    this.teacherBio,
    this.sections = const [],
    this.isFree = false,
  });

  final int id;
  final String title;
  final String description;
  final String price;
  final String grade;
  final String subject;
  final String teacherName;
  final String? teacherAvatar;
  final String? teacherBio;
  final List<CourseSection> sections;
  final bool isFree;

  factory CourseDetail.fromJson(Map<String, dynamic> json) => CourseDetail(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: '${json['price'] ?? '0'}',
        grade: json['grade'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        teacherName: json['teacher_name'] as String? ?? '',
        teacherAvatar: json['teacher_avatar'] as String?,
        teacherBio: json['teacher_bio'] as String?,
        sections: (json['sections'] as List<dynamic>? ?? [])
            .map((e) => CourseSection.fromJson(e as Map<String, dynamic>))
            .toList(),
        isFree: json['is_free'] == true || json['is_free'] == 1,
      );

  int get lectureCount => sections.fold(0, (sum, s) => sum + s.lectures.length);
}

/// A course the current student is already enrolled in, from `GET
/// /my-courses` - includes a pre-computed average progress percentage.
class MyCourse {
  MyCourse({
    required this.id,
    required this.title,
    required this.grade,
    required this.subject,
    this.teacherName = '',
    this.progress = 0,
  });

  final int id;
  final String title;
  final String grade;
  final String subject;
  final String teacherName;
  final int progress;

  factory MyCourse.fromJson(Map<String, dynamic> json) => MyCourse(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        grade: json['grade'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        teacherName: json['teacher_name'] as String? ?? '',
        // `progress` is a raw SQL `coalesce(round(avg(...)), 0)` expression -
        // MySQL's driver returns that as a numeric STRING, not a JSON
        // number (confirmed - this crashed with a cast error in production
        // before `asInt` was added), unlike the plain integer columns above.
        progress: asInt(json['progress']) ?? 0,
      );
}
