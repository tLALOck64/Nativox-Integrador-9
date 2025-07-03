import 'package:flutter/material.dart';
import '../models/practice_mode_model.dart';
import '../models/challenge_model.dart';
import '../models/practice_stats_model.dart';
import '../services/practice_service.dart';
import '../widgets/animated_header_widget.dart';
import '../widgets/practice_stats_widget.dart';
import '../widgets/practice_mode_card_widget.dart';
import '../widgets/challenge_card_widget.dart';
import '../widgets/custom_bottom_nav_widget.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final PracticeService _practiceService = PracticeService();
  
  int _selectedIndex = 2; // Practice tab is selected
  List<PracticeModeModel> _practiceModes = [];
  List<ChallengeModel> _challenges = [];
  PracticeStatsModel? _practiceStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Cargar datos en paralelo
      final results = await Future.wait([
        _practiceService.getPracticeModes(),
        _practiceService.getChallenges(),
        _practiceService.getPracticeStats(),
      ]);
      
      setState(() {
        _practiceModes = results[0] as List<PracticeModeModel>;
        _challenges = results[1] as List<ChallengeModel>;
        _practiceStats = results[2] as PracticeStatsModel;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar los datos de práctica');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navegar según el índice
    switch (index) {
      case 0:
        Navigator.of(context).pop(); // Volver a Home
        break;
      case 1:
        _showMessage('Navegando a Lecciones...');
        break;
      case 2:
        // Ya estamos en Práctica
        break;
      case 3:
        _showMessage('Navegando a Perfil...');
        break;
    }
  }

  void _onPracticeModeTapped(PracticeModeModel mode) {
    if (!mode.isUnlocked) {
      _showMessage('Este modo está bloqueado. Completa más lecciones para desbloquearlo.');
      return;
    }
    
    _showMessage('Iniciando modo: ${mode.title}');
    _startPracticeSession(mode);
  }

  Future<void> _startPracticeSession(PracticeModeModel mode) async {
    final success = await _practiceService.startPracticeSession(mode.id);
    if (success) {
      // Aquí navegarías a la pantalla de práctica específica
      _showMessage('Sesión de ${mode.title} iniciada');
      
      // Simular completar una sesión después de un delay
      Future.delayed(const Duration(seconds: 2), () {
        _completePracticeSession(mode.id);
      });
    } else {
      _showError('No se pudo iniciar la sesión de práctica');
    }
  }

  Future<void> _completePracticeSession(String modeId) async {
    // Simular datos de una sesión completada
    final success = await _practiceService.completePracticeSession(
      modeId,
      wordsCorrect: 8,
      totalWords: 10,
      durationMinutes: 5,
    );
    
    if (success) {
      _showMessage('¡Sesión completada! +8/10 palabras correctas');
      _loadData(); // Recargar datos para mostrar el progreso actualizado
    }
  }

  void _onChallengeTapped(ChallengeModel challenge) {
    if (challenge.status == ChallengeStatus.locked) {
      _showMessage('Este desafío está bloqueado.');
      return;
    }
    
    if (challenge.status == ChallengeStatus.completed) {
      _showMessage('Ya completaste este desafío. ¡Bien hecho!');
      return;
    }
    
    _showMessage('Iniciando desafío: ${challenge.title}');
    _startChallenge(challenge);
  }

  Future<void> _startChallenge(ChallengeModel challenge) async {
    final success = await _practiceService.startChallenge(challenge.id);
    if (success) {
      _showMessage('Desafío "${challenge.title}" iniciado');
      
      // Simular progreso del desafío
      Future.delayed(const Duration(seconds: 3), () {
        _updateChallengeProgress(challenge.id, challenge.target);
      });
    } else {
      _showError('No se pudo iniciar el desafío');
    }
  }

  Future<void> _updateChallengeProgress(String challengeId, int progress) async {
    final success = await _practiceService.updateChallengeProgress(challengeId, progress);
    if (success) {
      _showMessage('¡Desafío completado! 🏆');
      _loadData(); // Recargar datos
    }
  }

  void _onGoalTapped() {
    _showMessage('Aquí podrías ajustar tu meta semanal');
    // Aquí podrías mostrar un dialog para cambiar la meta
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F3F0), Color(0xFFE8DDD4)],
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingState() : _buildMainContent(),
        ),
      ),
      bottomNavigationBar: CustomBottomNavWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onBottomNavTapped,
      ),
    );
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
            'Cargando datos de práctica...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Header with back button
        _buildHeader(),
        
        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFFD4A574),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Practice Stats
                  if (_practiceStats != null)
                    PracticeStatsWidget(
                      stats: _practiceStats!,
                      onGoalTap: _onGoalTapped,
                    ),
                  
                  // Practice Modes
                  _buildPracticeModesSection(),
                  
                  // Challenges
                  _buildChallengesSection(),
                  
                  // Bottom padding for safe area
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
        ),
      ),
      child: Row(
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          
          // Title
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Práctica',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Refuerza tu aprendizaje',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // Spacer for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildPracticeModesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            child: Text(
              'Modos de práctica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          
          // Practice modes grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: _practiceModes.length,
            itemBuilder: (context, index) {
              final mode = _practiceModes[index];
              return PracticeModeCardWidget(
                practiceMode: mode,
                onTap: () => _onPracticeModeTapped(mode),
                shouldAnimate: index % 2 == 0, // Animar las tarjetas impares
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Text(
              'Desafíos diarios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
          
          // Challenges list
          if (_challenges.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Text(
                      '🎯',
                      style: TextStyle(fontSize: 48),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay desafíos disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _challenges.length,
              itemBuilder: (context, index) {
                final challenge = _challenges[index];
                return ChallengeCardWidget(
                  challenge: challenge,
                  onTap: () => _onChallengeTapped(challenge),
                );
              },
            ),
        ],
      ),
    );
  }
}