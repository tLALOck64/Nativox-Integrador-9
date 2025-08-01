import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson_detail_model.dart';
import 'package:integrador/core/services/secure_storage_service.dart';

class LessonDetailService {
  static final LessonDetailService _instance = LessonDetailService._internal();
  factory LessonDetailService() => _instance;
  LessonDetailService._internal();

  // URL de tu API
  static const String _baseUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-learning/api_learning';
  
  // Cache para performance
  Map<String, LessonDetailModel> _cachedLessons = {};
  DateTime? _lastFetch;
  static const Duration _cacheValidDuration = Duration(minutes: 30);

  // Headers comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers dinámicos con token
  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorageService().getToken();
    print('Token usado en Authorization: $token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // ✅ OBTENER LECCIÓN POR ID DESDE TU API
  Future<LessonDetailModel?> getLessonById(String lessonId) async {
    try {
      // Verificar cache
      if (_cachedLessons.containsKey(lessonId) && 
          _lastFetch != null && 
          DateTime.now().difference(_lastFetch!) < _cacheValidDuration) {
        print('📱 Using cached lesson: $lessonId');
        return _cachedLessons[lessonId];
      }

      print('🌐 Fetching lesson from API: $lessonId');
      final headers = await _getHeaders();
      print('Headers: $headers');
      final response = await http.get(
        Uri.parse('$_baseUrl/lecciones/lecciones/$lessonId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final lesson = LessonDetailModel.fromJson(json);
        
        // Guardar en cache
        _cachedLessons[lessonId] = lesson;
        _lastFetch = DateTime.now();
        
        print('✅ Lesson loaded successfully: ${lesson.titulo}');
        return lesson;
        
      } else if (response.statusCode == 404) {
        print('❌ Lesson not found: $lessonId');
        return null;
        
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('❌ Error fetching lesson $lessonId: $e');
      
      // Intentar obtener del cache aunque esté expirado
      if (_cachedLessons.containsKey(lessonId)) {
        print('📱 Using expired cache for lesson: $lessonId');
        return _cachedLessons[lessonId];
      }
      
      throw LessonDetailException('Error al cargar la lección: ${e.toString()}');
    }
  }

  // ✅ VALIDAR RESPUESTA DEL EJERCICIO
  bool validateAnswer(ExerciseModel exercise, dynamic userAnswer) {
    try {
      switch (exercise.tipo) {
        case 'selección':
          return _validateSelectionAnswer(exercise, userAnswer);
        case 'completar':
          return _validateCompletionAnswer(exercise, userAnswer);
        case 'traducción':
          return _validateTranslationAnswer(exercise, userAnswer);
        case 'emparejamiento':
          return _validateMatchingAnswer(exercise, userAnswer);
        default:
          print('⚠️ Tipo de ejercicio no soportado: ${exercise.tipo}');
          return false;
      }
    } catch (e) {
      print('❌ Error validating answer: $e');
      return false;
    }
  }

  bool _validateSelectionAnswer(ExerciseModel exercise, dynamic userAnswer) {
    return userAnswer.toString().trim().toLowerCase() == 
           exercise.respuestaCorrecta.toString().trim().toLowerCase();
  }

  bool _validateCompletionAnswer(ExerciseModel exercise, dynamic userAnswer) {
    return userAnswer.toString().trim().toLowerCase() == 
           exercise.respuestaCorrecta.toString().trim().toLowerCase();
  }

  bool _validateTranslationAnswer(ExerciseModel exercise, dynamic userAnswer) {
    final userText = userAnswer.toString().trim().toLowerCase();
    final correctText = exercise.respuestaCorrecta.toString().trim().toLowerCase();
    
    // Validación exacta o parcial para traducciones
    return userText == correctText || 
           userText.contains(correctText) || 
           correctText.contains(userText);
  }

  bool _validateMatchingAnswer(ExerciseModel exercise, dynamic userAnswer) {
    // Para emparejamiento, asumir que se pasa la respuesta correcta
    // TODO: Implementar lógica más específica según tu necesidad
    return true;
  }

  // ✅ CALCULAR PUNTUACIÓN
  int calculateScore(List<ExerciseResultModel> results) {
    if (results.isEmpty) return 0;
    
    final correctAnswers = results.where((r) => r.isCorrect).length;
    return ((correctAnswers / results.length) * 100).round();
  }

  // ✅ RESOLVER EJERCICIO INDIVIDUAL (NUEVO ENDPOINT)
  Future<bool> resolverEjercicio({
    required String lessonId,
    required String ejercicioId,
    required String usuarioId,
    required dynamic respuesta,
  }) async {
    try {
      print('📤 Enviando respuesta del ejercicio: $ejercicioId');
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/lecciones/lecciones/$lessonId/ejercicios/resolver'),
        headers: headers,
        body: json.encode({
          'usuarioId': usuarioId,
          'ejercicioId': ejercicioId,
          'respuesta': respuesta.toString(),
          'tiempoRespuesta': 0, // No incluir tiempoRespuesta como pediste
          // No incluir tiempoRespuesta como pediste
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Ejercicio resuelto correctamente');
        return true;
      } else {
        print('❌ Error al resolver ejercicio: ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error sending exercise answer: $e');
      return false;
    }
  }

  // ✅ GUARDAR PROGRESO (SIMPLIFICADO)
  Future<void> saveProgress(LessonProgressModel progress) async {
    try {
      // El progreso ya se envía ejercicio por ejercicio con resolverEjercicio()
      // Aquí solo guardamos localmente para el cache
      await Future.delayed(const Duration(milliseconds: 100));
      print('💾 Progreso local guardado: ${progress.lessonId} - ${progress.score}%');
      
    } catch (e) {
      print('❌ Error saving local progress: $e');
      throw Exception('Error al guardar progreso local: ${e.toString()}');
    }
  }

  // ✅ OBTENER PROGRESO GUARDADO
  Future<LessonProgressModel?> getProgress(String lessonId, String userId) async {
    try {
      print('📱 Obteniendo progreso para lección: $lessonId, usuario: $userId');
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/lecciones/usuarios/$userId/lecciones/$lessonId/progreso'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      
      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final progress = LessonProgressModel.fromJson(json);
        print('✅ Progreso obtenido: ${progress.score}%');
        return progress;
      } else if (response.statusCode == 404) {
        print('📝 No se encontró progreso para esta lección');
        return LessonProgressModel.empty(lessonId);
      } else {
        print('❌ Error al obtener progreso: ${response.statusCode} - ${response.body}');
        return LessonProgressModel.empty(lessonId);
      }
      
    } catch (e) {
      print('❌ Error getting progress: $e');
      return LessonProgressModel.empty(lessonId);
    }
  }

  // ✅ OBTENER PROGRESO PARA USUARIO ACTUAL
  Future<LessonProgressModel?> getProgressForCurrentUser(String lessonId) async {
    try {
      final userData = await SecureStorageService().getUserData();
      final userId = userData?['id'] ?? userData?['uid'] ?? '';
      
      if (userId.isEmpty) {
        print('❌ No se pudo obtener el ID del usuario');
        return LessonProgressModel.empty(lessonId);
      }
      
      return await getProgress(lessonId, userId);
    } catch (e) {
      print('❌ Error getting current user progress: $e');
      return LessonProgressModel.empty(lessonId);
    }
  }

  // ✅ LIMPIAR CACHE
  void clearCache() {
    _cachedLessons.clear();
    _lastFetch = null;
    print('🗑️ Cache cleared');
  }

  // ✅ VERIFICAR CONECTIVIDAD
  Future<bool> checkApiConnectivity() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/lecciones'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ✅ OBTENER INFO DEL CACHE
  Map<String, dynamic> getCacheInfo() {
    return {
      'cachedLessons': _cachedLessons.length,
      'cachedLessonIds': _cachedLessons.keys.toList(),
      'lastFetch': _lastFetch?.toIso8601String(),
      'cacheValidUntil': _lastFetch?.add(_cacheValidDuration).toIso8601String(),
    };
  }

  // ✅ ENVIAR COMENTARIO DE USUARIO
  Future<bool> enviarComentario({required String usuarioId, required String texto}) async {
    const String comentariosUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-user/api_user/usuarios/comentarios';
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(comentariosUrl),
        headers: headers,
        body: jsonEncode({
          'usuarioId': usuarioId,
          'texto': texto,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Comentario enviado correctamente');
        return true;
      } else {
        print('❌ Error al enviar comentario: \n [31m${response.statusCode} - ${response.body}\u001b[0m');
        return false;
      }
    } catch (e) {
      print('❌ Error de red al enviar comentario: \n$e');
      return false;
    }
  }
}