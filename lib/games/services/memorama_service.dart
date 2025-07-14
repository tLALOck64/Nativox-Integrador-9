import 'dart:math';
import '../models/memorama_model.dart';

class MemoramaService {
  static final MemoramaService _instance = MemoramaService._internal();
  factory MemoramaService() => _instance;
  MemoramaService._internal();

  // Datos mock de palabras en zapoteco para el memorama
  static const List<Map<String, String>> _zapotecoWords = [
    {
      'zapoteco': 'Bixhozhe',
      'spanish': 'Hola',
      'image': '🖐️',
    },
    {
      'zapoteco': 'Guendaró',
      'spanish': 'Gracias',
      'image': '🙏',
    },
    {
      'zapoteco': 'Tobi',
      'spanish': 'Uno',
      'image': '1️⃣',
    },
    {
      'zapoteco': 'Chupa',
      'spanish': 'Dos',
      'image': '2️⃣',
    },
    {
      'zapoteco': 'Bicu\'',
      'spanish': 'Perro',
      'image': '🐕',
    },
    {
      'zapoteco': 'Mistu',
      'spanish': 'Gato',
      'image': '🐱',
    },
    {
      'zapoteco': 'Gueta',
      'spanish': 'Tortilla',
      'image': '🫓',
    },
    {
      'zapoteco': 'Nisa',
      'spanish': 'Agua',
      'image': '💧',
    },
    {
      'zapoteco': 'Guela',
      'spanish': 'Casa',
      'image': '🏠',
    },
    {
      'zapoteco': 'Guie\'',
      'spanish': 'Árbol',
      'image': '🌳',
    },
    {
      'zapoteco': 'Bedanda',
      'spanish': 'Familia',
      'image': '👨‍👩‍👧‍👦',
    },
    {
      'zapoteco': 'Bicuini',
      'spanish': 'Niño',
      'image': '👶',
    },
  ];

  /// Crear un juego de memorama con dificultad específica
  Future<MemoramaGameModel> createGame(String difficulty) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular carga

    final int pairCount = _getPairCountByDifficulty(difficulty);
    final selectedWords = _selectRandomWords(pairCount);
    final cards = _createCardPairs(selectedWords);
    
    return MemoramaGameModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Memorama Zapoteco - $difficulty',
      difficulty: difficulty,
      cards: cards,
    );
  }

  /// Obtener juegos guardados (mock)
  Future<List<MemoramaGameModel>> getSavedGames() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // En una implementación real, cargarías desde storage local
    return [];
  }

  /// Guardar progreso del juego
  Future<bool> saveGameProgress(MemoramaGameModel game) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // En una implementación real, guardarías en storage local
    return true;
  }

  /// Validar si dos cartas son pareja
  bool areCardsMatching(MemoramaCard card1, MemoramaCard card2) {
    // Las cartas hacen match si tienen el mismo ID base incluyendo el número (card_0, card_1, etc)
    // pero con diferentes sufijos (_zapoteco vs _spanish)
    final id1Parts = card1.id.split('_');
    final id2Parts = card2.id.split('_');
    
    if (id1Parts.length < 3 || id2Parts.length < 3) return false;
    
    final base1 = '${id1Parts[0]}_${id1Parts[1]}'; // card_0, card_1, etc
    final base2 = '${id2Parts[0]}_${id2Parts[1]}'; // card_0, card_1, etc
    final suffix1 = id1Parts[2]; // zapoteco o spanish
    final suffix2 = id2Parts[2]; // zapoteco o spanish
    
    final result = base1 == base2 && suffix1 != suffix2;
    
    // Debug logs
    print('Debug areCardsMatching:');
    print('  Card1 - ID: ${card1.id}, Base: $base1, Suffix: $suffix1, Word: ${card1.zapotecoWord}/${card1.spanishWord}');
    print('  Card2 - ID: ${card2.id}, Base: $base2, Suffix: $suffix2, Word: ${card2.zapotecoWord}/${card2.spanishWord}');
    print('  Same base? ${base1 == base2}, Different suffixes? ${suffix1 != suffix2}');
    print('  Result: $result');
    
    return result;
  }

  /// Calcular puntaje basado en moves y tiempo
  int calculateScore(int moves, int timeElapsed, String difficulty) {
    final baseScore = _getBaseScoreByDifficulty(difficulty);
    final movePenalty = moves * 2;
    final timePenalty = timeElapsed ~/ 10; // Penalización por cada 10 segundos
    
    final score = (baseScore - movePenalty - timePenalty).clamp(0, baseScore);
    return score;
  }

  /// Obtener estadísticas del juego
  Map<String, dynamic> getGameStats(MemoramaGameModel game) {
    final efficiency = game.matches > 0 ? (game.matches * 2) / game.moves : 0.0;
    final timePerMove = game.moves > 0 ? game.timeElapsed / game.moves : 0.0;
    
    return {
      'efficiency': efficiency.clamp(0.0, 1.0),
      'timePerMove': timePerMove,
      'perfectGame': game.moves == game.matches * 2,
      'grade': _calculateGrade(efficiency, game.timeElapsed),
    };
  }

  // Métodos privados

  int _getPairCountByDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
        return 4; // 8 cartas (4 pares)
      case 'medio':
        return 6; // 12 cartas (6 pares)
      case 'difícil':
        return 8; // 16 cartas (8 pares)
      default:
        return 4;
    }
  }

  int _getBaseScoreByDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
        return 100;
      case 'medio':
        return 200;
      case 'difícil':
        return 300;
      default:
        return 100;
    }
  }

  List<Map<String, String>> _selectRandomWords(int count) {
    final shuffled = List<Map<String, String>>.from(_zapotecoWords);
    shuffled.shuffle(Random());
    return shuffled.take(count).toList();
  }

  List<MemoramaCard> _createCardPairs(List<Map<String, String>> words) {
    final cards = <MemoramaCard>[];
    
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final baseId = 'card_$i';
      
      // Carta con palabra en zapoteco
      cards.add(MemoramaCard(
        id: '${baseId}_zapoteco',
        zapotecoWord: word['zapoteco']!,
        spanishWord: word['spanish']!,
        imageUrl: word['image']!,
      ));
      
      // Carta con traducción en español
      cards.add(MemoramaCard(
        id: '${baseId}_spanish',
        zapotecoWord: word['zapoteco']!,
        spanishWord: word['spanish']!,
        imageUrl: word['image']!,
      ));
    }
    
    // Mezclar las cartas
    cards.shuffle(Random());
    return cards;
  }

  String _calculateGrade(double efficiency, int timeElapsed) {
    if (efficiency >= 0.9 && timeElapsed < 60) return 'Excelente';
    if (efficiency >= 0.7 && timeElapsed < 120) return 'Muy bien';
    if (efficiency >= 0.5 && timeElapsed < 180) return 'Bien';
    if (efficiency >= 0.3) return 'Regular';
    return 'Necesitas practicar';
  }
}
