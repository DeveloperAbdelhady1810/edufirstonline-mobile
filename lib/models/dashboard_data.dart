/// "Continue watching" card on the home dashboard - the most recently
/// touched, not-yet-complete lecture. Null on the API when a student hasn't
/// started anything yet (handled by simply hiding the section, not showing
/// placeholder content).
class ContinueWatching {
  ContinueWatching({
    required this.courseId,
    required this.lectureId,
    required this.courseTitle,
    required this.lectureTitle,
    this.subject = '',
    this.grade = '',
    this.teacherName,
    this.thumbnail,
    this.progressPercentage = 0,
    this.sectionPosition,
    this.totalSections,
  });

  final int courseId;
  final int lectureId;
  final String courseTitle;
  final String lectureTitle;
  final String subject;
  final String grade;
  final String? teacherName;
  final String? thumbnail;
  final int progressPercentage;
  final int? sectionPosition;
  final int? totalSections;

  factory ContinueWatching.fromJson(Map<String, dynamic> json) => ContinueWatching(
        courseId: json['course_id'] as int,
        lectureId: json['lecture_id'] as int,
        courseTitle: json['course_title'] as String? ?? '',
        lectureTitle: json['lecture_title'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        grade: json['grade'] as String? ?? '',
        teacherName: json['teacher_name'] as String?,
        thumbnail: json['thumbnail'] as String?,
        progressPercentage: (json['progress_percentage'] as num?)?.toInt() ?? 0,
        sectionPosition: (json['section_position'] as num?)?.toInt(),
        totalSections: (json['total_sections'] as num?)?.toInt(),
      );
}

class UpNextLecture {
  UpNextLecture({
    required this.courseId,
    required this.lectureId,
    required this.lectureTitle,
    this.videoDuration,
  });

  final int courseId;
  final int lectureId;
  final String lectureTitle;
  final int? videoDuration;

  factory UpNextLecture.fromJson(Map<String, dynamic> json) => UpNextLecture(
        courseId: json['course_id'] as int,
        lectureId: json['lecture_id'] as int,
        lectureTitle: json['lecture_title'] as String? ?? '',
        videoDuration: (json['video_duration'] as num?)?.toInt(),
      );
}

class DashboardData {
  DashboardData({
    this.enrolled = 0,
    this.completed = 0,
    this.streak = 0,
    this.continueWatching,
    this.upNext,
  });

  final int enrolled;
  final int completed;
  final int streak;
  final ContinueWatching? continueWatching;
  final UpNextLecture? upNext;

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        enrolled: (json['enrolled'] as num?)?.toInt() ?? 0,
        completed: (json['completed'] as num?)?.toInt() ?? 0,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        continueWatching: json['continueWatching'] is Map<String, dynamic>
            ? ContinueWatching.fromJson(json['continueWatching'] as Map<String, dynamic>)
            : null,
        upNext: json['upNext'] is Map<String, dynamic>
            ? UpNextLecture.fromJson(json['upNext'] as Map<String, dynamic>)
            : null,
      );
}
