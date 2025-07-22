import '../../domain/entities/lesson.dart';
import '../../domain/usecases/get_lesson_details.dart';
import '../../domain/usecases/save_lesson_progress.dart';
import '../../domain/usecases/complete_lessons.dart';
import 'package:integrador/core/error/failure.dart';
import 'base_view_model.dart';

class LessonDetailViewModel extends BaseViewModel {
  final String lessonId;
  final GetLessonDetails _getLessonDetails;
  final SaveLessonProgress _saveLessonProgress;
  final CompleteLesson _completeLesson;

  LessonDetailViewModel({
    required this.lessonId,
    required GetLessonDetails getLessonDetails,
    required SaveLessonProgress saveLessonProgress,
    required CompleteLesson completeLesson,
  }) : _getLessonDetails = getLessonDetails,
       _saveLessonProgress = saveLessonProgress,
       _completeLesson = completeLesson;

  Lesson? _lesson;
  int _currentProgress = 0;

  // Getters
  Lesson? get lesson => _lesson;
  int get currentProgress => _currentProgress;
  bool get isCompleted => _currentProgress >= 100;
  bool get hasLesson => _lesson != null;

  Future<void> initialize() async {
    await loadLesson();
  }

  Future<void> loadLesson() async {
    setLoading();
    
    try {
      final result = await _getLessonDetails.call(lessonId);
      
      result.fold(
        (failure) => setError(failure),
        (lesson) {
          _lesson = lesson;
          _currentProgress = (lesson.progress * 100).round();
          setLoaded();
        },
      );
    } catch (e) {
      // Manejo más específico de errores según el tipo de excepción
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        setError(NetworkFailure.noInternet());
      } else if (e.toString().contains('TimeoutException')) {
        setError(NetworkFailure.timeout());
      } else {
        setError(ServerFailure.internalError());
      }
    }
  }

  Future<bool> updateProgress(int progress) async {
    if (_lesson == null) {
      setError(const ValidationFailure('No hay lección cargada para actualizar'));
      return false;
    }
    
    // Validación del progreso
    if (progress < 0 || progress > 100) {
      setError(ValidationFailure.required('Progreso válido (0-100)'));
      return false;
    }
    
    try {
      _currentProgress = progress.clamp(0, 100);
      notifyListeners();
      
      final params = SaveProgressParams(lessonId: lessonId, progress: progress);
      final result = await _saveLessonProgress.call(params);
      
      return result.fold(
        (failure) {
          setError(failure);
          return false;
        },
        (_) {
          clearError();
          return true;
        },
      );
    } catch (e) {
      // Manejo específico según el tipo de error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        setError(NetworkFailure.noInternet());
      } else if (e.toString().contains('TimeoutException')) {
        setError(NetworkFailure.timeout());
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        setError(AuthFailure.tokenExpired());
      } else if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        setError(AuthFailure.accountDisabled());
      } else if (e.toString().contains('404')) {
        setError(ServerFailure.notFound());
      } else if (e.toString().contains('400')) {
        setError(ServerFailure.badRequest());
      } else {
        setError(ServerFailure.internalError());
      }
      return false;
    }
  }

  Future<bool> completeLesson() async {
    if (_lesson == null) {
      setError(const ValidationFailure('No hay lección cargada para completar'));
      return false;
    }
    
    // Verificar si ya está completada
    if (isCompleted) {
      setError(const ValidationFailure('La lección ya está completada'));
      return false;
    }
    
    try {
      _currentProgress = 100;
      notifyListeners();
      
      final result = await _completeLesson.call(lessonId);
      
      return result.fold(
        (failure) {
          setError(failure);
          return false;
        },
        (_) {
          _lesson = _lesson!.copyWith(
            progress: 1.0,
            isCompleted: true,
          );
          clearError();
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      // Manejo específico según el tipo de error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        setError(NetworkFailure.noInternet());
      } else if (e.toString().contains('TimeoutException')) {
        setError(NetworkFailure.timeout());
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        setError(AuthFailure.tokenExpired());
      } else if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        setError(AuthFailure.accountDisabled());
      } else if (e.toString().contains('404')) {
        setError(ServerFailure.notFound());
      } else if (e.toString().contains('400')) {
        setError(ServerFailure.badRequest());
      } else if (e.toString().contains('429') || e.toString().contains('Too Many Requests')) {
        setError(AuthFailure.tooManyRequests());
      } else {
        setError(ServerFailure.internalError());
      }
      return false;
    }
  }

  void resetProgress() {
    if (_lesson == null) {
      setError(const ValidationFailure('No hay lección cargada para resetear'));
      return;
    }
    
    _currentProgress = 0;
    clearError();
    notifyListeners();
  }
}