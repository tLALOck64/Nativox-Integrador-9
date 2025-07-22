import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/usecases/usecase.dart';
import 'package:integrador/core/utils/either.dart';
import '../repositories/lesson_repository.dart';

class SaveLessonProgress implements UseCase<void, SaveProgressParams> {
  final LessonRepository repository;

  SaveLessonProgress(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveProgressParams params) async {
    return await repository.saveLessonProgress(params.lessonId, params.progress);
  }
}

class SaveProgressParams {
  final String lessonId;
  final int progress;

  const SaveProgressParams({
    required this.lessonId,
    required this.progress,
  });
}
