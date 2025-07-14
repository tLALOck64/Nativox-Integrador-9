import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/memorama_viewmodel.dart';
import '../widgets/memorama_card_widget.dart';
import '../models/memorama_model.dart';

class MemoramaGameScreen extends StatefulWidget {
  final String difficulty;

  const MemoramaGameScreen({
    super.key,
    this.difficulty = 'Fácil',
  });

  @override
  State<MemoramaGameScreen> createState() => _MemoramaGameScreenState();
}

class _MemoramaGameScreenState extends State<MemoramaGameScreen> {
  late MemoramaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MemoramaViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.startNewGame(widget.difficulty);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MemoramaViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF7F3F0), Color(0xFFE8DDD4)],
            ),
          ),
          child: SafeArea(
            child: Consumer<MemoramaViewModel>(
              builder: (context, viewModel, child) {
                return _buildContent(viewModel);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MemoramaViewModel viewModel) {
    switch (viewModel.viewState) {
      case MemoramaViewState.loading:
        return _buildLoadingState();
      case MemoramaViewState.error:
        return _buildErrorState(viewModel);
      case MemoramaViewState.gameReady:
      case MemoramaViewState.playing:
        return _buildGameState(viewModel);
      case MemoramaViewState.gameCompleted:
        return _buildCompletedState(viewModel);
      default:
        return _buildLoadingState();
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
          ),
          SizedBox(height: 16),
          Text(
            'Preparando memorama...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(MemoramaViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFD4A574),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar el juego',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameState(MemoramaViewModel viewModel) {
    final game = viewModel.currentGame!;
    
    return Column(
      children: [
        // Header con información del juego
        _buildGameHeader(viewModel),
        
        // Grid de cartas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCardGrid(game, viewModel),
          ),
        ),
        
        // Botones de control
        _buildControlButtons(viewModel),
      ],
    );
  }

  Widget _buildGameHeader(MemoramaViewModel viewModel) {
    final game = viewModel.currentGame!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
        ),
      ),
      child: Column(
        children: [
          // Botón atrás y título
          Row(
            children: [
              IconButton(
                onPressed: () => _showExitDialog(viewModel),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Memorama ${game.difficulty}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => _showPauseDialog(viewModel),
                icon: const Icon(Icons.pause, color: Colors.white),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Estadísticas del juego
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('⏱️', viewModel.formattedTime, 'Tiempo'),
              _buildStatItem('🎯', '${game.moves}', 'Movimientos'),
              _buildStatItem('✨', '${game.matches}/${game.cards.length ~/ 2}', 'Pares'),
              _buildStatItem('🏆', '${game.score}', 'Puntos'),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Barra de progreso
          LinearProgressIndicator(
            value: viewModel.gameProgress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCardGrid(MemoramaGameModel game, MemoramaViewModel viewModel) {
    final crossAxisCount = _getCrossAxisCount(game.cards.length);
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: game.cards.length,
      itemBuilder: (context, index) {
        final card = game.cards[index];
        return MemoramaCardWidget(
          card: card,
          isSelected: viewModel.selectedCardIds.contains(card.id),
          isDisabled: !viewModel.canFlipCards && !card.isFlipped,
          onTap: () => viewModel.flipCard(card.id),
        );
      },
    );
  }

  Widget _buildControlButtons(MemoramaViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showRestartDialog(viewModel),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD4A574),
                side: const BorderSide(color: Color(0xFFD4A574)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Reiniciar'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: viewModel.isPlaying 
                  ? () => _showPauseDialog(viewModel)
                  : viewModel.resumeGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(viewModel.isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(viewModel.isPlaying ? 'Pausar' : 'Continuar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState(MemoramaViewModel viewModel) {
    final game = viewModel.currentGame!;
    final stats = viewModel.gameStats;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animación de éxito
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFD4A574),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              '¡Felicitaciones!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4A574),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Completaste el memorama ${game.difficulty}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Estadísticas finales
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tiempo:'),
                      Text(
                        viewModel.formattedTime,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Movimientos:'),
                      Text(
                        '${game.moves}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Puntuación:'),
                      Text(
                        '${game.score}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD4A574),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Calificación:'),
                      Text(
                        stats['grade'] ?? 'Bien',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => viewModel.startNewGame(game.difficulty),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4A574),
                      side: const BorderSide(color: Color(0xFFD4A574)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Jugar de nuevo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A574),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Finalizar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares

  int _getCrossAxisCount(int cardCount) {
    if (cardCount <= 8) return 2;
    if (cardCount <= 12) return 3;
    return 4;
  }

  void _showExitDialog(MemoramaViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir del juego'),
        content: const Text('¿Estás seguro de que quieres salir? Se perderá el progreso actual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.exitGame();
              context.pop();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _showPauseDialog(MemoramaViewModel viewModel) {
    viewModel.pauseGame();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Juego pausado'),
        content: const Text('El tiempo se ha detenido. ¿Qué quieres hacer?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.resumeGame();
            },
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showRestartDialog(viewModel);
            },
            child: const Text('Reiniciar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showExitDialog(viewModel);
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _showRestartDialog(MemoramaViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar juego'),
        content: const Text('¿Estás seguro de que quieres reiniciar? Se perderá el progreso actual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.restartGame();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }
}