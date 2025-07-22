
import 'package:flutter/material.dart';
import 'package:integrador/lecciones/domain/entities/lesson_stats.dart';
import 'package:integrador/lecciones/presentation/viewsmodels/base_view_model.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/lesson.dart';
import '../viewsmodels/lessons_view_model.dart';
import '../widgets/lesson_stats_widget.dart';
import '../widgets/level_section_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/lessons_header.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  late LessonsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Aquí inyectarías el ViewModel usando tu DI container
    // _viewModel = getIt<LessonsViewModel>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LessonsViewModel>.value(
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
            child: Consumer<LessonsViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  children: [
                    const LessonsHeader(),
                    Expanded(
                      child: _buildBody(viewModel),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(LessonsViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.initial:
      case ViewState.loading:
        return const LoadingWidget();
      
      case ViewState.error:
        return ErrorStateWidget(
          message: viewModel.errorMessage ?? 'Error desconocido',
          onRetry: viewModel.loadData,
        );
      
      case ViewState.empty:
        return const EmptyStateWidget(
          message: 'No hay lecciones disponibles',
          icon: '📚',
        );
      
      case ViewState.loaded:
        return _buildLoadedContent(viewModel);
    }
  }

  Widget _buildLoadedContent(LessonsViewModel viewModel) {
    return Column(
      children: [
        if (viewModel.lessonStats != LessonStats.empty)
          LessonStatsWidget(
            stats: viewModel.lessonStats,
            onTap: () => _showMessage('Estadísticas detalladas próximamente'),
          ),
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

  Widget _buildLevelSections(LessonsViewModel viewModel) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          ...viewModel.getAvailableLevels().map((level) {
            return LevelSectionWidget(
              level: int.parse(level),
              lessons: viewModel.getLessonsForLevel(level),
              onLessonTap: (lesson) => _onLessonTapped(lesson, viewModel),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _onLessonTapped(Lesson lesson, LessonsViewModel viewModel) async {
    final canStart = await viewModel.startLesson(lesson.id);
    
    if (canStart) {
      if (lesson.isCompleted) {
        _showMessage('Ya completaste esta lección. ¡Bien hecho! Puedes repetirla.');
      } else {
        _showMessage('Iniciando lección: ${lesson.title}');
      }
      
      // Navegar a la lección
      if (mounted) {
        context.push('/lessons/${lesson.id}');
      }
    } else {
      // El error se muestra automáticamente desde el ViewModel
      _showError(viewModel.errorMessage ?? 'No se pudo iniciar la lección');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
