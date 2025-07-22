import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class GetLessonsUsecase {
  final LessonRepository _lessonRepository;

  GetLessonsUsecase(this._lessonRepository);

  Future<Either<Failure, List<Lesson>>> call() {
    return _lessonRepository.getAllLessons();
  }
}
