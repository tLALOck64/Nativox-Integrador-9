import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/usecases/usecase.dart';
import 'package:integrador/core/utils/either.dart';
import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class GetLessonsByLevel implements UseCase<Map<String, List<Lesson>>, NoParams> {
  final LessonRepository repository;

  GetLessonsByLevel(this.repository);

  @override
  Future<Either<Failure, Map<String, List<Lesson>>>> call(NoParams params) async {
    return await repository.getLessonsByLevel();
  }
}