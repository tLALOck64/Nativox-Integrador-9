import 'package:integrador/games/models/exercise_detail_model.dart';
import 'package:integrador/games/models/lesson_detail_model.dart';

class LessonDetailService {
  // Datos mock basados en tu JSON
  static const List<Map<String, dynamic>> _mockLessons = [
    {
      "titulo": "Saludos y expresiones básicas en zapoteco",
      "nivel": "basico",
      "contenidoJson": {
        "descripcion": "Lección de introducción al zapoteco del Istmo, enfocada en saludos y frases conversacionales básicas.",
        "objetivos": ["Aprender saludos comunes", "Practicar frases introductorias", "Entender el uso de tonos en saludos"]
      },
      "idioma": "zapoteco_istmo",
      "ejercicios": [
        {
          "tipo": "selección",
          "enunciado": "¿Cómo se dice 'Hola' en zapoteco del Istmo?",
          "opciones": ["Bixho'zhe", "Naxhi' la?", "Qué riene", "Guela'"],
          "imagenes": [],
          "respuestaCorrecta": "Bixho'zhe"
        },
        {
          "tipo": "completar",
          "enunciado": "Completa la frase: ______ lu didxazá la? (¿Entiendes zapoteco?)",
          "opciones": ["Riene", "Naxhi'", "Huaxhi'", "Cayaca"],
          "imagenes": [],
          "respuestaCorrecta": "Riene"
        },
        {
          "tipo": "traducción",
          "enunciado": "Traduce al español: Naxhi' la lu?",
          "opciones": [],
          "imagenes": [],
          "respuestaCorrecta": "¿Cómo estás (está)?"
        },
        {
          "tipo": "emparejamiento",
          "enunciado": "Relaciona cada frase en zapoteco con su traducción en español:",
          "opciones": [
            {"zapoteco": "Bixho'zhe ladi", "español": "Buenos días"},
            {"zapoteco": "Bixho'zhe guela", "español": "Buenas noches"},
            {"zapoteco": "Naxhi' cayaca la?", "español": "¿Cómo te sientes?"}
          ],
          "imagenes": [],
          "respuestaCorrecta": [
            {"zapoteco": "Bixho'zhe ladi", "español": "Buenos días"},
            {"zapoteco": "Bixho'zhe guela", "español": "Buenas noches"},
            {"zapoteco": "Naxhi' cayaca la?", "español": "¿Cómo te sientes?"}
          ]
        }
      ]
    },
    {
      "titulo": "Números en zapoteco",
      "nivel": "basico",
      "contenidoJson": {
        "descripcion": "Lección para aprender los números cardinales del 1 al 10 en zapoteco del Istmo y su uso en contextos básicos.",
        "objetivos": ["Memorizar números cardinales del 1 al 10", "Usar números en frases simples", "Reconocer la estructura de números compuestos"]
      },
      "idioma": "zapoteco_istmo",
      "ejercicios": [
        {
          "tipo": "selección",
          "enunciado": "¿Cómo se dice 'cinco' en zapoteco del Istmo?",
          "opciones": ["tobi", "gaayu'", "chona", "chi"],
          "imagenes": [],
          "respuestaCorrecta": "gaayu'"
        },
        {
          "tipo": "emparejamiento",
          "enunciado": "Relaciona cada número en zapoteco con su traducción en español:",
          "opciones": [
            {"zapoteco": "tobi", "español": "uno"},
            {"zapoteco": "chupa", "español": "dos"},
            {"zapoteco": "chona", "español": "tres"},
            {"zapoteco": "tapa", "español": "cuatro"}
          ],
          "imagenes": [],
          "respuestaCorrecta": [
            {"zapoteco": "tobi", "español": "uno"},
            {"zapoteco": "chupa", "español": "dos"},
            {"zapoteco": "chona", "español": "tres"},
            {"zapoteco": "tapa", "español": "cuatro"}
          ]
        }
      ]
    },
    {
      "titulo": "Vocabulario cotidiano en zapoteco",
      "nivel": "basico",
      "contenidoJson": {
        "descripcion": "Lección para aprender sustantivos comunes en zapoteco del Istmo, como animales y objetos cotidianos.",
        "objetivos": ["Memorizar sustantivos básicos", "Usar vocabulario en frases simples", "Reconocer palabras con múltiples significados"]
      },
      "idioma": "zapoteco_istmo",
      "ejercicios": [
        {
          "tipo": "selección",
          "enunciado": "¿Cómo se dice 'perro' en zapoteco del Istmo?",
          "opciones": ["bicu'", "bidxu", "bere", "bida'wi"],
          "imagenes": [],
          "respuestaCorrecta": "bicu'"
        },
        {
          "tipo": "traducción",
          "enunciado": "Traduce al zapoteco: 'tortilla'",
          "opciones": [],
          "imagenes": [],
          "respuestaCorrecta": "gueta"
        },
        {
          "tipo": "emparejamiento",
          "enunciado": "Relaciona cada palabra en zapoteco con su traducción en español:",
          "opciones": [
            {"zapoteco": "bidxiguí", "español": "araña"},
            {"zapoteco": "biguidi'", "español": "mariposa"},
            {"zapoteco": "benda", "español": "pescado, pez"}
          ],
          "imagenes": [],
          "respuestaCorrecta": [
            {"zapoteco": "bidxiguí", "español": "araña"},
            {"zapoteco": "biguidi'", "español": "mariposa"},
            {"zapoteco": "benda", "español": "pescado, pez"}
          ]
        }
      ]
    }
  ];

