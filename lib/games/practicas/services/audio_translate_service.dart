import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb

class AudioTranslatorService {
  final SpeechToText _speech = SpeechToText();
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

      // Manejar permisos según la plataforma
      if (!kIsWeb) {
        print('📱 Solicitando permisos de micrófono en móvil...');
        final microphoneStatus = await Permission.microphone.request();
        print('🔐 Estado de permisos: $microphoneStatus');
        
        if (microphoneStatus != PermissionStatus.granted) {
          throw Exception('Permisos de micrófono denegados');
        }
      } else {
        print('🌐 En web - los permisos se solicitan automáticamente por el navegador al presionar el botón de grabar.');
      }

      // Verificar disponibilidad antes de inicializar
      print('🔍 Verificando disponibilidad de Speech-to-Text...');
      
      // Inicializar Speech to Text con reintentos
      bool speechAvailable = false;
      int intentos = 0;
      const maxIntentos = 3;
      
      while (!speechAvailable && intentos < maxIntentos) {
        intentos++;
        print('🔄 Intento $intentos de $maxIntentos...');
        
        try {
          speechAvailable = await _speech.initialize(
            onStatus: _onSpeechStatus,
            onError: _onSpeechError,
            debugLogging: true, // Activar logs para debug
          );
          
          if (speechAvailable) {
            print('✅ Speech-to-Text inicializado correctamente');
            break;
          } else {
            print('❌ Speech-to-Text no disponible en intento $intentos');
            if (intentos < maxIntentos) {
              await Future.delayed(Duration(milliseconds: 500));
            }
          }
        } catch (e) {
          print('💥 Error en intento $intentos: $e');
          if (intentos < maxIntentos) {
            await Future.delayed(Duration(milliseconds: 500));
          }
        }
      }

      if (!speechAvailable) {
        // Información de diagnóstico
        await _diagnosticarProblema();
        if (kIsWeb) {
          throw Exception('Speech-to-Text no está disponible en este navegador. Prueba con Google Chrome en escritorio y asegúrate de usar HTTPS o localhost.');
        } else {
          throw Exception('Speech-to-Text no está disponible en este dispositivo.');
        }
      }

      // Configurar Text to Speech
      print('🔊 Configurando Text-to-Speech...');
      await _configureTTS();

      // Verificar idiomas disponibles
      print('🌍 Verificando idiomas disponibles...');
      await _checkAvailableLanguages();

