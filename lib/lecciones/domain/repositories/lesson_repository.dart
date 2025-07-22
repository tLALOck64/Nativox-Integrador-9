import '../entities/lesson.dart';
import '../entities/lesson_stats.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';

abstract class LessonRepository {
  Future<Either<Failure, Map<String, List<Lesson>>>> getLessonsByLevel();
  Future<Either<Failure, Map<String, int>>> getLessonStats();
  Future<Either<Failure, Lesson>> getLessonDetails(String lessonId);
  Future<Either<Failure, void>> saveLessonProgress(String lessonId, int progress);
  Future<Either<Failure, Lesson>> getLessonStatsById(String lessonId);
  Future<Either<Failure, void>> completeLesson(String lessonId);
  Future<Either<Failure, void>> lockLesson(String lessonId);
  Future<Either<Failure, void>> unlockLesson(String lessonId);
  Future<Either<Failure, void>> deleteLesson(String lessonId);
  Future<Either<Failure, void>> updateLesson(Lesson lesson);
  Future<Either<Failure, List<Lesson>>> getAllLessons();
  void clearCache();
}