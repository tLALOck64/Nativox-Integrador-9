import 'dart:convert';
import 'package:integrador/lecciones/data/models/lessons_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:integrador/core/error/failure.dart';

abstract class LessonLocalDataSource {
  Future<List<LessonModel>> getCachedLessons();
  Future<void> cacheLessons(List<LessonModel> lessons);
  Future<LessonModel?> getCachedLessonById(String id);
  Future<void> updateCachedLesson(LessonModel lesson);
  Future<void> clearCache();
}

class LessonLocalDataSourceImpl implements LessonLocalDataSource {
  static const String _cacheKey = 'CACHED_LESSONS';
  static const String _cacheTimeKey = 'CACHE_TIME';
  static const Duration _cacheValidDuration = Duration(minutes: 10);
  
  final SharedPreferences sharedPreferences;

  LessonLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<LessonModel>> getCachedLessons() async {
    try {
      final jsonString = sharedPreferences.getString(_cacheKey);
      final cacheTime = sharedPreferences.getInt(_cacheTimeKey);
      
      if (jsonString == null || cacheTime == null) {
        throw CacheFailure.notFound();
      }
      
      final cacheDateTime = DateTime.fromMillisecondsSinceEpoch(cacheTime);
      final now = DateTime.now();
      
      if (now.difference(cacheDateTime) > _cacheValidDuration) {
        throw CacheFailure.expired();
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => LessonModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is CacheFailure) rethrow;
      throw CacheFailure('Error al leer cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheLessons(List<LessonModel> lessons) async {
    try {
      final jsonString = json.encode(
        lessons.map((lesson) => lesson.toJson()).toList(),
      );
      
      await sharedPreferences.setString(_cacheKey, jsonString);
      await sharedPreferences.setInt(
        _cacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheFailure('Error al guardar en cache: ${e.toString()}');
    }
  }

  @override
  Future<LessonModel?> getCachedLessonById(String id) async {
    try {
      final lessons = await getCachedLessons();
      try {
        return lessons.firstWhere(
          (lesson) => lesson.id == id,
        );
      } catch (e) {
        // No se encontró la lección
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateCachedLesson(LessonModel lesson) async {
    try {
      final lessons = await getCachedLessons();
      final index = lessons.indexWhere((l) => l.id == lesson.id);
      
      if (index != -1) {
        lessons[index] = lesson;
        await cacheLessons(lessons);
      }
    } catch (e) {
      throw CacheFailure('Error al actualizar cache: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_cacheKey);
      await sharedPreferences.remove(_cacheTimeKey);
    } catch (e) {
      throw CacheFailure('Error al limpiar cache: ${e.toString()}');
    }
  }
}