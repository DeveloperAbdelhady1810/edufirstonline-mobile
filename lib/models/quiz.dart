import '../utils/json_num.dart';

/// One quiz in a course's quiz list (`GET /courses/{course}/quizzes`).
class QuizSummary {
  QuizSummary({
    required this.id,
    required this.title,
    this.description,
    this.passScore = 50,
    this.durationMinutes,
    this.questionCount = 0,
    this.submitted = false,
  });

  final int id;
  final String title;
  final String? description;
  final int passScore;
  final int? durationMinutes;
  final int questionCount;
  final bool submitted;

  factory QuizSummary.fromJson(Map<String, dynamic> json) => QuizSummary(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        passScore: asInt(json['pass_score']) ?? 50,
        durationMinutes: asInt(json['duration_minutes']),
        questionCount: asInt(json['question_count']) ?? 0,
        submitted: json['submitted'] == true,
      );
}

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.questionText,
    this.image,
    this.options = const [],
    this.points = 1,
    this.order = 0,
  });

  final int id;
  final String questionText;
  final String? image;

  /// Raw options as stored (commonly a JSON-decoded map/list of choice
  /// text keyed A/B/C/D) - kept as a dynamic map so this survives whatever
  /// shape the backend actually stores without a brittle strict model.
  final List<MapEntry<String, String>> options;
  final int points;
  final int order;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as int,
        questionText: json['question_text'] as String? ?? '',
        image: json['image'] as String?,
        options: _parseOptions(json['options']),
        points: asInt(json['points']) ?? 1,
        order: asInt(json['order']) ?? 0,
      );

  static List<MapEntry<String, String>> _parseOptions(dynamic raw) {
    if (raw is Map) {
      return raw.entries.map((e) => MapEntry('${e.key}', '${e.value}')).toList();
    }
    if (raw is List) {
      const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
      final count = raw.length < letters.length ? raw.length : letters.length;
      return List.generate(count, (i) => MapEntry(letters[i], '${raw[i]}'));
    }
    return const [];
  }
}

/// Full quiz + questions, from `GET /quizzes/{quiz}` (also starts the
/// attempt server-side as a side effect of that call).
class QuizDetail {
  QuizDetail({
    required this.id,
    required this.title,
    this.description,
    this.passScore = 50,
    this.durationMinutes,
    this.questions = const [],
  });

  final int id;
  final String title;
  final String? description;
  final int passScore;
  final int? durationMinutes;
  final List<QuizQuestion> questions;

  factory QuizDetail.fromJson(Map<String, dynamic> json) => QuizDetail(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        passScore: asInt(json['pass_score']) ?? 50,
        durationMinutes: asInt(json['duration_minutes']),
        questions: (json['questions'] as List<dynamic>? ?? [])
            .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class QuizAnswerResult {
  QuizAnswerResult({
    required this.questionId,
    required this.questionText,
    this.yourAnswer,
    this.correctAnswer,
    this.isCorrect = false,
    this.pointsEarned = 0,
  });

  final int questionId;
  final String questionText;
  final String? yourAnswer;
  final String? correctAnswer;
  final bool isCorrect;
  final int pointsEarned;

  factory QuizAnswerResult.fromJson(Map<String, dynamic> json) => QuizAnswerResult(
        questionId: json['question_id'] as int,
        questionText: json['question_text'] as String? ?? '',
        yourAnswer: json['your_answer'] as String?,
        correctAnswer: json['correct_answer'] as String?,
        isCorrect: json['is_correct'] == true,
        pointsEarned: asInt(json['points_earned']) ?? 0,
      );
}

class QuizResult {
  QuizResult({
    required this.quizId,
    required this.title,
    this.score = 0,
    this.totalScore = 0,
    this.percentage = 0,
    this.passed = false,
    this.passScore = 50,
    this.answers = const [],
  });

  final int quizId;
  final String title;
  final int score;
  final int totalScore;
  final num percentage;
  final bool passed;
  final int passScore;
  final List<QuizAnswerResult> answers;

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        quizId: json['quiz_id'] as int,
        title: json['title'] as String? ?? '',
        score: asInt(json['score']) ?? 0,
        totalScore: asInt(json['total_score']) ?? 0,
        percentage: asNum(json['percentage']) ?? 0,
        passed: json['passed'] == true,
        passScore: asInt(json['pass_score']) ?? 50,
        answers: (json['answers'] as List<dynamic>? ?? [])
            .map((e) => QuizAnswerResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
