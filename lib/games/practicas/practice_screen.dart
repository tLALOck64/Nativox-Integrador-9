import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/practice_mode_model.dart';
import '../../services/practice_service.dart';
import 'package:integrador/core/config/app_theme.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with TickerProviderStateMixin {
  final PracticeService _practiceService = PracticeService();

  List<PracticeModeModel> _practiceModes = [];
  bool _isLoading = true;

  // SISTEMA DE COLORES CONSISTENTE - Mismo que HomeScreen y LessonsScreen
  static const Color _primaryColor = Color(0xFFD4A574);    // Dorado principal
  static const Color _backgroundColor = Color(0xFFF8F6F3); // Fondo cálido
  static const Color _surfaceColor = Color(0xFFFFFFFF);    // Tarjetas
  static const Color _textPrimary = Color(0xFF2C2C2C);     // Texto principal
  static const Color _textSecondary = Color(0xFF666666);   // Texto secundario
  static const Color _borderColor = Color(0xFFE8E1DC);     // Bordes suaves
  
  // Colores para diferentes modos de práctica
  static const Color _modeBlue = Color(0xFF2196F3);        // Traductor
  static const Color _modeGreen = Color(0xFF4CAF50);       // Audio
  static const Color _modePink = Color(0xFFE91E63);        // Memorama
  static const Color _modeOrange = Color(0xFFFF9800);      // Cuentos

  // Controladores de animación
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      _practiceModes = [
        PracticeModeModel(
          id: 'cuentos',
          icon: '📖',
          title: 'Cuentos',
          subtitle: 'Lee cuentos y pon aprueba tu comprensión lectora',
          difficulty: PracticeDifficulty.easy,
          completedSessions: 0,
          totalSessions: 0,
          isUnlocked: true,
        ),
        PracticeModeModel(
          id: 'translator',
          icon: '🔄',
          title: 'Traductor',
          subtitle: 'Practica traduciendo palabras y frases',
          difficulty: PracticeDifficulty.easy,
          completedSessions: 7,
          totalSessions: 10,
          isUnlocked: true,
        ),
        PracticeModeModel(
          id: 'audio_translator',
          icon: '🎤',
          title: 'Traductor de Audio',
          subtitle: 'Habla en zapoteco y escucha la traducción',
          difficulty: PracticeDifficulty.medium,
          completedSessions: 2,
          totalSessions: 8,
          isUnlocked: true,
        ),
        PracticeModeModel(
          id: 'memory_game',
          icon: '🧠',
          title: 'Memorama',
          subtitle: 'Encuentra las parejas de palabras',
          difficulty: PracticeDifficulty.medium,
          completedSessions: 4,
          totalSessions: 10,
          isUnlocked: true,
        ),
      ];

      if (mounted) {
        setState(() => _isLoading = false);
        
        // Iniciar animaciones después de cargar datos
        _fadeController.forward();
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          _slideController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error al cargar los modos de práctica');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  void _onPracticeModeTapped(PracticeModeModel mode) {
    if (!mode.isUnlocked) {
      _showMessage('Este modo está bloqueado. Completa más lecciones para desbloquearlo.');
      return;
    }
    if (mode.id == 'cuentos') {
      try {
        context.go('/cuentos');
      } catch (e) {
        _showMessage('Sección de cuentos próximamente');
      }
      return;
    }
    _showMessage('Iniciando ${mode.title}...');
    _startPracticeSession(mode);
  }

  Future<void> _startPracticeSession(PracticeModeModel mode) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      if (mode.id == 'translator') {
        _showMessage('¡Iniciando Traductor!');
        context.go('/traductor');
      } else if (mode.id == 'audio_translator') {
        _showMessage('¡Iniciando Traductor de Audio!');
        context.go('/audio-translate');
      } else if (mode.id == 'memory_game') {
        _showMessage('¡Iniciando Memorama!');
        context.go('/memorama');
      }
    } catch (e) {
      _showError('Error al navegar a ${mode.title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // Fondo consistente
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildMainContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cargando modos de práctica...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparando tus ejercicios interactivos',
              style: TextStyle(
                fontSize: 14,
                color: _textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Header consistente
            _buildHeader(),
            
            // Contenido scrolleable
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: _primaryColor,
                backgroundColor: _surfaceColor,
                strokeWidth: 3,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Welcome section
                    SliverToBoxAdapter(
                      child: _buildWelcomeSection(),
                    ),
                    
                    // Practice modes
                    SliverToBoxAdapter(
                      child: _buildPracticeModesSection(),
                    ),
                    
                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 40),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            _primaryColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button consistente
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.go('/home'),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Icono de práctica
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Texto del header
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Práctica',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Elige tu modo de práctica',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ícono principal
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.track_changes_rounded,
              color: _primaryColor,
              size: 36,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Título
          Text(
            '¡Es hora de practicar!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtítulo
          Text(
            'Mejora tus habilidades con nuestros ejercicios interactivos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary,
              height: 1.4,
              fontWeight: FontWeight.w500,
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
        children: _practiceModes.map((mode) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildPracticeModeCard(mode),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPracticeModeCard(PracticeModeModel mode) {
    // Configuración específica para cada modo
    Color modeColor;
    IconData iconData;

    switch (mode.id) {
      case 'translator':
        modeColor = _modeBlue;
        iconData = Icons.translate_rounded;
        break;
      case 'audio_translator':
        modeColor = _modeGreen;
        iconData = Icons.mic_rounded;
        break;
      case 'memory_game':
        modeColor = _modePink;
        iconData = Icons.psychology_rounded;
        break;
      case 'cuentos':
        modeColor = _modeOrange;
        iconData = Icons.menu_book_rounded;
        break;
      default:
        modeColor = _primaryColor;
        iconData = Icons.school_rounded;
    }

    bool isAudioMode = mode.id == 'audio_translator';

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _onPracticeModeTapped(mode),
          splashColor: modeColor.withOpacity(0.1),
          highlightColor: modeColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Ícono del modo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: modeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: modeColor.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: modeColor,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Contenido del modo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mode.title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          if (isAudioMode) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: modeColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: modeColor.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'PRÓXIMAMENTE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Subtítulo
                      Text(
                        mode.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Características especiales
                      if (isAudioMode) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: modeColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: modeColor.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.volume_up_rounded,
                                size: 16,
                                color: modeColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Con síntesis de voz',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: modeColor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Flecha indicadora
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: modeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: modeColor.withOpacity(0.8),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}