class LessonDetailModel {
  final String titulo;
  final String nivel;
  final LessonContent contenidoJson;
  final String idioma;
  final List<ExerciseModel> ejercicios;

  const LessonDetailModel({
    required this.titulo,
    required this.nivel,
    required this.contenidoJson,
    required this.idioma,
    required this.ejercicios,
  });

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) {
    return LessonDetailModel(
      titulo: json['titulo'] ?? '',
      nivel: json['nivel'] ?? '',
      contenidoJson: LessonContent.fromJson(json['contenidoJson'] ?? {}),
      idioma: json['idioma'] ?? '',
      ejercicios: (json['ejercicios'] as List<dynamic>?)
          ?.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class LessonContent {
  final String descripcion;
  final List<String> objetivos;

  const LessonContent({
    required this.descripcion,
    required this.objetivos,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      descripcion: json['descripcion'] ?? '',
      objetivos: (json['objetivos'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}

class ExerciseModel {
  final String tipo;
  final String enunciado;
  final List<dynamic> opciones;
  final List<String> imagenes;
  final dynamic respuestaCorrecta;

  const ExerciseModel({
    required this.tipo,
    required this.enunciado,
    required this.opciones,
    required this.imagenes,
    required this.respuestaCorrecta,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      tipo: json['tipo'] ?? '',
      enunciado: json['enunciado'] ?? '',
      opciones: json['opciones'] ?? [],
      imagenes: (json['imagenes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      respuestaCorrecta: json['respuestaCorrecta'],
    );
  }

  // Helpers para diferentes tipos de ejercicios
  bool get isSeleccion => tipo == 'selección';
  bool get isCompletar => tipo == 'completar';
  bool get isTraduccion => tipo == 'traducción';
  bool get isEmparejamiento => tipo == 'emparejamiento';

  List<String> get opcionesString {
    if (opciones.isEmpty) return [];
    return opciones.map((e) => e.toString()).toList();
  }

  List<Map<String, String>> get opcionesEmparejamiento {
    if (!isEmparejamiento) return [];
    return opciones.cast<Map<String, dynamic>>()
        .map((e) => e.map((k, v) => MapEntry(k, v.toString())))
        .toList();
  }
}
