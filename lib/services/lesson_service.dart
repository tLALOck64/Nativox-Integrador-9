import '../models/lesson_model.dart';

class LessonService {
  static final LessonService _instance = LessonService._internal();
  factory LessonService() => _instance;
  LessonService._internal();

  // Simulación de datos de lecciones actualizadas
  List<LessonModel> _lessons = [
    LessonModel(
      id: '1',
      icon: '🌅',
      title: 'Saludos básicos',
      subtitle: 'Básico • 5 min',
      progress: 1.0,
      difficulty: 'Básico',
      duration: 5,
      isCompleted: true,
      isLocked: false,
      lessonNumber: 1,
      level: 'Básico',
      wordCount: 8,
    ),
    LessonModel(
      id: '2',
      icon: '🔢',
      title: 'Números 1-10',
      subtitle: 'Básico • 7 min',
      progress: 1.0,
      difficulty: 'Básico',
      duration: 7,
      isCompleted: true,
      isLocked: false,
      lessonNumber: 2,
      level: 'Básico',
      wordCount: 10,
    ),
    LessonModel(
      id: '3',
      icon: '👨‍👩‍👧‍👦',
      title: 'La familia',
      subtitle: 'Básico • 8 min',
      progress: 0.45,
      difficulty: 'Básico',
      duration: 8,
      isCompleted: false,
      isLocked: false,
      lessonNumber: 3,
      level: 'Básico',
      wordCount: 12,
    ),
    LessonModel(
      id: '4',
      icon: '🎨',
      title: 'Colores',
      subtitle: 'Básico • 6 min',
      progress: 0.0,
      difficulty: 'Básico',
      duration: 6,
      isCompleted: false,
      isLocked: true,
      lessonNumber: 4,
      level: 'Básico',
      wordCount: 9,
    ),
    LessonModel(
      id: '5',
      icon: '🌽',
      title: 'Comida tradicional',
      subtitle: 'Intermedio • 12 min',
      progress: 0.0,
      difficulty: 'Intermedio',
      duration: 12,
      isCompleted: false,
      isLocked: true,
      lessonNumber: 5,
      level: 'Intermedio',
      wordCount: 15,
    ),
    LessonModel(
      id: '6',
      icon: '🏔️',
      title: 'Naturaleza',
      subtitle: 'Intermedio • 10 min',
      progress: 0.0,
      difficulty: 'Intermedio',
      duration: 10,
      isCompleted: false,
      isLocked: true,
      lessonNumber: 6,
      level: 'Intermedio',
      wordCount: 18,
    ),
    LessonModel(
      id: '7',
      icon: '🎭',
      title: 'Ceremonias',
      subtitle: 'Avanzado • 15 min',
      progress: 0.0,
      difficulty: 'Avanzado',
      duration: 15,
      isCompleted: false,
      isLocked: true,
      lessonNumber: 7,
      level: 'Avanzado',
      wordCount: 20,
    ),
  ];

  // Obtener todas las lecciones
  Future<List<LessonModel>> getAllLessons() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_lessons);
  }

  // Obtener lección por ID
  Future<LessonModel?> getLessonById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _lessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener lecciones por dificultad
  Future<List<LessonModel>> getLessonsByDifficulty(String difficulty) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _lessons.where((lesson) => lesson.difficulty == difficulty).toList();
  }

  // Actualizar progreso de una lección
  Future<bool> updateLessonProgress(String lessonId, double progress) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
      if (index != -1) {
        _lessons[index] = _lessons[index].copyWith(
          progress: progress,
          isCompleted: progress >= 1.0,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Completar una lección
  Future<bool> completeLesson(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
      if (index != -1) {
        _lessons[index] = _lessons[index].copyWith(
          progress: 1.0,
          isCompleted: true,
        );
        
        // Desbloquear la siguiente lección si existe
        if (index + 1 < _lessons.length) {
          _lessons[index + 1] = _lessons[index + 1].copyWith(isLocked: false);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtener la siguiente lección disponible
  Future<LessonModel?> getNextLesson() async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _lessons.firstWhere(
        (lesson) => !lesson.isCompleted && !lesson.isLocked,
      );
    } catch (e) {
      return null;
    }
  }

  // Obtener lecciones agrupadas por nivel
  Future<Map<String, List<LessonModel>>> getLessonsByLevel() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final Map<String, List<LessonModel>> groupedLessons = {};
    
    for (final lesson in _lessons) {
      if (!groupedLessons.containsKey(lesson.level)) {
        groupedLessons[lesson.level] = [];
      }
      groupedLessons[lesson.level]!.add(lesson);
    }
    
    // Ordenar lecciones por número dentro de cada nivel
    groupedLessons.forEach((level, lessons) {
      lessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
    });
    
    return groupedLessons;
  }

  // Obtener estadísticas de lecciones
  Future<Map<String, int>> getLessonStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final completedLessons = _lessons.where((lesson) => lesson.isCompleted).length;
    final inProgressLessons = _lessons.where(
      (lesson) => lesson.progress > 0 && lesson.progress < 1.0
    ).length;
    final totalWords = _lessons.fold<int>(
      0,
      (sum, lesson) => sum + (lesson.wordCount * lesson.progress).round(),
    );
    
    return {
      'completed': completedLessons,
      'inProgress': inProgressLessons,
      'totalWords': totalWords,
    };
  }
  Future<Map<String, dynamic>> getProgressStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final completedLessons = _lessons.where((lesson) => lesson.isCompleted).length;
    final totalLessons = _lessons.length;
    final averageProgress = _lessons.fold<double>(
      0.0,
      (sum, lesson) => sum + lesson.progress,
    ) / totalLessons;

    return {
      'completedLessons': completedLessons,
      'totalLessons': totalLessons,
      'averageProgress': averageProgress,
      'completionRate': completedLessons / totalLessons,
    };
  }

  // Reiniciar progreso (para testing)
  Future<void> resetProgress() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _lessons.length; i++) {
      _lessons[i] = _lessons[i].copyWith(
        progress: 0.0,
        isCompleted: false,
        isLocked: i > 0, // Solo la primera lección desbloqueada
      );
    }
  }
}