// lessons/models/api_lesson_model.dart

import 'package:integrador/games/lecciones/lesson_model.dart';

class ApiLessonModel {
  final String id;
  final String titulo;
  final NivelModel nivel;
  final ContenidoJsonModel contenidoJson;
  final String idioma;
  final List<EjercicioModel> ejercicios;
  final List<EventoModel> eventos;

  const ApiLessonModel({
    required this.id,
    required this.titulo,
    required this.nivel,
    required this.contenidoJson,
    required this.idioma,
    required this.ejercicios,
    required this.eventos,
  });

  factory ApiLessonModel.fromJson(Map<String, dynamic> json) {
    return ApiLessonModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      nivel: NivelModel.fromJson(json['nivel'] ?? {}),
      contenidoJson: ContenidoJsonModel.fromJson(json['contenidoJson'] ?? {}),
      idioma: json['idioma'] ?? '',
      ejercicios: (json['ejercicios'] as List<dynamic>?)
          ?.map((e) => EjercicioModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      eventos: (json['eventos'] as List<dynamic>?)
          ?.map((e) => EventoModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Convertir a tu LessonModel existente para compatibilidad
  LessonModel toLessonModel() {
    return LessonModel(
      id: id,
      icon: _getIconForLevel(nivel.value),
      title: titulo,
      subtitle: '${_capitalizeLevel(nivel.value)} • ${_estimateDuration(ejercicios.length)} min',
      progress: 0.0, // Por defecto, se puede actualizar desde progreso guardado
      difficulty: _capitalizeLevel(nivel.value),
      duration: _estimateDuration(ejercicios.length),
      isCompleted: false, // Se actualiza desde progreso guardado
      isLocked: false, // Se determina por lógica de negocio
      lessonNumber: _extractLessonNumber(),
      level: _capitalizeLevel(nivel.value),
      wordCount: ejercicios.length * 3, // Estimación
    );
  }

  String _getIconForLevel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'basico':
        return '🌅';
      case 'intermedio':
        return '🌽';
      case 'avanzado':
        return '🏔️';
      default:
        return '📚';
    }
  }

  String _capitalizeLevel(String nivel) {
    return nivel[0].toUpperCase() + nivel.substring(1);
  }

  int _estimateDuration(int exerciseCount) {
    return (exerciseCount * 2).clamp(5, 20); // 2 min por ejercicio, min 5, max 20
  }

  int _extractLessonNumber() {
    // Intentar extraer número del título o usar hash del ID
    final match = RegExp(r'\d+').firstMatch(titulo);
    return match != null ? int.parse(match.group(0)!) : id.hashCode % 100;
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

class EjercicioModel {
  final String id;
  final String leccionId;
  final String tipo;
  final String enunciado;
  final ContenidoEjercicioModel contenido;
  final String respuestaCorrecta;
  final List<EventoModel> eventos;

  const EjercicioModel({
    required this.id,
    required this.leccionId,
    required this.tipo,
    required this.enunciado,
    required this.contenido,
    required this.respuestaCorrecta,
    required this.eventos,
  });

  factory EjercicioModel.fromJson(Map<String, dynamic> json) {
    return EjercicioModel(
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

  // Para compatibilidad con el sistema anterior
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
