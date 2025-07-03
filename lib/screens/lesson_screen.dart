import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../services/lesson_service.dart';
import '../widgets/lesson_stats_widget.dart';
import '../widgets/level_section_widget.dart';
import '../widgets/custom_bottom_nav_widget.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final LessonService _lessonService = LessonService();
  
  int _selectedIndex = 1; // Lessons tab is selected
  Map<String, List<LessonModel>> _lessonsByLevel = {};
  Map<String, int> _lessonStats = {};
  bool _isLoading = true;

  // Orden de niveles para mostrar
  final List<String> _levelOrder = ['Básico', 'Intermedio', 'Avanzado'];

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
        _lessonService.getLessonsByLevel(),
        _lessonService.getLessonStats(),
      ]);
      
      setState(() {
        _lessonsByLevel = results[0] as Map<String, List<LessonModel>>;
        _lessonStats = results[1] as Map<String, int>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar las lecciones');
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
        // Ya estamos en Lecciones
        break;
      case 2:
        _showMessage('Navegando a Práctica...');
        break;
      case 3:
        _showMessage('Navegando a Perfil...');
        break;
    }
  }

  void _onLessonTapped(LessonModel lesson) {
    if (lesson.isLocked) {
      _showMessage('Esta lección está bloqueada. Completa las anteriores primero.');
      return;
    }
    
    if (lesson.isCompleted) {
      _showMessage('Ya completaste esta lección. ¡Bien hecho! Puedes repetirla.');
    } else {
      _showMessage('Iniciando lección: ${lesson.title}');
    }
    
    // Aquí navegarías a la pantalla individual de la lección
    _startLesson(lesson);
  }

  Future<void> _startLesson(LessonModel lesson) async {
    // Simular inicio de lección
    _showMessage('Cargando lección "${lesson.title}"...');
    
    // Aquí podrías navegar a la pantalla de la lección individual
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => LessonDetailScreen(lesson: lesson),
    //   ),
    // );
  }

  void _onStatsBoxTapped() {
    _showMessage('Aquí podrías ver estadísticas detalladas');
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
            'Cargando lecciones...',
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
        
        // Stats
        if (_lessonStats.isNotEmpty)
          LessonStatsWidget(
            stats: _lessonStats,
            onTap: _onStatsBoxTapped,
          ),
        
        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFFD4A574),
            child: _buildLevelSections(),
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
                  'Lecciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Aprende paso a paso',
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

  Widget _buildLevelSections() {
    if (_lessonsByLevel.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📚',
              style: TextStyle(fontSize: 64),
            ),
            SizedBox(height: 16),
            Text(
              'No hay lecciones disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Mostrar niveles en orden específico
          ..._levelOrder.map((level) {
            if (_lessonsByLevel.containsKey(level)) {
              return LevelSectionWidget(
                level: level,
                lessons: _lessonsByLevel[level]!,
                onLessonTap: _onLessonTapped,
              );
            }
            return const SizedBox.shrink();
          }).toList(),
          
          // Mostrar cualquier nivel adicional que no esté en el orden predefinido
          ..._lessonsByLevel.entries
              .where((entry) => !_levelOrder.contains(entry.key))
              .map((entry) {
            return LevelSectionWidget(
              level: entry.key,
              lessons: entry.value,
              onLessonTap: _onLessonTapped,
            );
          }).toList(),
          
          // Bottom padding for safe area
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}