// models/translation_model.dart
class TranslationModel {
  final String idioma;
  final String entrada;
  final String match;
  final String traduccion;

  TranslationModel({
    required this.idioma,
    required this.entrada,
    required this.match,
    required this.traduccion,
  });

  // Factory constructor para crear desde JSON
  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      idioma: json['idioma'] ?? '',
      entrada: json['entrada'] ?? '',
      match: json['match'] ?? '',
      traduccion: json['traduccion'] ?? '',
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'idioma': idioma,
      'entrada': entrada,
      'match': match,
      'traduccion': traduccion,
    };
  }

  // Método para crear una copia con modificaciones
  TranslationModel copyWith({
    String? idioma,
    String? entrada,
    String? match,
    String? traduccion,
  }) {
    return TranslationModel(
      idioma: idioma ?? this.idioma,
      entrada: entrada ?? this.entrada,
      match: match ?? this.match,
      traduccion: traduccion ?? this.traduccion,
    );
  }

  @override
  String toString() {
    return 'TranslationModel(idioma: $idioma, entrada: $entrada, match: $match, traduccion: $traduccion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TranslationModel &&
        other.idioma == idioma &&
        other.entrada == entrada &&
        other.match == match &&
        other.traduccion == traduccion;
  }

  @override
  int get hashCode {
    return idioma.hashCode ^
        entrada.hashCode ^
        match.hashCode ^
        traduccion.hashCode;
  }
}

// models/language_model.dart
class LanguageModel {
  final String name;
  final String code;
  final String flag;
  final bool isAvailable;

  LanguageModel({
    required this.name,
    required this.code,
    required this.flag,
    this.isAvailable = true,
  });

  // Factory constructor para crear desde JSON
  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      flag: json['flag'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'flag': flag,
      'isAvailable': isAvailable,
    };
  }

  @override
  String toString() {
    return 'LanguageModel(name: $name, code: $code, flag: $flag, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageModel &&
        other.name == name &&
        other.code == code &&
        other.flag == flag &&
        other.isAvailable == isAvailable;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        code.hashCode ^
        flag.hashCode ^
        isAvailable.hashCode;
  }
}

// models/translation_request_model.dart
class TranslationRequestModel {
  final String text;
  final String sourceLanguage;
  final String targetLanguage;

  TranslationRequestModel({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
    };
  }

  @override
  String toString() {
    return 'TranslationRequestModel(text: $text, sourceLanguage: $sourceLanguage, targetLanguage: $targetLanguage)';
  }
}