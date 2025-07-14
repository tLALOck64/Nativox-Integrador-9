import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson_model.dart';

class LessonService {
  static final LessonService _instance = LessonService._internal();
  factory LessonService() => _instance;
  LessonService._internal();

  // ✅ NUEVA: URL de tu API
  static const String _baseUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-learning/api_learning';
  
  // Cache para mejorar performance
  List<LessonModel>? _cachedLessons;
  DateTime? _lastFetch;
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  // Datos locales como fallback (tus datos actuales)
  List<LessonModel> _localLessons = [
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

  // ✅ ACTUALIZADO: Obtener todas las lecciones (API first)
  Future<List<LessonModel>> getAllLessons() async {
    try {
      // Verificar cache
      if (_cachedLessons != null && 
          _lastFetch != null && 
          DateTime.now().difference(_lastFetch!) < _cacheValidDuration) {
        return _applyProgressLogic(List.from(_cachedLessons!));
      }

      // Llamar a la API
      final response = await http.get(
        Uri.parse('$_baseUrl/lecciones'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        final lessons = jsonList
            .map((json) => LessonModel.fromApiResponse(json as Map<String, dynamic>))
            .toList();

        // Actualizar cache
        _cachedLessons = lessons;
        _lastFetch = DateTime.now();

        return _applyProgressLogic(lessons);
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lessons from API: $e');
      
      // Fallback a cache si existe
      if (_cachedLessons != null) {
        return _applyProgressLogic(List.from(_cachedLessons!));
      }
      
      // Fallback final a datos locales
      await Future.delayed(const Duration(milliseconds: 500));
      return _applyProgressLogic(List.from(_localLessons));
    }
  }

  // ✅ ACTUALIZADO: Obtener lección por ID (API first)
  Future<LessonModel?> getLessonById(String id) async {
    try {
      // Primero intentar de la lista cacheada
      final lessons = await getAllLessons();
      return lessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      print('Error fetching lesson by ID: $e');
      return null;
    }
  }

  // ✅ ACTUALIZADO: Obtener lecciones agrupadas por nivel (API first)
  Future<Map<String, List<LessonModel>>> getLessonsByLevel() async {
    try {
      final lessons = await getAllLessons();
      
      final Map<String, List<LessonModel>> groupedLessons = {};
      
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
      
      return groupedLessons;
    } catch (e) {
      print('Error grouping lessons by level: $e');
      
      // Fallback a datos locales
      await Future.delayed(const Duration(milliseconds: 500));
      final Map<String, List<LessonModel>> groupedLessons = {};
      
      for (final lesson in _localLessons) {
        if (!groupedLessons.containsKey(lesson.level)) {
          groupedLessons[lesson.level] = [];
        }
        groupedLessons[lesson.level]!.add(lesson);
      }
      
      groupedLessons.forEach((level, lessons) {
        lessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
      });
      
      return groupedLessons;
    }
  }

  // ✅ ACTUALIZADO: Obtener estadísticas de lecciones (API first)
  Future<Map<String, int>> getLessonStats() async {
    try {
      final lessons = await getAllLessons();
      
      final completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
      final inProgressLessons = lessons.where(
        (lesson) => lesson.progress > 0 && lesson.progress < 1.0
      ).length;
      final totalWords = lessons.fold<int>(
        0,
        (sum, lesson) => sum + (lesson.wordCount * lesson.progress).round(),
      );
      
      return {
        'completed': completedLessons,
        'inProgress': inProgressLessons,
        'totalWords': totalWords,
      };
    } catch (e) {
      print('Error getting lesson stats: $e');
      
      // Fallback a datos locales
      await Future.delayed(const Duration(milliseconds: 300));
      
      final completedLessons = _localLessons.where((lesson) => lesson.isCompleted).length;
      final inProgressLessons = _localLessons.where(
        (lesson) => lesson.progress > 0 && lesson.progress < 1.0
      ).length;
      final totalWords = _localLessons.fold<int>(
        0,
        (sum, lesson) => sum + (lesson.wordCount * lesson.progress).round(),
      );
      
      return {
        'completed': completedLessons,
        'inProgress': inProgressLessons,
        'totalWords': totalWords,
      };
    }
  }

  // ✅ NUEVO: Aplicar lógica de progreso y bloqueos
  List<LessonModel> _applyProgressLogic(List<LessonModel> lessons) {
    // Ordenar por número de lección
    lessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
    
    for (int i = 0; i < lessons.length; i++) {
      // La primera lección siempre desbloqueada
      if (i == 0) {
        lessons[i] = lessons[i].copyWith(isLocked: false);
      } else {
        // Desbloquear si la anterior está completada
        final previousCompleted = i > 0 ? lessons[i - 1].isCompleted : true;
        lessons[i] = lessons[i].copyWith(isLocked: !previousCompleted);
      }
    }
    
    return lessons;
  }

  // ✅ NUEVO: Limpiar cache
  void clearCache() {
    _cachedLessons = null;
    _lastFetch = null;
  }

  // Métodos existentes (sin cambios, pero usando la nueva lógica)
  Future<List<LessonModel>> getLessonsByDifficulty(String difficulty) async {
    final lessons = await getAllLessons();
    return lessons.where((lesson) => lesson.difficulty == difficulty).toList();
  }

  Future<bool> updateLessonProgress(String lessonId, double progress) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      // Actualizar en cache si existe
      if (_cachedLessons != null) {
        final index = _cachedLessons!.indexWhere((lesson) => lesson.id == lessonId);
        if (index != -1) {
          _cachedLessons![index] = _cachedLessons![index].copyWith(
            progress: progress,
            isCompleted: progress >= 1.0,
          );
        }
      }
      
      // Actualizar en datos locales también
      final index = _localLessons.indexWhere((lesson) => lesson.id == lessonId);
      if (index != -1) {
        _localLessons[index] = _localLessons[index].copyWith(
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

  Future<bool> completeLesson(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      // Actualizar en cache
      if (_cachedLessons != null) {
        final index = _cachedLessons!.indexWhere((lesson) => lesson.id == lessonId);
        if (index != -1) {
          _cachedLessons![index] = _cachedLessons![index].copyWith(
            progress: 1.0,
            isCompleted: true,
          );
          
          // Desbloquear la siguiente lección
          if (index + 1 < _cachedLessons!.length) {
            _cachedLessons![index + 1] = _cachedLessons![index + 1].copyWith(isLocked: false);
          }
        }
      }
      
      // Actualizar en datos locales
      final index = _localLessons.indexWhere((lesson) => lesson.id == lessonId);
      if (index != -1) {
        _localLessons[index] = _localLessons[index].copyWith(
          progress: 1.0,
          isCompleted: true,
        );
        
        if (index + 1 < _localLessons.length) {
          _localLessons[index + 1] = _localLessons[index + 1].copyWith(isLocked: false);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<LessonModel?> getNextLesson() async {
    try {
      final lessons = await getAllLessons();
      return lessons.firstWhere(
        (lesson) => !lesson.isCompleted && !lesson.isLocked,
      );
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getProgressStats() async {
    try {
      final lessons = await getAllLessons();
      
      final completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
      final totalLessons = lessons.length;
      final averageProgress = lessons.fold<double>(
        0.0,
        (sum, lesson) => sum + lesson.progress,
      ) / totalLessons;

      return {
        'completedLessons': completedLessons,
        'totalLessons': totalLessons,
        'averageProgress': averageProgress,
        'completionRate': completedLessons / totalLessons,
      };
    } catch (e) {
      // Fallback
      await Future.delayed(const Duration(milliseconds: 200));
      
      final completedLessons = _localLessons.where((lesson) => lesson.isCompleted).length;
      final totalLessons = _localLessons.length;
      final averageProgress = _localLessons.fold<double>(
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
  }

  Future<void> resetProgress() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Reset cache
    if (_cachedLessons != null) {
      for (int i = 0; i < _cachedLessons!.length; i++) {
        _cachedLessons![i] = _cachedLessons![i].copyWith(
          progress: 0.0,
          isCompleted: false,
          isLocked: i > 0,
        );
      }
    }
    
    // Reset datos locales
    for (int i = 0; i < _localLessons.length; i++) {
      _localLessons[i] = _localLessons[i].copyWith(
        progress: 0.0,
        isCompleted: false,
        isLocked: i > 0,
      );
    }
  }
}
