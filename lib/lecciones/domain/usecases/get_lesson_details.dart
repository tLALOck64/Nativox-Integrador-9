import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/usecases/usecase.dart';
import 'package:integrador/core/utils/either.dart';
import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class GetLessonDetails implements UseCase<Lesson, String> {
  final LessonRepository repository;

  GetLessonDetails(this.repository);

  @override
  Future<Either<Failure, Lesson>> call(String lessonId) async {
    return await repository.getLessonDetails(lessonId);
  }
}