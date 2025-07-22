import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/practice_mode_model.dart';
import '../../services/practice_service.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final PracticeService _practiceService = PracticeService();
  
  List<PracticeModeModel> _practiceModes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Crear solo los dos modos que necesitamos: Traductor y Memorama
      _practiceModes = [
        PracticeModeModel(
          id: 'translator',
          icon: '🔄', // Emoji como string
          title: 'Traductor',
          subtitle: 'Practica traduciendo palabras y frases',
          difficulty: PracticeDifficulty.easy,
          completedSessions: 7,
          totalSessions: 10,
          isUnlocked: true,
        ),
        PracticeModeModel(
          id: 'memory_game',
          icon: '🧠', // Emoji como string
          title: 'Memorama',
          subtitle: 'Encuentra las parejas de palabras',
          difficulty: PracticeDifficulty.medium,
          completedSessions: 4,
          totalSessions: 10,
          isUnlocked: true,
        ),
      ];
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar los modos de práctica');
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

  void _onPracticeModeTapped(PracticeModeModel mode) {
    if (!mode.isUnlocked) {
      _showMessage('Este modo está bloqueado. Completa más lecciones para desbloquearlo.');
      return;
    }
    
    _showMessage('Iniciando ${mode.title}...');
    _startPracticeSession(mode);
  }

  Future<void> _startPracticeSession(PracticeModeModel mode) async {
    // Simular inicio de sesión
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      if (mode.id == 'translator') {
        _showMessage('¡Iniciando Traductor!');
        // Navegar usando GoRouter
        context.go('/traductor');
      } else if (mode.id == 'memory_game') {
        _showMessage('¡Iniciando Memorama!');
        // Navegar usando GoRouter
        context.go('/memorama');
      }
    } catch (e) {
      _showError('Error al navegar a ${mode.title}');
    }
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
            'Cargando modos de práctica...',
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
                  const SizedBox(height: 40),
                  
                  // Welcome message
                  _buildWelcomeSection(),
                  
                  const SizedBox(height: 40),
                  
                  // Practice Modes
                  _buildPracticeModesSection(),
                  
                  // Bottom padding for safe area
                  const SizedBox(height: 40),
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
                  'Elige tu modo de práctica',
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

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎯',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Es hora de practicar!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mejora tus habilidades con nuestros ejercicios interactivos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
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
          
          // Practice modes - solo 2 modos en diseño vertical
          Column(
            children: _practiceModes.map((mode) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildPracticeModeCard(mode),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeModeCard(PracticeModeModel mode) {
    // Definir colores según el tipo de modo
    Color modeColor;
    IconData iconData;
    
    switch (mode.id) {
      case 'translator':
        modeColor = const Color(0xFF6B73FF);
        iconData = Icons.translate;
        break;
      case 'memory_game':
        modeColor = const Color(0xFFFF6B9D);
        iconData = Icons.psychology;
        break;
      default:
        modeColor = const Color(0xFFD4A574);
        iconData = Icons.school;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onPracticeModeTapped(mode),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Primera fila: Icon, título y arrow
                Row(
                  children: [
                    // Icon container
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: modeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData,
                        color: modeColor,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Título - Expandido para tomar el espacio disponible
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mode.subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow icon
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Segunda fila: Badges solamente
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: modeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mode.difficultyText,
                        style: TextStyle(
                          fontSize: 12,
                          color: modeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${mode.completedSessions}/${mode.totalSessions}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}