// services/translation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/translation_model.dart';

class TranslationService {
  static const String _baseUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/services-translator/traducir';
  static const Duration _timeoutDuration = Duration(seconds: 10);

  // Idiomas disponibles
  static final List<LanguageModel> _availableLanguages = [
    LanguageModel(name: 'Español', code: 'es', flag: '🇪🇸'),
    LanguageModel(name: 'Tseltal', code: 'tseltal', flag: '🌎'),
    LanguageModel(name: 'Zapoteco', code: 'zapoteco', flag: '🌎'),
  ];

  /// Obtiene la lista de idiomas disponibles
  List<LanguageModel> getAvailableLanguages() {
    return List.from(_availableLanguages);
  }

  /// Traduce un texto entre dos idiomas
  /// 
  /// [text] - Texto a traducir
  /// [sourceLanguage] - Idioma de origen (código)
  /// [targetLanguage] - Idioma de destino (código)
  /// 
  /// Retorna [TranslationModel] con el resultado de la traducción
  Future<TranslationModel> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Validar entrada
      if (text.trim().isEmpty) {
        throw TranslationException('El texto no puede estar vacío');
      }

      // Construir la URL del endpoint
      final endpoint = _buildEndpoint(
        text: text.trim(),
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      // Realizar la petición HTTP
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeoutDuration);

      // Procesar la respuesta
      return _processResponse(response);

    } on TranslationException {
      rethrow;
    } catch (e) {
      throw TranslationException('Error de conexión: ${e.toString()}');
    }
  }

  /// Construye el endpoint correcto según los idiomas
  String _buildEndpoint({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    // Validar combinación de idiomas
    if (!_isValidLanguageCombination(sourceLanguage, targetLanguage)) {
      throw TranslationException(
        'Combinación de idiomas no disponible: $sourceLanguage -> $targetLanguage'
      );
    }

    String endpoint = '';
    
    if (sourceLanguage == 'es' && targetLanguage == 'tseltal') {
      endpoint = '$_baseUrl/tseltal-inverso?palabra=$text';
    } else if (sourceLanguage == 'tseltal' && targetLanguage == 'es') {
      endpoint = '$_baseUrl/tseltal?palabra=$text';
    } else if (sourceLanguage == 'es' && targetLanguage == 'zapoteco') {
      endpoint = '$_baseUrl/zapoteco-inverso?palabra=$text';
    } else if (sourceLanguage == 'zapoteco' && targetLanguage == 'es') {
      endpoint = '$_baseUrl/zapoteco?palabra=$text';
    } else {
      throw TranslationException('Combinación de idiomas no soportada');
    }

    return endpoint;
  }

  /// Valida si la combinación de idiomas es válida
  bool _isValidLanguageCombination(String sourceLanguage, String targetLanguage) {
    final validCombinations = [
      ['es', 'tseltal'],
      ['tseltal', 'es'],
      ['es', 'zapoteco'],
      ['zapoteco', 'es'],
    ];

    return validCombinations.any((combination) =>
        (combination[0] == sourceLanguage && combination[1] == targetLanguage));
  }

  /// Procesa la respuesta HTTP y convierte a TranslationModel
  TranslationModel _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        
        if (data is Map<String, dynamic>) {
          return TranslationModel.fromJson(data);
        } else {
          throw TranslationException('Formato de respuesta inválido');
        }
      } catch (e) {
        if (e is TranslationException) rethrow;
        throw TranslationException('Error al procesar la respuesta: ${e.toString()}');
      }
    } else if (response.statusCode == 404) {
      throw TranslationException('Palabra no encontrada en el diccionario');
    } else if (response.statusCode >= 500) {
      throw TranslationException('Error del servidor. Intenta más tarde');
    } else {
      throw TranslationException('Error de conexión: ${response.statusCode}');
    }
  }

  /// Valida si un idioma es soportado
  bool isLanguageSupported(String languageCode) {
    return _availableLanguages.any((lang) => lang.code == languageCode);
  }

  /// Obtiene un idioma por su código
  LanguageModel? getLanguageByCode(String code) {
    try {
      return _availableLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene las combinaciones válidas de idiomas
  List<Map<String, String>> getValidCombinations() {
    return [
      {'source': 'es', 'target': 'tseltal'},
      {'source': 'tseltal', 'target': 'es'},
      {'source': 'es', 'target': 'zapoteco'},
      {'source': 'zapoteco', 'target': 'es'},
    ];
  }
}

/// Excepción personalizada para errores de traducción
class TranslationException implements Exception {
  final String message;
  
  TranslationException(this.message);
  
  @override
  String toString() => 'TranslationException: $message';
}