  Future<LessonDetailModel?> getLessonById(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simular red
    
    try {
      final index = int.parse(lessonId);
      if (index >= 0 && index < _mockLessons.length) {
        return LessonDetailModel.fromJson(_mockLessons[index]);
      }
    } catch (e) {
      // Si lessonId no es un número, buscar por título
      final lesson = _mockLessons.firstWhere(
        (lesson) => lesson['titulo'].toString().toLowerCase()
            .contains(lessonId.toLowerCase()),
        orElse: () => _mockLessons.first,
      );
      return LessonDetailModel.fromJson(lesson);
    }
    
    return null;
  }

  Future<List<LessonDetailModel>> getAllLessons() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _mockLessons
        .map((json) => LessonDetailModel.fromJson(json))
        .toList();
  }

  // Validar respuesta del ejercicio
  bool validateAnswer(ExerciseModel exercise, dynamic userAnswer) {
    switch (exercise.tipo) {
      case 'selección':
      case 'completar':
      case 'traducción':
        return userAnswer.toString().toLowerCase().trim() ==
               exercise.respuestaCorrecta.toString().toLowerCase().trim();
      
      case 'emparejamiento':
        if (userAnswer is! List || exercise.respuestaCorrecta is! List) {
          return false;
        }
        
        final userList = userAnswer as List;
        final correctList = exercise.respuestaCorrecta as List;
        
        if (userList.length != correctList.length) return false;
        
        for (int i = 0; i < userList.length; i++) {
          final userItem = userList[i] as Map<String, dynamic>;
          final correctItem = correctList[i] as Map<String, dynamic>;
          
          if (userItem['zapoteco'] != correctItem['zapoteco'] ||
              userItem['español'] != correctItem['español']) {
            return false;
          }
        }
        return true;
      
      default:
        return false;
    }
  }

  // Calcular puntuación de la lección
  int calculateScore(List<ExerciseResultModel> results) {
    if (results.isEmpty) return 0;
    
    final correctAnswers = results.where((r) => r.isCorrect).length;
    return ((correctAnswers / results.length) * 100).round();
  }

  // Guardar progreso (mock)
  Future<void> saveProgress(LessonProgressModel progress) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // En una app real, aquí guardarías en base de datos local o API
    print('Progreso guardado: ${progress.lessonId} - ${progress.score}%');
  }
}
