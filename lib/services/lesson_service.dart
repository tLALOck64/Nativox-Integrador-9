import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson_model.dart';

class LessonService {
  static final LessonService _instance = LessonService._internal();
  factory LessonService() => _instance;
  LessonService._internal();

  // URL de tu API
  static const String _baseUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-learning/api_learning';
  
  // Cache para mejorar performance
  List<LessonModel>? _cachedLessons;
  DateTime? _lastFetch;
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  // Headers comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTI1NDczODcsImlhdCI6MTc1MjQ2MDk4N30.vF2Qs1lxBYelkt3NyVxeAHH0x_5-tZBsiHGFECcEhYI',
  };
  // ✅ OBTENER TODAS LAS LECCIONES (SOLO API)
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
        Uri.parse('$_baseUrl/lecciones/lecciones'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List<dynamic> jsonList = decoded['data'];

        final lessons =
            jsonList
                .map(
                  (json) =>
                      LessonModel.fromApiResponse(json as Map<String, dynamic>),
                )
                .toList();

        _cachedLessons = lessons;
        _lastFetch = DateTime.now();

        return _applyProgressLogic(lessons);
      }
 else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lessons from API: $e');
      
      // Solo usar cache si existe
      if (_cachedLessons != null) {
        print('Using cached lessons');
        return _applyProgressLogic(List.from(_cachedLessons!));
      }
      
      // Si no hay cache, lanzar error
      throw Exception('No se pudieron cargar las lecciones. Verifica tu conexión a internet.');
    }
  }

  // ✅ OBTENER LECCIÓN POR ID (SOLO API)
  Future<LessonModel?> getLessonById(String id) async {
    try {
      // Intentar obtener de la lista cacheada primero
      final lessons = await getAllLessons();
      return lessons.firstWhere(
        (lesson) => lesson.id == id,
        orElse: () => throw Exception('Lección no encontrada'),
      );
    } catch (e) {
      print('Error fetching lesson by ID $id: $e');
      
      // Si falla, intentar llamada directa a API (si tienes endpoint específico)
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/lecciones/$id'),
          headers: _headers,
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final Map<String, dynamic> json = jsonDecode(response.body);
          return LessonModel.fromApiResponse(json);
        }
      } catch (e) {
        print('Error fetching single lesson from API: $e');
      }
      
      return null;
    }
  }

  // ✅ OBTENER LECCIONES AGRUPADAS POR NIVEL (SOLO API)
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
      throw Exception('Error al agrupar lecciones por nivel: ${e.toString()}');
    }
  }

  // ✅ OBTENER ESTADÍSTICAS DE LECCIONES (SOLO API)
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
      
      // Retornar estadísticas vacías si falla
      return {
        'completed': 0,
        'inProgress': 0,
        'totalWords': 0,
      };
    }
  }

  // ✅ OBTENER LECCIONES POR DIFICULTAD (SOLO API)
  Future<List<LessonModel>> getLessonsByDifficulty(String difficulty) async {
    final lessons = await getAllLessons();
    return lessons.where((lesson) => lesson.difficulty == difficulty).toList();
  }

  // ✅ OBTENER SIGUIENTE LECCIÓN DISPONIBLE (SOLO API)
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

  // ✅ OBTENER ESTADÍSTICAS DE PROGRESO (SOLO API)
  Future<Map<String, dynamic>> getProgressStats() async {
    try {
      final lessons = await getAllLessons();
      
      final completedLessons = lessons.where((lesson) => lesson.isCompleted).length;
      final totalLessons = lessons.length;
      final averageProgress = totalLessons > 0 
          ? lessons.fold<double>(0.0, (sum, lesson) => sum + lesson.progress) / totalLessons
          : 0.0;

      return {
        'completedLessons': completedLessons,
        'totalLessons': totalLessons,
        'averageProgress': averageProgress,
        'completionRate': totalLessons > 0 ? completedLessons / totalLessons : 0.0,
      };
    } catch (e) {
      print('Error getting progress stats: $e');
      
      // Retornar estadísticas vacías si falla
      return {
        'completedLessons': 0,
        'totalLessons': 0,
        'averageProgress': 0.0,
        'completionRate': 0.0,
      };
    }
  }

  // ✅ ACTUALIZAR PROGRESO DE LECCIÓN (CACHE LOCAL)
  Future<bool> updateLessonProgress(String lessonId, double progress) async {
    try {
      // Actualizar en cache si existe
      if (_cachedLessons != null) {
        final index = _cachedLessons!.indexWhere((lesson) => lesson.id == lessonId);
        if (index != -1) {
          _cachedLessons![index] = _cachedLessons![index].copyWith(
            progress: progress,
            isCompleted: progress >= 1.0,
          );
          
          // Aplicar lógica de bloqueo/desbloqueo
          _cachedLessons = _applyProgressLogic(_cachedLessons!);
          
          return true;
        }
      }
      
      // TODO: Aquí podrías enviar el progreso a tu API si tienes endpoint para eso
      // await _sendProgressToAPI(lessonId, progress);
      
      return false;
    } catch (e) {
      print('Error updating lesson progress: $e');
      return false;
    }
  }

  // ✅ COMPLETAR LECCIÓN (CACHE LOCAL)
  Future<bool> completeLesson(String lessonId) async {
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
          
          // TODO: Enviar completion a API
          // await _sendCompletionToAPI(lessonId);
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error completing lesson: $e');
      return false;
    }
  }

  // ✅ RESETEAR PROGRESO (CACHE LOCAL)
  Future<void> resetProgress() async {
    try {
      // Reset cache
      if (_cachedLessons != null) {
        for (int i = 0; i < _cachedLessons!.length; i++) {
          _cachedLessons![i] = _cachedLessons![i].copyWith(
            progress: 0.0,
            isCompleted: false,
            isLocked: i > 0, // Solo la primera lección desbloqueada
          );
        }
      }
      
      // TODO: Enviar reset a API si tienes endpoint
      // await _sendResetToAPI();
      
    } catch (e) {
      print('Error resetting progress: $e');
    }
  }

  // ✅ APLICAR LÓGICA DE PROGRESO Y BLOQUEOS
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

  // ✅ LIMPIAR CACHE
  void clearCache() {
    _cachedLessons = null;
    _lastFetch = null;
    print('Cache cleared');
  }

  // ✅ VERIFICAR CONECTIVIDAD CON API
  Future<bool> checkApiConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lecciones'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('API connectivity check failed: $e');
      return false;
    }
  }

  // ✅ FORZAR RECARGA DESDE API
  Future<List<LessonModel>> forceRefresh() async {
    clearCache();
    return await getAllLessons();
  }

  // ✅ OBTENER INFORMACIÓN DEL CACHE
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedData': _cachedLessons != null,
      'cacheSize': _cachedLessons?.length ?? 0,
      'lastFetch': _lastFetch?.toIso8601String(),
      'cacheValidUntil': _lastFetch?.add(_cacheValidDuration).toIso8601String(),
      'isCacheValid': _cachedLessons != null && 
          _lastFetch != null && 
          DateTime.now().difference(_lastFetch!) < _cacheValidDuration,
    };
  }

  // TODO: Métodos para enviar datos a la API (implementar cuando tengas endpoints)
  /*
  Future<void> _sendProgressToAPI(String lessonId, double progress) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/progreso/$lessonId'),
        headers: _headers,
        body: json.encode({'progress': progress}),
      );
    } catch (e) {
      print('Error sending progress to API: $e');
    }
  }

  Future<void> _sendCompletionToAPI(String lessonId) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/completar/$lessonId'),
        headers: _headers,
      );
    } catch (e) {
      print('Error sending completion to API: $e');
    }
  }

  Future<void> _sendResetToAPI() async {
    try {
      await http.delete(
        Uri.parse('$_baseUrl/progreso'),
        headers: _headers,
      );
    } catch (e) {
      print('Error sending reset to API: $e');
    }
  }
  */
}

// ============================================
// MANEJO DE ERRORES MEJORADO
// ============================================

// lessons/services/lesson_service_exceptions.dart
class LessonServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const LessonServiceException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'LessonServiceException: $message';
}

class NoInternetException extends LessonServiceException {
  const NoInternetException() : super('Sin conexión a internet');
}

class ApiServerException extends LessonServiceException {
  const ApiServerException(String message) : super(message);
}

class LessonNotFoundException extends LessonServiceException {
  const LessonNotFoundException(String lessonId) 
      : super('Lección no encontrada: $lessonId');
}
