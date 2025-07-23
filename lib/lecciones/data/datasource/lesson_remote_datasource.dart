import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:integrador/core/error/failure.dart';
import 'package:integrador/core/services/secure_storage_service.dart'
    as secure_storage;
import '../models/lessons_models.dart';

abstract class LessonRemoteDataSource {
  Future<List<LessonModel>> getAllLessons();
  Future<LessonModel> getLessonById(String id);
  Future<void> updateLessonProgress(String lessonId, int progress);
  Future<void> completeLesson(String lessonId);
}

class LessonRemoteDataSourceImpl implements LessonRemoteDataSource {
  static const String _baseUrl =
      'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-learning/api_learning';
  final http.Client client;
  LessonRemoteDataSourceImpl({required this.client});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<List<LessonModel>> getAllLessons() async {
    try {
      final storage = secure_storage.SecureStorageService();
      final token = await storage.getToken();

      final headers = Map<String, String>.from(_headers);
      headers['Authorization'] = 'Bearer $token';
      if (token == null || token.isEmpty) {
        throw Exception('Token no encontrado');
      }
      final response = await client
          .get(Uri.parse('$_baseUrl/lecciones/lecciones'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List<dynamic> jsonList = decoded['data'];
        print(jsonList);
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
      final response = await client
          .get(Uri.parse('$_baseUrl/lecciones/$id'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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
      final response = await client
          .put(
            Uri.parse('$_baseUrl/lecciones/$lessonId/progress'),
            headers: _headers,
            body: json.encode({'progress': progress}),
          )
          .timeout(const Duration(seconds: 15));

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
      final response = await client
          .post(
            Uri.parse('$_baseUrl/lecciones/$lessonId/complete'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw NetworkFailure.serverError(response.statusCode);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure.noInternet();
    }
  }
}
