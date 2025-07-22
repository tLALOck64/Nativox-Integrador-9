import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/usecases/usecase.dart';
import 'package:integrador/core/utils/either.dart';
import '../repositories/lesson_repository.dart';

class CompleteLesson implements UseCase<void, String> {
  final LessonRepository repository;

  CompleteLesson(this.repository);

  @override
  Future<Either<Failure, void>> call(String lessonId) async {
    return await repository.completeLesson(lessonId);
  }
}