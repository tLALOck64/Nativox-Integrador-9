class ExerciseResultModel {
  final int exerciseIndex;
  final dynamic userAnswer;
  final bool isCorrect;
  final DateTime timestamp;

  const ExerciseResultModel({
    required this.exerciseIndex,
    required this.userAnswer,
    required this.isCorrect,
    required this.timestamp,
  });
}

class LessonProgressModel {
  final String lessonId;
  final List<ExerciseResultModel> results;
  final double completionPercentage;
  final bool isCompleted;
  final int score;

  const LessonProgressModel({
    required this.lessonId,
    required this.results,
    required this.completionPercentage,
    required this.isCompleted,
    required this.score,
  });

  factory LessonProgressModel.empty(String lessonId) {
    return LessonProgressModel(
      lessonId: lessonId,
      results: [],
      completionPercentage: 0.0,
      isCompleted: false,
      score: 0,
    );
  }
}