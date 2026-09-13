import '../models/package.dart';
import '../models/teacher.dart';
import 'api_client.dart';

/// Packages and teacher-directory browsing.
class DirectoryService {
  DirectoryService._();
  static final DirectoryService instance = DirectoryService._();

  Future<List<CoursePackage>> packages({String? stage, String? grade}) async {
    final data = await ApiClient.instance.get('/packages', query: {
      if (stage != null && stage.isNotEmpty) 'stage': stage,
      if (grade != null && grade.isNotEmpty) 'grade': grade,
    }) as Map<String, dynamic>;

    return (data['data'] as List<dynamic>)
        .map((e) => CoursePackage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CoursePackage> packageDetail(int packageId) async {
    final data = await ApiClient.instance.get('/packages/$packageId') as Map<String, dynamic>;
    return CoursePackage.fromJson(data);
  }

  Future<List<TeacherProfile>> teachers({String? search}) async {
    final data = await ApiClient.instance.get('/teachers', query: {
      if (search != null && search.isNotEmpty) 'search': search,
    }) as Map<String, dynamic>;

    return (data['data'] as List<dynamic>)
        .map((e) => TeacherProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TeacherProfile> teacherDetail(int teacherId) async {
    final data = await ApiClient.instance.get('/teachers/$teacherId') as Map<String, dynamic>;
    return TeacherProfile.fromJson(data);
  }
}
