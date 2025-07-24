// import 'package:speech_to_text/speech_to_text.dart'; // Temporarily commented out due to v1 embedding issues
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb

class AudioTranslatorService {
  // final SpeechToText _speech = SpeechToText(); // Temporarily commented out
  final FlutterTts _tts = FlutterTts();
  
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognizedText = '';
  
  // Callbacks para comunicar con la UI
  Function(String)? _onResult;
  Function(String)? _onTranslation;
  Function(String)? _onError;

  /// Inicializa los servicios de speech-to-text y text-to-speech
  Future<bool> initialize() async {
    try {
      print('🎤 Iniciando AudioTranslatorService...');
      print('🌐 Plataforma:  [1m${kIsWeb ? "Web" : "Móvil"} [0m');
      print('⚠️ Speech-to-Text temporalmente deshabilitado debido a problemas de compatibilidad');

      // Configurar Text to Speech
      print('🔊 Configurando Text-to-Speech...');
      await _configureTTS();

      _isInitialized = true;
      print('🎉 AudioTranslatorService inicializado correctamente (solo TTS)');
      return true;
      
    } catch (e) {
      print('💥 Error al inicializar AudioTranslatorService: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Configura el servicio de Text-to-Speech
  Future<void> _configureTTS() async {
    try {
      // Configurar idioma español mexicano
      await _tts.setLanguage("es-MX");
      
      // Si no está disponible, usar español general
      final languages = await _tts.getLanguages;
      if (!languages.contains("es-MX")) {
        await _tts.setLanguage("es-ES");
      }
      
      // Configuraciones de voz
      await _tts.setSpeechRate(0.5); // Velocidad normal
      await _tts.setVolume(0.8); // Volumen alto
      await _tts.setPitch(1.0); // Tono normal
      
      // Configurar callbacks
      _tts.setStartHandler(() {
        print('TTS: Iniciando reproducción');
      });
      
      _tts.setCompletionHandler(() {
        print('TTS: Reproducción completada');
      });
      
      _tts.setErrorHandler((msg) {
        print('TTS Error: $msg');
      });
      
    } catch (e) {
      print('Error configurando TTS: $e');
      throw Exception('Error al configurar síntesis de voz');
    }
  }

  /// Inicia la escucha de audio (temporalmente deshabilitado)
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onTranslation,
    required Function(String) onError,
  }) async {
    onError('Speech-to-Text temporalmente deshabilitado. Actualiza las dependencias para habilitarlo.');
  }

  /// Detiene la escucha de audio (temporalmente deshabilitado)
  Future<void> stopListening() async {
    print('Speech-to-Text temporalmente deshabilitado');
  }

  /// Procesa el texto en zapoteco y lo traduce
  Future<void> _processZapotecoText(String zapotecoText) async {
    try {
      print('Procesando texto zapoteco: $zapotecoText');
      
      // Aquí integrarías tu modelo de predicción
      // Por ahora simulo una traducción
      String translation = await _translateZapotecoToSpanish(zapotecoText);
      
      _onTranslation?.call(translation);
      
    } catch (e) {
      _onError?.call('Error al traducir: $e');
    }
  }

  /// Traduce el texto zapoteco a español usando tu modelo
  Future<String> _translateZapotecoToSpanish(String zapotecoText) async {
    try {
      // AQUÍ INTEGRAS TU MODELO DE PREDICCIÓN REAL
      print('Procesando con modelo: $zapotecoText');
      
      await Future.delayed(const Duration(milliseconds: 800)); // Simular procesamiento
      
      // SIMULACIÓN TEMPORAL - Quita esto cuando integres tu modelo
      if (zapotecoText.trim().isEmpty) {
        return 'Por favor, habla algo en zapoteco';
      }
      
      // Simulación básica para testing
      final Map<String, String> simulatedTranslations = {
        'guelaguetza': 'fiesta tradicional',
        'mole': 'salsa tradicional mexicana',
        'copal': 'incienso sagrado',
        'mezcal': 'bebida destilada de agave',
        'tejate': 'bebida tradicional',
      };
      
      // Buscar coincidencias en el diccionario simulado
      for (var entry in simulatedTranslations.entries) {
        if (zapotecoText.toLowerCase().contains(entry.key)) {
          return 'Traducción: ${entry.value}';
        }
      }
      
      // Respuesta genérica para testing
      return 'Procesando zapoteco: "$zapotecoText" → [Aquí iría tu traducción real]';
      
    } catch (e) {
      throw Exception('Error en traducción: $e');
    }
  }

  /// Reproduce texto en español usando TTS
  Future<void> speakText(String text) async {
    if (!_isInitialized) {
      throw Exception('Servicio no inicializado');
    }

    try {
      // Detener cualquier reproducción en curso
      await _tts.stop();
      
      // Reproducir el texto
      await _tts.speak(text);
      
    } catch (e) {
      throw Exception('Error al reproducir texto: $e');
    }
  }

  /// Detiene la reproducción de TTS
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('Error al detener TTS: $e');
    }
  }

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _isInitialized;
  
  /// Verifica si está escuchando actualmente
  bool get isListening => _isListening;
  
  /// Obtiene el último texto reconocido
  String get lastRecognizedText => _lastRecognizedText;

  /// Obtiene información sobre las capacidades del dispositivo
  Future<Map<String, dynamic>> getDeviceCapabilities() async {
    try {
      final hasPermission = kIsWeb ? true : await Permission.microphone.isGranted;
      
      return {
        'platform': kIsWeb ? 'web' : 'mobile',
        'hasMicrophonePermission': hasPermission,
        'speechToTextAvailable': false, // Temporalmente deshabilitado
        'totalLanguages': 0,
        'zapotecoLanguagesCount': 0,
        'zapotecoLanguages': [],
        'note': 'Speech-to-Text temporalmente deshabilitado debido a problemas de compatibilidad'
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Configura parámetros del TTS
  Future<void> configureTTSSettings({
    double? speechRate,
    double? volume,
    double? pitch,
    String? language,
  }) async {
    try {
      if (speechRate != null) {
        await _tts.setSpeechRate(speechRate);
      }
      if (volume != null) {
        await _tts.setVolume(volume);
      }
      if (pitch != null) {
        await _tts.setPitch(pitch);
      }
      if (language != null) {
        await _tts.setLanguage(language);
      }
    } catch (e) {
      throw Exception('Error configurando TTS: $e');
    }
  }

  /// Obtiene las voces disponibles para TTS
  Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      final voices = await _tts.getVoices;
      return voices.map<Map<String, String>>((voice) => {
        'name': voice['name'] ?? '',
        'locale': voice['locale'] ?? '',
      }).toList();
    } catch (e) {
      print('Error obteniendo voces: $e');
      return [];
    }
  }

  /// Integración con tu modelo de predicción - método para personalizar
  void setCustomTranslationFunction(Future<String> Function(String) customTranslator) {
    _customTranslator = customTranslator;
  }
  
  Future<String> Function(String)? _customTranslator;

  /// Versión actualizada del traductor que usa función personalizada si está disponible
  Future<String> _translateZapotecoToSpanishUpdated(String zapotecoText) async {
    try {
      // Si hay un traductor personalizado, usarlo
      if (_customTranslator != null) {
        return await _customTranslator!(zapotecoText);
      }
      
      // Fallback a la traducción por defecto
      return await _translateZapotecoToSpanish(zapotecoText);
    } catch (e) {
      throw Exception('Error en traducción personalizada: $e');
    }
  }

  /// Limpia recursos y estado
  void dispose() {
    try {
      // _speech.stop(); // Temporalmente comentado
      _tts.stop();
      _isListening = false;
      _lastRecognizedText = '';
      _onResult = null;
      _onTranslation = null;
      _onError = null;
      _customTranslator = null;
    } catch (e) {
      print('Error al limpiar AudioTranslatorService: $e');
    }
  }

  /// Método para testing y debug
  Future<void> testServices() async {
    try {
      print('=== TESTING AUDIO TRANSLATOR SERVICE ===');
      
      final capabilities = await getDeviceCapabilities();
      print('Capacidades del dispositivo: $capabilities');
      
      final voices = await getAvailableVoices();
      print('Voces disponibles: ${voices.take(5)}'); // Mostrar solo las primeras 5
      
      // Test TTS
      await speakText('Prueba de síntesis de voz en español');
      
      print('=== TEST COMPLETADO ===');
    } catch (e) {
      print('Error en test: $e');
    }
  }
}