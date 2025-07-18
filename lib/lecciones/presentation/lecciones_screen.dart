import 'package:flutter/material.dart';
import 'package:integrador/games/screen/lesson_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../models/lesson_model.dart';
import '../../widgets/lesson_stats_widget.dart';
import '../../widgets/level_section_widget.dart';
import '../../widgets/custom_bottom_nav_widget.dart';
import 'lecciones_viewmodel.dart';

class LessonsView extends StatefulWidget {
  const LessonsView({super.key});
  @override
  State<LessonsView> createState() => _LessonsViewState();
}

class _LessonsViewState extends State<LessonsView> {
  late LessonsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<LessonsViewModel>();
    _viewModel.loadData();
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
          child: Consumer<LessonsViewModel>(
            builder: (context, viewModel, child) {
              return _buildContent(viewModel);
            },
          ),
        ),
      ),
      bottomNavigationBar: Consumer<LessonsViewModel>(
        builder: (context, viewModel, child) {
          return CustomBottomNavWidget(
            selectedIndex: viewModel.selectedIndex,
            onItemTapped: (index) => _onBottomNavTapped(index),
          );
        },
      ),
    );
  }

  Widget _buildContent(LessonsViewModel viewModel) {
    switch (viewModel.state) {
      case LessonsState.loading:
        return _buildLoadingState();
      case LessonsState.error:
        return _buildErrorState(viewModel);
      case LessonsState.loaded:
        return _buildLoadedState(viewModel);
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

  Widget _buildErrorState(LessonsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => viewModel.loadData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(LessonsViewModel viewModel) {
    return Column(
      children: [
        // Header
        _buildHeader(),
        
        // Stats
        if (viewModel.lessonStats.isNotEmpty)
          LessonStatsWidget(
            stats: viewModel.lessonStats,
            onTap: _onStatsBoxTapped,
          ),
        
        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.refreshData,
            color: const Color(0xFFD4A574),
            child: _buildLevelSections(viewModel),
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

  Widget _buildLevelSections(LessonsViewModel viewModel) {
    if (!viewModel.hasData) {
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

    final orderedLevels = viewModel.getOrderedLevels();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          ...orderedLevels.map((levelEntry) {
            return LevelSectionWidget(
              level: levelEntry.key,
              lessons: levelEntry.value,
              onLessonTap: (lesson) => _onLessonTapped(lesson),
            );
          }).toList(),
          
          // Bottom padding for safe area
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    _viewModel.updateSelectedIndex(index);
    
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
    print("holaaaa");
    final message = _viewModel.getLessonMessage(lesson);
    print(!_viewModel.canStartLesson(lesson));
    if (!_viewModel.canStartLesson(lesson)) {
      _showMessage(message);
      return;
    }

    _startLesson(lesson); 
  }

 Future<void> _startLesson(LessonModel lesson) async {
    try {
      print("cargando lección ${lesson.id}");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LessonDetailScreen(lessonId: lesson.id),
          ),
        );
      });

    } catch (e, stack) {
      print(" Error al iniciar la lección: $e");
      print("🪵 Stacktrace: $stack");
      _showMessage("Ocurrió un error al cargar la lección");
    }
  }

  void _onStatsBoxTapped() {
    _showMessage('Aquí podrías ver estadísticas detalladas');
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
}