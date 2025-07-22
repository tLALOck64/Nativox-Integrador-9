import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../models/user_progress_model.dart';
import '../services/lesson_service.dart';
import '../services/user_progress_service.dart';
import '../widgets/animated_header_widget.dart';
import '../widgets/progress_circle_widget.dart';
import '../widgets/lesson_card_widget.dart';
import '../widgets/streak_banner_widget.dart';
import '../widgets/custom_floating_button_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LessonService _lessonService = LessonService();
  final UserProgressService _userProgressService = UserProgressService();

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
      _showError('Error al cargar los datos: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
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

  void _onLessonTapped(LessonModel lesson) {
    if (lesson.isLocked) {
      _showMessage('Esta lección está bloqueada. Completa las anteriores primero.');
      return;
    }

    _showMessage('Iniciando lección: ${lesson.title}');
    // Navigator.pushNamed(context, '/lesson', arguments: lesson);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final crossAxisCount = (screenWidth / 200).floor().clamp(2, 4);

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
          child: _isLoading ? _buildLoadingState() : _buildMainContent(crossAxisCount, screenHeight),
        ),
      ),
      floatingActionButton: _userProgress != null
          ? CustomFloatingButtonWidget(
              onPressed: _onFloatingButtonPressed,
              tooltip: 'Continuar aprendiendo',
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
            semanticsLabel: 'Cargando progreso',
          ),
          SizedBox(height: 16),
          Text(
            'Cargando tu progreso...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
            semanticsLabel: 'Cargando tu progreso',
          ),
        ],
      ),
    );
  }


Widget _buildMainContent(int crossAxisCount, double screenHeight) {
  if (_userProgress == null) {
    return _buildErrorState();
  }

  return LayoutBuilder(
    builder: (context, constraints) {
      return RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFFD4A574),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  const AnimatedHeaderWidget(
                    title: 'Nativox',
                    subtitle: 'Preservando nuestras raíces',
                  ),

                  // Streak Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StreakBannerWidget(
                      streakDays: _userProgress!.streakDays,
                      isActive: _userProgress!.isStreakActive,
                      onTap: _onStreakBannerTapped,
                    ),
                  ),

                  // Progress Section
                  _buildProgressSection(),

                  // Lessons Grid
                  _buildLessonGrid(crossAxisCount),
                ],
              ),
            ),
          ),
        ),
      );
    },
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
            semanticLabel: 'Error',
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar los datos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
            semanticsLabel: 'Error al cargar los datos',
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
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tu progreso Actual',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
            semanticsLabel: 'Tu progreso actual',
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2, // Constrain height
            child: ProgressCircleWidget(
              progress: _userProgress!.overallProgress,
              percentage: _userProgress!.progressPercentage,
              level: _userProgress!.currentLevel,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Text(
            'Siguiente: ${_userProgress!.nextLesson}',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
            semanticsLabel: 'Siguiente lección: ${_userProgress!.nextLesson}',
          ),
        ],
      ),
    );
  }
Widget _buildLessonGrid(int crossAxisCount) {
  if (_lessons.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Text(
          'No hay lecciones disponibles',
          style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _lessons.length,
          itemBuilder: (context, index) {
            final lesson = _lessons[index];
            return LessonCardWidget(
              lesson: lesson,
              onTap: () => _onLessonTapped(lesson),
              shouldAnimate: true,
            );
          },
        );
      },
    ),
  );
}

  
}