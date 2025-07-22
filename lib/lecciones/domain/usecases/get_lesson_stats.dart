import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/usecases/usecase.dart';
import 'package:integrador/core/utils/either.dart';
import '../repositories/lesson_repository.dart';

class GetLessonStats implements UseCase<Map<String, int>, NoParams> {
  final LessonRepository repository;

  GetLessonStats(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(NoParams params) async {
    return await repository.getLessonStats();
  }
}