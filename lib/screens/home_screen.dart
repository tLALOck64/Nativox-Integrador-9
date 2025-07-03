import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../models/user_progress_model.dart';
import '../services/lesson_service.dart';
import '../services/user_progress_service.dart';
import '../widgets/animated_header_widget.dart';
import '../widgets/progress_circle_widget.dart';
import '../widgets/lesson_card_widget.dart';
import '../widgets/streak_banner_widget.dart';
import '../widgets/custom_bottom_nav_widget.dart';
import '../widgets/custom_floating_button_widget.dart';
import 'practice_screen.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LessonService _lessonService = LessonService();
  final UserProgressService _userProgressService = UserProgressService();

  int _selectedIndex = 0;
  List<LessonModel> _lessons = [];
  UserProgressModel? _userProgress;
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
        _lessonService.getAllLessons(),
        _userProgressService.getUserProgress(),
      ]);
      
      setState(() {
        _lessons = results[0] as List<LessonModel>;
        _userProgress = results[1] as UserProgressModel;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error al cargar los datos');
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

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Aquí puedes navegar a diferentes pantallas según el índice
    switch (index) {
      case 0:
        // Ya estamos en Home
        break;
      case 1:
        // Navegar a Lecciones
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LessonsScreen()),
        );
        break;
      case 2:
        // Navegar a Práctica
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PracticeScreen()),
        );
        break;
      case 3:
        // Navegar a Perfil
        _showMessage('Navegando a Perfil...');
        break;
    }
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

  void _onLessonTapped(LessonModel lesson) {
    if (lesson.isLocked) {
      _showMessage('Esta lección está bloqueada. Completa las anteriores primero.');
      return;
    }
    
    _showMessage('Iniciando lección: ${lesson.title}');
    // Aquí navegarías a la pantalla de la lección
  }

  void _onFloatingButtonPressed() {
    final nextLesson = _lessons.firstWhere(
      (lesson) => !lesson.isCompleted && !lesson.isLocked,
      orElse: () => _lessons.first,
    );
    
    _onLessonTapped(nextLesson);
  }

  void _onStreakBannerTapped() {
    _showMessage('¡Mantén tu racha activa practicando todos los días!');
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
      floatingActionButton: _userProgress != null
          ? CustomFloatingButtonWidget(
              onPressed: _onFloatingButtonPressed,
              tooltip: 'Continuar aprendiendo',
            )
          : null,
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
            'Cargando tu progreso...',
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
    if (_userProgress == null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        // Header
        const AnimatedHeaderWidget(
          title: 'Nativox',
          subtitle: 'Preservando nuestras raíces',
        ),
        
        // Streak Banner
        StreakBannerWidget(
          streakDays: _userProgress!.streakDays,
          isActive: _userProgress!.isStreakActive,
          onTap: _onStreakBannerTapped,
        ),
        
        // Progress Section
        _buildProgressSection(),
        
        // Lesson Grid
        Expanded(
          child: _buildLessonGrid(),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            'Error al cargar los datos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Por favor, intenta de nuevo',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
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
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          const Text(
            'Tu progreso en Náhuatl',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 20),
          
          // Progress Circle
          ProgressCircleWidget(
            progress: _userProgress!.overallProgress,
            percentage: _userProgress!.progressPercentage,
            level: _userProgress!.currentLevel,
          ),
          
          const SizedBox(height: 20),
          Text(
            'Siguiente: ${_userProgress!.nextLesson}',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonGrid() {
    if (_lessons.isEmpty) {
      return const Center(
        child: Text(
          'No hay lecciones disponibles',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFFD4A574),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: _lessons.length,
          itemBuilder: (context, index) {
            final lesson = _lessons[index];
            return LessonCardWidget(
              lesson: lesson,
              onTap: () => _onLessonTapped(lesson),
              shouldAnimate: index % 2 == 1, // Animar solo las tarjetas pares
            );
          },
        ),
      ),
    );
  }
}