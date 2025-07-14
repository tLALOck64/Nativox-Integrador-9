enum CardState {
  hidden,
  flipped, // Carta volteada pero aún no validada
  revealed, // Carta correcta (verde)
  matched,
  error, // Para cartas que no coinciden temporalmente
}

class MemoramaCard {
  final String id;
  final String zapotecoWord;
  final String spanishWord;
  final String imageUrl;
  final CardState state;
  final bool isFlipped;

  const MemoramaCard({
    required this.id,
    required this.zapotecoWord,
    required this.spanishWord,
    required this.imageUrl,
    this.state = CardState.hidden,
    this.isFlipped = false,
  });

  MemoramaCard copyWith({
    String? id,
    String? zapotecoWord,
    String? spanishWord,
    String? imageUrl,
    CardState? state,
    bool? isFlipped,
  }) {
    return MemoramaCard(
      id: id ?? this.id,
      zapotecoWord: zapotecoWord ?? this.zapotecoWord,
      spanishWord: spanishWord ?? this.spanishWord,
      imageUrl: imageUrl ?? this.imageUrl,
      state: state ?? this.state,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }

  factory MemoramaCard.fromJson(Map<String, dynamic> json) {
    return MemoramaCard(
      id: json['id'] ?? '',
      zapotecoWord: json['zapotecoWord'] ?? '',
      spanishWord: json['spanishWord'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zapotecoWord': zapotecoWord,
      'spanishWord': spanishWord,
      'imageUrl': imageUrl,
    };
  }
}

enum MemoramaGameState {
  waiting,
  playing,
  checking,
  completed,
  paused,
}

class MemoramaGameModel {
  final String id;
  final String title;
  final String difficulty;
  final List<MemoramaCard> cards;
  final MemoramaGameState gameState;
  final int moves;
  final int matches;
  final int timeElapsed;
  final int score;
  final List<String> revealedCardIds;

  const MemoramaGameModel({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.cards,
    this.gameState = MemoramaGameState.waiting,
    this.moves = 0,
    this.matches = 0,
    this.timeElapsed = 0,
    this.score = 0,
    this.revealedCardIds = const [],
  });

  MemoramaGameModel copyWith({
    String? id,
    String? title,
    String? difficulty,
    List<MemoramaCard>? cards,
    MemoramaGameState? gameState,
    int? moves,
    int? matches,
    int? timeElapsed,
    int? score,
    List<String>? revealedCardIds,
  }) {
    return MemoramaGameModel(
      id: id ?? this.id,
      title: title ?? this.title,
      difficulty: difficulty ?? this.difficulty,
      cards: cards ?? this.cards,
      gameState: gameState ?? this.gameState,
      moves: moves ?? this.moves,
      matches: matches ?? this.matches,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      score: score ?? this.score,
      revealedCardIds: revealedCardIds ?? this.revealedCardIds,
    );
  }

  // Getters útiles
  bool get isCompleted => matches == cards.length ~/ 2;
  bool get isPlaying => gameState == MemoramaGameState.playing;
  double get progress => matches / (cards.length ~/ 2);
  int get remainingPairs => (cards.length ~/ 2) - matches;
}