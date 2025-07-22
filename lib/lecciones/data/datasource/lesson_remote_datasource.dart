import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:integrador/core/error/failure.dart';
import '../models/lessons_models.dart';

abstract class LessonRemoteDataSource {
  Future<List<LessonModel>> getAllLessons();
  Future<LessonModel> getLessonById(String id);
  Future<void> updateLessonProgress(String lessonId, int progress);
  Future<void> completeLesson(String lessonId);
}

class LessonRemoteDataSourceImpl implements LessonRemoteDataSource {
  static const String _baseUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-learning/api_learning';
  final http.Client client;

  LessonRemoteDataSourceImpl({required this.client});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTI5MzkzNTEsImlhdCI6MTc1Mjg1Mjk1MX0.mIiEGSmpBT_CeiCaggltvgSrobjX7bqceidJVTCr1zo'
  };

  @override
  Future<List<LessonModel>> getAllLessons() async {
    try {
      final response = await client.get(
        Uri.parse('http://localhost:3001/api/lecciones/lecciones'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List<dynamic> jsonList = decoded['data'];

        return jsonList
            .map((json) => LessonModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw AuthFailure.emailAlreadyExists();
      } else {
        throw NetworkFailure.serverError(response.statusCode);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure.noInternet();
    }
  }

  @override
  Future<LessonModel> getLessonById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/lecciones/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return LessonModel.fromJson(json);
      } else if (response.statusCode == 404) {
        throw NetworkFailure.serverError(response.statusCode);
      } else {
        throw NetworkFailure.serverError(response.statusCode);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure.noInternet();
    }
  }

  @override
  Future<void> updateLessonProgress(String lessonId, int progress) async {
    try {
      final response = await client.put(
        Uri.parse('$_baseUrl/lecciones/$lessonId/progress'),
        headers: _headers,
        body: json.encode({'progress': progress}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw NetworkFailure.serverError(response.statusCode);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure.noInternet();
    }
  }

  @override
  Future<void> completeLesson(String lessonId) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/lecciones/$lessonId/complete'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw NetworkFailure.serverError(response.statusCode);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure.noInternet();
    }
  }
}
