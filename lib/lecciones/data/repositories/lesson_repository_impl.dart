import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasource/lesson_remote_datasource.dart';
import '../datasource/lesson_local_datasource.dart';
import '../models/lessons_models.dart';

class LessonRepositoryImpl implements LessonRepository {
  final LessonRemoteDataSource remoteDataSource;
  final LessonLocalDataSource localDataSource;

  LessonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Lesson>>> getAllLessons() async {
    try {
      // Intentar cache primero
      try {
        final cachedLessons = await localDataSource.getCachedLessons();
        final lessons = cachedLessons.map((model) => model.toEntity()).toList();
        return Right(_applyProgressLogic(lessons));
      } catch (e) {
        // Cache falló, continuar con API
      }

      // Llamar API
      final lessonModels = await remoteDataSource.getAllLessons();
      await localDataSource.cacheLessons(lessonModels);
      
      final lessons = lessonModels.map((model) => model.toEntity()).toList();
      return Right(_applyProgressLogic(lessons));
      
    } catch (failure) {
      if (failure is Failure) {
        // Si API falla, intentar cache expirado
        try {
          final cachedLessons = await localDataSource.getCachedLessons();
          final lessons = cachedLessons.map((model) => model.toEntity()).toList();
          return Right(_applyProgressLogic(lessons));
        } catch (e) {
          // Devolver datos de fallback
          return Right(_getFallbackLessons());
        }
      }
      return Left(ServerFailure('Error inesperado: ${failure.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<Lesson>>>> getLessonsByLevel() async {
    final result = await getAllLessons();
    
    return result.fold(
      (failure) => Left(failure),
      (lessons) {
        final Map<String, List<Lesson>> groupedLessons = {};
        
        for (final lesson in lessons) {
          if (!groupedLessons.containsKey(lesson.level)) {
            groupedLessons[lesson.level] = [];
          }
          groupedLessons[lesson.level]!.add(lesson);
        }
        
        // Ordenar lecciones por número dentro de cada nivel
        groupedLessons.forEach((level, lessons) {
          lessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
        });
        
        return Right(groupedLessons);
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, int>>> getLessonStats() async {
    final result = await getAllLessons();
    
    return result.fold(
      (failure) => Left(failure),
      (lessons) {
        final completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
        final inProgressLessons = lessons.where(
          (lesson) => lesson.progress > 0 && lesson.progress < 1.0
        ).length;
        final totalWords = lessons.fold<int>(
          0,
          (sum, lesson) => sum + (lesson.wordCount * lesson.progress).round(),
        );
        
        return Right({
          'completed': completedLessons,
          'inProgress': inProgressLessons,
          'totalWords': totalWords,
        });
      },
    );
  }

  @override
  Future<Either<Failure, Lesson>> getLessonDetails(String lessonId) async {
    try {
      // Intentar cache primero
      final cachedLesson = await localDataSource.getCachedLessonById(lessonId);
      if (cachedLesson != null) {
        return Right(cachedLesson.toEntity());
      }

      // Si no está en cache, llamar API
      final lessonModel = await remoteDataSource.getLessonById(lessonId);
      return Right(lessonModel.toEntity());
      
    } catch (failure) {
      if (failure is Failure) {
        return Left(failure);
      }
      return Left(ServerFailure('Error inesperado: ${failure.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveLessonProgress(String lessonId, int progress) async {
    try {
      // Validar progreso
      if (progress < 0 || progress > 100) {
        return Left(ValidationFailure('El progreso debe estar entre 0 y 100'));
      }

      // Actualizar en API
      await remoteDataSource.updateLessonProgress(lessonId, progress);
      
      // Actualizar en cache si existe
      final cachedLesson = await localDataSource.getCachedLessonById(lessonId);
      if (cachedLesson != null) {
        final updatedLesson = cachedLesson.copyWith(
          progress: progress.toDouble() / 100,
          isCompleted: progress >= 100,
        );
        await localDataSource.updateCachedLesson(updatedLesson);
      }
      
      return const Right(null);
    } catch (failure) {
      if (failure is Failure) {
        return Left(failure);
      }
      return Left(ServerFailure('Error inesperado: ${failure.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Lesson>> getLessonStatsById(String lessonId) async {
    return getLessonDetails(lessonId);
  }

  @override
  Future<Either<Failure, void>> completeLesson(String lessonId) async {
    try {
      // Completar en API
      await remoteDataSource.completeLesson(lessonId);
      
      // Actualizar en cache
      final cachedLesson = await localDataSource.getCachedLessonById(lessonId);
      if (cachedLesson != null) {
        final completedLesson = cachedLesson.copyWith(
          progress: 1.0,
          isCompleted: true,
        );
        await localDataSource.updateCachedLesson(completedLesson);
        
        // Desbloquear siguiente lección si existe
        await _unlockNextLesson(lessonId);
      }
      
      return const Right(null);
    } catch (failure) {
      if (failure is Failure) {
        return Left(failure);
      }
      return Left(ServerFailure('Error inesperado: ${failure.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> lockLesson(String lessonId) async {
    try {
      final cachedLesson = await localDataSource.getCachedLessonById(lessonId);
      if (cachedLesson != null) {
        final lockedLesson = cachedLesson.copyWith(isLocked: true);
        await localDataSource.updateCachedLesson(lockedLesson);
      }
      return const Right(null);
    } catch (failure) {
      if (failure is Failure) {
        return Left(failure);
      }
      return Left(CacheFailure('Error al bloquear lección: ${failure.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> unlockLesson(String lessonId) async {
    try {
      final cachedLesson = await localDataSource.getCachedLessonById(lessonId);
      if (cachedLesson != null) {
        final unlockedLesson = cachedLesson.copyWith(isLocked: false);
        await localDataSource.updateCachedLesson(unlockedLesson);
      }
      return const Right(null);
    } catch (failure) {
      if (failure is Failure) {
        return Left(failure);
      }
      return Left(CacheFailure('Error al desbloquear lección: ${failure.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLesson(String lessonId) async {
    // Implementar si es necesario en el futuro
    return Left(ServerFailure('Operación no implementada'));
  }

  @override
  Future<Either<Failure, void>> updateLesson(Lesson lesson) async {
    try {
      final lessonModel = LessonModel.fromEntity(lesson);
      await localDataSource.updateCachedLesson(lessonModel);
      return const Right(null);
    } catch (failure) {
      if (failure is Failure) {
        return Left(failure);
      }
      return Left(CacheFailure('Error al actualizar lección: ${failure.toString()}'));
    }
  }

  @override
  void clearCache() {
    localDataSource.clearCache();
  }

  // ============================================
  // MÉTODOS PRIVADOS
  // ============================================

  List<Lesson> _applyProgressLogic(List<Lesson> lessons) {
    lessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
    
    for (int i = 0; i < lessons.length; i++) {
      if (i == 0) {
        lessons[i] = lessons[i].copyWith(isLocked: false);
      } else {
        final previousCompleted = i > 0 ? lessons[i - 1].isCompleted : true;
        lessons[i] = lessons[i].copyWith(isLocked: !previousCompleted);
      }
    }
    
    return lessons;
  }

  Future<void> _unlockNextLesson(String completedLessonId) async {
    try {
      final cachedLessons = await localDataSource.getCachedLessons();
      final currentIndex = cachedLessons.indexWhere((lesson) => lesson.id == completedLessonId);
      
      if (currentIndex != -1 && currentIndex + 1 < cachedLessons.length) {
        final nextLesson = cachedLessons[currentIndex + 1].copyWith(isLocked: false);
        await localDataSource.updateCachedLesson(nextLesson);
      }
    } catch (e) {
      // Silenciar error de desbloqueo
    }
  }

  List<Lesson> _getFallbackLessons() {
    final fallbackModels = [
      const LessonModel(
        id: 'test-1',
        icon: '👋',
        title: 'Saludos en Zapoteco',
        subtitle: 'Aprende saludos básicos',
        difficulty: 'Fácil',
        duration: 15,
        progress: 0.0,
        isCompleted: false,
        isLocked: false,
        lessonNumber: 1,
        level: 'Básico',
        wordCount: 10,
      ),
      const LessonModel(
        id: 'test-2',
        icon: '🏠',
        title: 'La Familia en Tseltal',
        subtitle: 'Vocabulario familiar básico',
        difficulty: 'Medio',
        duration: 20,
        progress: 0.3,
        isCompleted: false,
        isLocked: false,
        lessonNumber: 2,
        level: 'Intermedio',
        wordCount: 15,
      ),
      const LessonModel(
        id: 'test-3',
        icon: '🔢',
        title: 'Números en Zapoteco',
        subtitle: 'Cuenta del 1 al 10',
        difficulty: 'Fácil',
        duration: 18,
        progress: 1.0,
        isCompleted: true,
        isLocked: false,
        lessonNumber: 3,
        level: 'Básico',
        wordCount: 12,
      ),
    ];
    
    return fallbackModels.map((model) => model.toEntity()).toList();
  }
}