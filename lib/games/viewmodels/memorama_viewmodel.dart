import 'dart:async';
import 'package:flutter/material.dart';
import '../models/memorama_model.dart';
import '../services/memorama_service.dart';

enum MemoramaViewState {
  initial,
  loading,
  gameReady,
  playing,
  gameCompleted,
  error,
}

class MemoramaViewModel extends ChangeNotifier {
  final MemoramaService _memoramaService = MemoramaService();
  
  // State
  MemoramaViewState _viewState = MemoramaViewState.initial;
  MemoramaGameModel? _currentGame;
  String _errorMessage = '';
  Timer? _gameTimer;
  List<String> _selectedCardIds = [];
  bool _canFlipCards = true;

  // Getters
  MemoramaViewState get viewState => _viewState;
  MemoramaGameModel? get currentGame => _currentGame;
  String get errorMessage => _errorMessage;
  bool get isLoading => _viewState == MemoramaViewState.loading;
  bool get isPlaying => _viewState == MemoramaViewState.playing;
  bool get isGameCompleted => _viewState == MemoramaViewState.gameCompleted;
  bool get canFlipCards => _canFlipCards;
  List<String> get selectedCardIds => _selectedCardIds;

  // Computed properties
  String get formattedTime {
    if (_currentGame == null) return '00:00';
    final minutes = _currentGame!.timeElapsed ~/ 60;
    final seconds = _currentGame!.timeElapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get gameProgress {
    if (_currentGame == null) return 0.0;
    return _currentGame!.progress;
  }

  Map<String, dynamic> get gameStats {
    if (_currentGame == null) return {};
    return _memoramaService.getGameStats(_currentGame!);
  }

  // Public methods

  /// Inicializar un nuevo juego
  Future<void> startNewGame(String difficulty) async {
    try {
      _setViewState(MemoramaViewState.loading);
      
      final game = await _memoramaService.createGame(difficulty);
      _currentGame = game.copyWith(gameState: MemoramaGameState.waiting);
      _selectedCardIds.clear();
      _canFlipCards = true;
      
      _setViewState(MemoramaViewState.gameReady);
    } catch (e) {
      _errorMessage = 'Error al crear el juego: ${e.toString()}';
      _setViewState(MemoramaViewState.error);
    }
  }

  /// Comenzar el juego (iniciar timer)
  void beginGame() {
    if (_currentGame == null) return;
    
    _currentGame = _currentGame!.copyWith(gameState: MemoramaGameState.playing);
    _setViewState(MemoramaViewState.playing);
    _startTimer();
    notifyListeners();
  }

  /// Voltear una carta
  void flipCard(String cardId) {
    if (!_canFlipCards || 
        _currentGame == null || 
        _selectedCardIds.contains(cardId)) { // Evitar clics múltiples en la misma carta
      return;
    }

    // Verificar que la carta no esté ya volteada o emparejada
    final card = _currentGame!.cards.firstWhere((c) => c.id == cardId);
    if (card.state == CardState.matched || card.isFlipped) {
      return;
    }

    // Evitar seleccionar más de 2 cartas
    if (_selectedCardIds.length >= 2) {
      return;
    }

    // Si es la primera carta del juego, comenzar
    if (_viewState == MemoramaViewState.gameReady) {
      beginGame();
    }

    // Voltear la carta
    _flipCardInGame(cardId);
    _selectedCardIds.add(cardId);

    // Si se han seleccionado 2 cartas, validar
    if (_selectedCardIds.length == 2) {
      _canFlipCards = false;
      _validateCardMatch();
    }

    notifyListeners();
  }

  /// Pausar el juego
  void pauseGame() {
    if (_currentGame == null) return;
    
    _stopTimer();
    _currentGame = _currentGame!.copyWith(gameState: MemoramaGameState.paused);
    notifyListeners();
  }

  /// Reanudar el juego
  void resumeGame() {
    if (_currentGame == null) return;
    
    _currentGame = _currentGame!.copyWith(gameState: MemoramaGameState.playing);
    _startTimer();
    notifyListeners();
  }

  /// Reiniciar el juego actual
  void restartGame() {
    if (_currentGame == null) return;
    
    _stopTimer();
    
    // Reiniciar todas las cartas
    final resetCards = _currentGame!.cards.map((card) => 
      card.copyWith(state: CardState.hidden, isFlipped: false)
    ).toList();
    resetCards.shuffle();

    _currentGame = _currentGame!.copyWith(
      cards: resetCards,
      gameState: MemoramaGameState.waiting,
      moves: 0,
      matches: 0,
      timeElapsed: 0,
      score: 0,
      revealedCardIds: [],
    );

    _selectedCardIds.clear();
    _canFlipCards = true;
    _setViewState(MemoramaViewState.gameReady);
  }

  /// Salir del juego
  void exitGame() {
    _stopTimer();
    _currentGame = null;
    _selectedCardIds.clear();
    _canFlipCards = true;
    _setViewState(MemoramaViewState.initial);
  }

  // Private methods

  void _flipCardInGame(String cardId) {
    if (_currentGame == null) return;

    final updatedCards = _currentGame!.cards.map((card) {
      if (card.id == cardId) {
        return card.copyWith(
          state: CardState.flipped, // Temporal hasta validar
          isFlipped: true,
        );
      }
      return card;
    }).toList();

    _currentGame = _currentGame!.copyWith(cards: updatedCards);
  }

  void _validateCardMatch() {
    if (_currentGame == null || _selectedCardIds.length != 2) return;

    final card1 = _currentGame!.cards.firstWhere((c) => c.id == _selectedCardIds[0]);
    final card2 = _currentGame!.cards.firstWhere((c) => c.id == _selectedCardIds[1]);

    // Debug: Imprimir información de las cartas
    print('Debug - Card 1: ID=${card1.id}, Zapoteco=${card1.zapotecoWord}, Spanish=${card1.spanishWord}');
    print('Debug - Card 2: ID=${card2.id}, Zapoteco=${card2.zapotecoWord}, Spanish=${card2.spanishWord}');
    print('Debug - Are matching? ${_memoramaService.areCardsMatching(card1, card2)}');

    // Incrementar movimientos
    final newMoves = _currentGame!.moves + 1;

    if (_memoramaService.areCardsMatching(card1, card2)) {
      _handleCardMatch(newMoves);
    } else {
      _handleCardMismatch(newMoves);
    }
  }

  void _handleCardMatch(int newMoves) {
    if (_currentGame == null) return;

    // Primero marcar cartas como revealed (verde) para mostrar éxito
    final updatedCards = _currentGame!.cards.map((card) {
      if (_selectedCardIds.contains(card.id)) {
        return card.copyWith(state: CardState.revealed);
      }
      return card;
    }).toList();

    final newMatches = _currentGame!.matches + 1;
    final newScore = _memoramaService.calculateScore(
      newMoves, 
      _currentGame!.timeElapsed, 
      _currentGame!.difficulty
    );

    _currentGame = _currentGame!.copyWith(
      cards: updatedCards,
      moves: newMoves,
      matches: newMatches,
      score: newScore,
    );

    notifyListeners();

    // Después de 800ms, marcar como matched
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_currentGame != null && _selectedCardIds.isNotEmpty) {
        final matchedCards = _currentGame!.cards.map((card) {
          if (_selectedCardIds.contains(card.id)) {
            return card.copyWith(state: CardState.matched);
          }
          return card;
        }).toList();

        _currentGame = _currentGame!.copyWith(cards: matchedCards);
        _selectedCardIds.clear();
        _canFlipCards = true;

        // Verificar si el juego se completó
        if (_currentGame!.isCompleted) {
          _completeGame();
        }

        notifyListeners();
      }
    });
  }

  void _handleCardMismatch(int newMoves) {
    if (_currentGame == null) return;

    // Marcar las cartas como error (rojas) temporalmente
    final updatedCards = _currentGame!.cards.map((card) {
      if (_selectedCardIds.contains(card.id)) {
        return card.copyWith(state: CardState.error);
      }
      return card;
    }).toList();

    _currentGame = _currentGame!.copyWith(
      cards: updatedCards,
      moves: newMoves,
    );
    
    notifyListeners();

    // Esperar 1 segundo antes de voltear las cartas
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_currentGame != null && _selectedCardIds.isNotEmpty) {
        final resetCards = _currentGame!.cards.map((card) {
          if (_selectedCardIds.contains(card.id)) {
            return card.copyWith(
              state: CardState.hidden,
              isFlipped: false,
            );
          }
          return card;
        }).toList();

        _currentGame = _currentGame!.copyWith(cards: resetCards);
        _selectedCardIds.clear();
        _canFlipCards = true;
        notifyListeners();
      }
    });
  }

  void _completeGame() {
    _stopTimer();
    
    if (_currentGame != null) {
      _currentGame = _currentGame!.copyWith(gameState: MemoramaGameState.completed);
      _memoramaService.saveGameProgress(_currentGame!);
    }
    
    _setViewState(MemoramaViewState.gameCompleted);
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentGame != null && _currentGame!.gameState == MemoramaGameState.playing) {
        _currentGame = _currentGame!.copyWith(
          timeElapsed: _currentGame!.timeElapsed + 1,
        );
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void _setViewState(MemoramaViewState newState) {
    _viewState = newState;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}