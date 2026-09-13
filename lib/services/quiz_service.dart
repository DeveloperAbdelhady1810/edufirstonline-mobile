import '../models/quiz.dart';
import 'api_client.dart';

class QuizService {
  QuizService._();
  static final QuizService instance = QuizService._();

  Future<List<QuizSummary>> courseQuizzes(int courseId) async {
    final data = await ApiClient.instance.get('/courses/$courseId/quizzes') as List<dynamic>;
    return data.map((e) => QuizSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Starting a quiz (fetching it) also opens the attempt server-side.
  Future<QuizDetail> startQuiz(int quizId) async {
    final data = await ApiClient.instance.get('/quizzes/$quizId') as Map<String, dynamic>;
    return QuizDetail.fromJson(data);
  }

  /// [answers] maps question id -> chosen letter (A/B/C/D).
  Future<void> submitQuiz(int quizId, Map<int, String> answers) {
    return ApiClient.instance.post('/quizzes/$quizId/submit', {
      'answers': answers.map((key, value) => MapEntry('$key', value)),
    });
  }

  Future<QuizResult> quizResult(int quizId) async {
    final data = await ApiClient.instance.get('/quizzes/$quizId/result') as Map<String, dynamic>;
    return QuizResult.fromJson(data);
  }
}
