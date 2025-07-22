import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_stats.dart';
import '../../domain/usecases/get_lessons_by_level.dart';
import '../../domain/usecases/get_lesson_stats.dart';
import '../../domain/usecases/get_lesson_details.dart';
import '../../domain/usecases/complete_lessons.dart';
import '../../domain/usecases/save_lesson_progress.dart';
import 'package:integrador/core/usecases/usecase.dart';
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/utils/either.dart';
import 'base_view_model.dart';

class LessonsViewModel extends BaseViewModel {
  final GetLessonsByLevel _getLessonsByLevel;
  final GetLessonStats _getLessonStats;
  final GetLessonDetails _getLessonDetails;
  final CompleteLesson _completeLesson;
  final SaveLessonProgress _saveLessonProgress;

  LessonsViewModel({
    required GetLessonsByLevel getLessonsByLevel,
    required GetLessonStats getLessonStats,
    required GetLessonDetails getLessonDetails,
    required CompleteLesson completeLesson,
    required SaveLessonProgress saveLessonProgress,
  }) : _getLessonsByLevel = getLessonsByLevel,
       _getLessonStats = getLessonStats,
       _getLessonDetails = getLessonDetails,
       _completeLesson = completeLesson,
       _saveLessonProgress = saveLessonProgress;

  // State
  Map<String, List<Lesson>> _lessonsByLevel = {};
  LessonStats _lessonStats = LessonStats.empty;
  final List<String> _levelOrder = ['Básico', 'Intermedio', 'Avanzado'];

  // Getters
  Map<String, List<Lesson>> get lessonsByLevel => Map.unmodifiable(_lessonsByLevel);
  LessonStats get lessonStats => _lessonStats;
  List<String> get levelOrder => List.unmodifiable(_levelOrder);
  bool get hasLessons => _lessonsByLevel.isNotEmpty;

  // Computed properties
  int get totalLessons => _lessonsByLevel.values
      .fold<int>(0, (sum, lessons) => sum + lessons.length);

  // ============================================
  // PUBLIC METHODS
  // ============================================

  Future<void> initialize() async {
    await loadData();
  }

  Future<void> loadData() async {
    setLoading();
    
    try {
      final results = await Future.wait([
        _getLessonsByLevel.call(const NoParams()),
        _getLessonStats.call(const NoParams()),
      ]);

      final lessonsByLevelResult = results[0] as Either<Failure, Map<String, List<Lesson>>>;
      final lessonStatsResult = results[1] as Either<Failure, Map<String, int>>;

      bool lessonsByLevelSuccess = false;
      bool lessonStatsSuccess = false;

      lessonsByLevelResult.fold(
        (failure) => setError(failure),
        (data) {
          _lessonsByLevel = data;
          lessonsByLevelSuccess = true;
        }
      );

      lessonStatsResult.fold(
        (failure) {
          if (!lessonsByLevelSuccess) setError(failure);
        },
        (data) {
          _lessonStats = LessonStats.fromMap(data);
          lessonStatsSuccess = true;
        }
      );

      if (lessonsByLevelSuccess) {
        if (_lessonsByLevel.isEmpty) {
          setEmpty();
        } else {
          setLoaded();
        }
      }
    } catch (e) {
      setError(ServerFailure('Error inesperado al cargar datos'));
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  Future<bool> startLesson(String lessonId) async {
    try {
      final result = await _getLessonDetails.call(lessonId);
      
      return result.fold(
        (failure) {
          setError(failure);
          return false;
        },
        (lesson) {
          if (lesson.isLocked) {
            setError(ValidationFailure(
              'Esta lección está bloqueada. Completa las anteriores primero.'
            ));
            return false;
          }
          clearError();
          return true;
        },
      );
    } catch (e) {
      setError(ServerFailure('Error al iniciar lección'));
      return false;
    }
  }

  Future<bool> updateLessonProgress(String lessonId, int progress) async {
    try {
      final params = SaveProgressParams(lessonId: lessonId, progress: progress);
      final result = await _saveLessonProgress.call(params);
      
      return result.fold(
        (failure) {
          setError(failure);
          return false;
        },
        (_) {
          // Recargar datos para actualizar UI
          loadData();
          return true;
        },
      );
    } catch (e) {
      setError(ServerFailure('Error al actualizar progreso'));
      return false;
    }
  }

  Future<bool> completeLesson(String lessonId) async {
    try {
      final result = await _completeLesson.call(lessonId);
      
      return result.fold(
        (failure) {
          setError(failure);
          return false;
        },
        (_) {
          // Recargar datos para actualizar UI y desbloquear siguiente
          loadData();
          return true;
        },
      );
    } catch (e) {
      setError(ServerFailure('Error al completar lección'));
      return false;
    }
  }

  // Helper methods for UI
  List<Lesson> getLessonsForLevel(String level) {
    return _lessonsByLevel[level] ?? [];
  }

  bool hasLessonsForLevel(String level) {
    return _lessonsByLevel.containsKey(level) && 
           _lessonsByLevel[level]!.isNotEmpty;
  }

  List<String> getAvailableLevels() {
    final orderedLevels = _levelOrder.where((level) => hasLessonsForLevel(level)).toList();
    final additionalLevels = _lessonsByLevel.keys
        .where((level) => !_levelOrder.contains(level))
        .toList();
    
    return [...orderedLevels, ...additionalLevels];
  }

  Lesson? getLessonById(String lessonId) {
    for (final lessons in _lessonsByLevel.values) {
      try {
        return lessons.firstWhere((lesson) => lesson.id == lessonId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }
}