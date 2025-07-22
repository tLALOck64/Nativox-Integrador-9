import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/practice_mode_model.dart';
import '../services/practice_service.dart';

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

      // Añadir el modo de cuentos
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
      _showMessage(
        'Este modo está bloqueado. Completa más lecciones para desbloquearlo.',
      );
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
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeader(),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFFD4A574),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  _buildWelcomeSection(),

                  const SizedBox(height: 40),

                  _buildPracticeModesSection(),

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
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

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
          const Text('🎯', style: TextStyle(fontSize: 48)),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          if (isWide) {
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children:
                  _practiceModes
                      .map((mode) => _buildPracticeModeCard(mode))
                      .toList(),
            );
          } else {
            return Column(
              children:
                  _practiceModes.map((mode) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: _buildPracticeModeCard(mode),
                    );
                  }).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildPracticeModeCard(PracticeModeModel mode) {
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
      case 'cuentos':
        modeColor = const Color(0xFFB8956A);
        iconData = Icons.menu_book_rounded;
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
        border:
            mode.id == 'cuentos'
                ? Border.all(color: modeColor, width: 2)
                : Border.all(color: modeColor, width: 2),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: modeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: modeColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                                  mode.id == 'cuentos'
                                      ? modeColor
                                      : const Color(0xFF2C2C2C),
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
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              
              ],
            ),
          ),
        ),
      ),
    );
  }
}
