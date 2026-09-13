import '../models/course.dart';
import '../models/dashboard_data.dart';
import 'api_client.dart';

/// Courses/dashboard/progress endpoints - the "student is learning"
/// surface of the API (browse, enroll status, lecture progress).
class ContentService {
  ContentService._();
  static final ContentService instance = ContentService._();

  Future<List<CourseSummary>> browseCourses({String? grade, String? subject, String? search}) async {
    final data = await ApiClient.instance.get('/courses', query: {
      if (grade != null && grade.isNotEmpty) 'grade': grade,
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      if (search != null && search.isNotEmpty) 'search': search,
    }) as Map<String, dynamic>;

    return (data['data'] as List<dynamic>)
        .map((e) => CourseSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CourseDetail> courseDetail(int courseId) async {
    final data = await ApiClient.instance.get('/courses/$courseId') as Map<String, dynamic>;
    return CourseDetail.fromJson(data);
  }

  Future<List<MyCourse>> myCourses() async {
    final data = await ApiClient.instance.get('/my-courses') as List<dynamic>;
    return data.map((e) => MyCourse.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CourseSection>> myCourseLectures(int courseId) async {
    final data = await ApiClient.instance.get('/my-courses/$courseId/lectures') as List<dynamic>;
    return data.map((e) => CourseSection.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markLectureComplete(int lectureId) {
    return ApiClient.instance.post('/lectures/$lectureId/complete');
  }

  Future<void> saveLectureProgress(int lectureId, {required int position, required int percentage}) {
    return ApiClient.instance.post('/lectures/$lectureId/progress', {
      'position': position,
      'percentage': percentage,
    });
  }

  Future<DashboardData> dashboard() async {
    final data = await ApiClient.instance.get('/dashboard') as Map<String, dynamic>;
    return DashboardData.fromJson(data);
  }
}