      _isInitialized = true;
      print('🎉 AudioTranslatorService inicializado correctamente');
      return true;
      
    } catch (e) {
      print('💥 Error al inicializar AudioTranslatorService: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Diagnostica problemas de inicialización
  Future<void> _diagnosticarProblema() async {
    print('🔍 === DIAGNÓSTICO DE PROBLEMAS ===');
    
    try {
      // Verificar si el dispositivo tiene micrófono
      print('🎤 Verificando disponibilidad de micrófono...');
      
      if (kIsWeb) {
        print('🌐 Plataforma: Web');
        print('🔗 URL actual: ${Uri.base}');
        print('🔒 Protocolo seguro (HTTPS): ${Uri.base.scheme == 'https' || Uri.base.host == 'localhost'}');
        
        // En web, verificar si getUserMedia está disponible
        print('📱 Navigator.mediaDevices disponible: disponible (no se puede verificar desde Dart)');
      } else {
        print('📱 Plataforma: Móvil (Android/iOS)');
        
        // Verificar permisos en móvil
        final status = await Permission.microphone.status;
        print('🔐 Estado actual de permisos: $status');
      }
      
      // Verificar disponibilidad básica
      final available = _speech.isAvailable;
      print('🎯 Speech instance disponible: $available');
      
    } catch (e) {
      print('💥 Error en diagnóstico: $e');
    }
    
    print('=== FIN DIAGNÓSTICO ===');
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

  /// Verifica y muestra los idiomas disponibles para STT
  Future<void> _checkAvailableLanguages() async {
    try {
      List<LocaleName> locales = await _speech.locales();
      
      print('=== IDIOMAS DISPONIBLES PARA SPEECH-TO-TEXT ===');
      
      // Buscar idiomas zapoteco
      final zapotecoLocales = locales.where((locale) =>
        locale.localeId.toLowerCase().contains('zap') ||
        locale.name.toLowerCase().contains('zapotec') ||
        locale.localeId.toLowerCase().contains('ztu')
      ).toList();
      
      if (zapotecoLocales.isNotEmpty) {
        print('Idiomas zapoteco encontrados:');
        for (var locale in zapotecoLocales) {
          print('  ${locale.localeId}: ${locale.name}');
        }
      } else {
        print('No se encontraron idiomas zapoteco específicos');
        print('Usando reconocimiento genérico...');
      }
      
      // Mostrar algunos idiomas disponibles para debug
      print('Otros idiomas disponibles (primeros 10):');
      for (int i = 0; i < locales.length && i < 10; i++) {
        print('  ${locales[i].localeId}: ${locales[i].name}');
      }
      
    } catch (e) {
      print('Error verificando idiomas: $e');
    }
  }

  /// Inicia la escucha de audio
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onTranslation,
    required Function(String) onError,
  }) async {
    if (!_isInitialized) {
      onError('Servicio no inicializado');
      return;
    }

    if (_isListening) {
      onError('Ya se está escuchando');
      return;
    }

    // Guardar callbacks
    _onResult = onResult;
    _onTranslation = onTranslation;
    _onError = onError;

    try {
      _isListening = true;
      _lastRecognizedText = '';

      await _speech.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30), // Máximo 30 segundos
        pauseFor: const Duration(seconds: 3), // Pausa de 3 segundos
        partialResults: true, // Mostrar resultados parciales
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
        
        // Intentar usar zapoteco, si no está disponible usar genérico
        localeId: await _getBestZapotecoLocale(),
      );
      
    } catch (e) {
      _isListening = false;
      onError('Error al iniciar escucha: $e');
    }
  }

  /// Obtiene el mejor código de idioma zapoteco disponible
  Future<String> _getBestZapotecoLocale() async {
    try {
      List<LocaleName> locales = await _speech.locales();
      
      // Lista de códigos zapoteco para probar (en orden de preferencia)
      final zapotecoCodes = [
        'zap-MX', // Zapoteco mexicano
        'zap',    // Zapoteco genérico
        'ztu-MX', // Zapoteco de Güilá
        'ztu',    // Zapoteco de Güilá genérico
      ];
      
      // Buscar el primer código disponible
      for (String code in zapotecoCodes) {
        if (locales.any((locale) => locale.localeId == code)) {
          print('Usando idioma zapoteco: $code');
          return code;
        }
      }
      
      // Si no encuentra zapoteco específico, usar español como fallback
      // para que al menos funcione el reconocimiento
      print('No se encontró zapoteco específico, usando es-MX como fallback');
      return 'es-MX';
      
    } catch (e) {
      print('Error obteniendo idioma zapoteco: $e');
      return 'es-MX'; // Fallback seguro
    }
  }

  /// Detiene la escucha de audio
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
      _isListening = false;
      
      // Si hay texto reconocido, procesarlo
      if (_lastRecognizedText.isNotEmpty) {
        await _processZapotecoText(_lastRecognizedText);
      }
      
    } catch (e) {
      _isListening = false;
      _onError?.call('Error al detener escucha: $e');
    }
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
      
      // TODO: Reemplazar esta simulación con tu modelo real
      // Ejemplos de integración:
      
      // 1. Si tu modelo es una API REST:
      /*
      final response = await http.post(
        Uri.parse('https://tu-api.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': zapotecoText, 'from': 'zap', 'to': 'es'}),
      );
      final data = jsonDecode(response.body);
      return data['translation'];
      */
      
      // 2. Si tu modelo es local con TensorFlow Lite:
      /*
      final input = preprocessText(zapotecoText);
      final output = await _interpreter.run(input);
      return postprocessOutput(output);
      */
      
      // 3. Si usas un servicio personalizado:
      /*
      final result = await YourModelService.translate(zapotecoText);
      return result.translatedText;
      */
      
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

  /// Callback cuando cambia el estado del speech-to-text
  void _onSpeechStatus(String status) {
    print('Speech Status: $status');
    
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }

  /// Callback cuando hay error en speech-to-text
  void _onSpeechError(dynamic error) {
    print('Speech Error: $error');
    _isListening = false;
    _onError?.call('Error de reconocimiento: ${error.errorMsg ?? error.toString()}');
  }

  /// Callback cuando se obtienen resultados del speech-to-text
  void _onSpeechResult(dynamic result) {
    try {
      final recognizedWords = result.recognizedWords ?? '';
      _lastRecognizedText = recognizedWords;
      
      // Informar a la UI sobre el texto reconocido
      _onResult?.call(recognizedWords);
      
      // Si es resultado final, procesar para traducción
      if (result.finalResult && recognizedWords.isNotEmpty) {
        _processZapotecoText(recognizedWords);
      }
      
    } catch (e) {
      print('Error procesando resultado de voz: $e');
      _onError?.call('Error procesando resultado: $e');
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
      final speechAvailable = await _speech.isAvailable;
      final locales = await _speech.locales();
      
      final zapotecoLocales = locales.where((locale) =>
        locale.localeId.toLowerCase().contains('zap') ||
        locale.name.toLowerCase().contains('zapotec')
      ).toList();
      
      return {
        'platform': kIsWeb ? 'web' : 'mobile',
        'hasMicrophonePermission': hasPermission,
        'speechToTextAvailable': speechAvailable,
        'totalLanguages': locales.length,
        'zapotecoLanguagesCount': zapotecoLocales.length,
        'zapotecoLanguages': zapotecoLocales.map((l) => {
          'id': l.localeId,
          'name': l.name,
        }).toList(),
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
      _speech.stop();
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