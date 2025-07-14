class LessonDetailModel {
  final String id;
  final String titulo;
  final NivelModel nivel;
  final ContenidoJsonModel contenidoJson;
  final String idioma;
  final List<ExerciseModel> ejercicios;
  final List<EventoModel> eventos;

  const LessonDetailModel({
    required this.id,
    required this.titulo,
    required this.nivel,
    required this.contenidoJson,
    required this.idioma,
    required this.ejercicios,
    required this.eventos,
  });

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) {
    return LessonDetailModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      nivel: NivelModel.fromJson(json['nivel'] ?? {}),
      contenidoJson: ContenidoJsonModel.fromJson(json['contenidoJson'] ?? {}),
      idioma: json['idioma'] ?? '',
      ejercicios: (json['ejercicios'] as List<dynamic>?)
          ?.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      eventos: (json['eventos'] as List<dynamic>?)
          ?.map((e) => EventoModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class NivelModel {
  final String value;

  const NivelModel({required this.value});

  factory NivelModel.fromJson(Map<String, dynamic> json) {
    return NivelModel(value: json['value'] ?? '');
  }
}

class ContenidoJsonModel {
  final List<String> objetivos;
  final String descripcion;

  const ContenidoJsonModel({
    required this.objetivos,
    required this.descripcion,
  });

  factory ContenidoJsonModel.fromJson(Map<String, dynamic> json) {
    return ContenidoJsonModel(
      objetivos: (json['objetivos'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      descripcion: json['descripcion'] ?? '',
    );
  }
}

class ExerciseModel {
  final String id;
  final String leccionId;
  final String tipo;
  final String enunciado;
  final ContenidoEjercicioModel contenido;
  final String respuestaCorrecta;
  final List<EventoModel> eventos;

  const ExerciseModel({
    required this.id,
    required this.leccionId,
    required this.tipo,
    required this.enunciado,
    required this.contenido,
    required this.respuestaCorrecta,
    required this.eventos,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? '',
      leccionId: json['leccionId'] ?? '',
      tipo: json['tipo'] ?? '',
      enunciado: json['enunciado'] ?? '',
      contenido: ContenidoEjercicioModel.fromJson(json['contenido'] ?? {}),
      respuestaCorrecta: json['respuestaCorrecta'] ?? '',
      eventos: (json['eventos'] as List<dynamic>?)
          ?.map((e) => EventoModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Helpers para tipos de ejercicio
  bool get isSeleccion => tipo == 'selección';
  bool get isCompletar => tipo == 'completar';
  bool get isTraduccion => tipo == 'traducción';
  bool get isEmparejamiento => tipo == 'emparejamiento';
}

class ContenidoEjercicioModel {
  final String texto;
  final List<String> imagenes;
  final List<String> opciones;

  const ContenidoEjercicioModel({
    required this.texto,
    required this.imagenes,
    required this.opciones,
  });

  factory ContenidoEjercicioModel.fromJson(Map<String, dynamic> json) {
    return ContenidoEjercicioModel(
      texto: json['texto'] ?? '',
      imagenes: (json['imagenes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      opciones: (json['opciones'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}

class EventoModel {
  final String aggregateId;
  final String occurredOn;
  final String? titulo;
  final String? nivel;
  final String? idioma;

  const EventoModel({
    required this.aggregateId,
    required this.occurredOn,
    this.titulo,
    this.nivel,
    this.idioma,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      aggregateId: json['aggregateId'] ?? '',
      occurredOn: json['occurredOn'] ?? '',
      titulo: json['titulo'],
      nivel: json['nivel'],
      idioma: json['idioma'],
    );
  }
}

// Modelos para progreso
class ExerciseResultModel {
  final int exerciseIndex;
  final dynamic userAnswer;
  final bool isCorrect;
  final DateTime timestamp;

  const ExerciseResultModel({
    required this.exerciseIndex,
    required this.userAnswer,
    required this.isCorrect,
    required this.timestamp,
  });
}

class LessonProgressModel {
  final String lessonId;
  final List<ExerciseResultModel> results;
  final double completionPercentage;
  final bool isCompleted;
  final int score;

  const LessonProgressModel({
    required this.lessonId,
    required this.results,
    required this.completionPercentage,
    required this.isCompleted,
    required this.score,
  });

  factory LessonProgressModel.empty(String lessonId) {
    return LessonProgressModel(
      lessonId: lessonId,
      results: [],
      completionPercentage: 0.0,
      isCompleted: false,
      score: 0,
    );
  }
}

// Excepciones personalizadas
class LessonDetailException implements Exception {
  final String message;
  final String? code;

  const LessonDetailException(this.message, {this.code});

  @override
  String toString() => 'LessonDetailException: $message';
}
